# programme pour tester l'assembleur riscv raspberry pico2
# uniquement assembleur riscv
# Clignottement Led, copie data
/*********************************************/
/*           CONSTANTES                      */
/********************************************/
.equ ADRESSEPILE,  0x20082000
.equ LED_PIN,    25

.equ ATOMIC_XOR,   0x1000
.equ ATOMIC_SET,   0x2000
.equ ATOMIC_CLEAR, 0x3000

.equ SIO_BASE,        0xD0000000

.equ GPIO_FUNC_SIO,   5

.equ SIOBASE_CPUID  , 0x000 # Processor core identifier
.equ GPIO_IN        , 0x004 # Input value for GPIO pins
.equ GPIO_HI_IN     , 0x008 # Input value for QSPI pins
.equ GPIO_OUT       , 0x010 # GPIO output value
.equ GPIO_HI_OUT    , 0x014 # QSPI output value

.equ GPIO_OUT_SET   , 0x018 # GPIO output value set
.equ GPIO_HI_OUT_SET, 0x01C # QSPI output value set

.equ GPIO_OUT_CLR   , 0x020 # GPIO output value clear
.equ GPIO_HI_OUT_CLR, 0x024 # QSPI output value clear

.equ GPIO_OUT_XOR   , 0x028 # GPIO output value XOR
.equ GPIO_HI_OUT_XOR, 0x02c # QSPI output value XOR
.equ GPIO_OE        , 0x030 # GPIO output enable
.equ GPIO_HI_OE     , 0x034 # QSPI output enable
.equ GPIO_OE_SET    , 0x038 # GPIO output enable set
.equ GPIO_HI_OE_SET , 0x03C # QSPI output enable set
.equ GPIO_OE_CLR    , 0x040 # GPIO output enable clear
.equ GPIO_HI_OE_CLR , 0x044 # QSPI output enable clear
.equ GPIO_OE_XOR    , 0x048 # GPIO output enable XOR
.equ GPIO_HI_OE_XOR , 0x04c # QSPI output enable XOR

.equ GPIO_CTRL,     0x4
.equ PADS_BANK0_BASE, 0x40038000
.equ IO_BANK0_BASE,   0x40028000


/*******************************************/
/* DONNEES INITIALISEES                    */
/*******************************************/ 
.data

.align 2
nbEclairs:     .int 8
/*******************************************/ 
/* DONNEES NON INITIALISEES                    */
/*******************************************/ 
.bss

/**********************************************/
/* SECTION CODE                              */
/**********************************************/
.text
.global main

main:                          # INFO: main
    call initDebut
    call initGpioLed
	la t0,nbEclairs
	lw a0,(t0)
	call ledEclats

100:                           # boucle finale
    j 100b
.align 2
iFlashdata:   .int _debutFlashData   
iRamdata:     .int _debutRamData 
iRamBss:      .int _debutRamBss
iFinRamBss:   .int _finRamBss	
.align 2                              # bloc obligatoire voir chapitre 5.9
blocembd:       .int 0xffffded3       # image riscv
                .int 0x11010142       # voir doc section 5.9.5
                .int 0x00000344
                .int 0x10000000       # initial pointer address
                #.int 0x20082000       # initial stack address
                .int ADRESSEPILE
                .int 0x000004FF       # dernier item avec taille du suivant
                .int 0x00000000       # fib de la boucle
                .int 0xab123579       # image end 	
/************************************/
/*       init gpio               */
/***********************************/
/* a0 pin led */
initGpioLed:                   # INFO: initGpioLed
    addi    sp, sp, -4
    sw      ra, 0(sp)
	li t0,LED_PIN
    li    t2,SIO_BASE
    li t1,1
    sll    t1,t1,t0         # bit pin LED 
    sw    t1,GPIO_OE(t2)
	
	li t2,PADS_BANK0_BASE + ATOMIC_SET
    slli t1,t0,2            # pin * 4
    add  t2,t2,t1   
	li t4,0b1000000 
    sw    t4,4(t2)          # charge valeur pour le pin (25 * 4 ) + 4 (VOLTAGE_SELECT)
  
	li t2,PADS_BANK0_BASE + ATOMIC_CLEAR
    slli t1,t0,2            # pin * 4
    add  t2,t2,t1   
	li t4,0b100000000 
    sw    t4,4(t2)          #   clear isolation bit
	
    li t2,IO_BANK0_BASE 
    slli t1,t0,3             # pin * 8
    add t2,t2, t1            # add to address BANK0  
    li    t4,GPIO_FUNC_SIO            
    sw    t4,GPIO_CTRL(t2)   # stocke le code fonction

100:	
    lw      ra, 0(sp)
    addi    sp, sp, 4
    ret

/************************************/
/*       LED  Eclat               */
/***********************************/
/* a0 contient le nombre d éclats   */
ledEclats:                      # INFO: ledEclats
    addi    sp, sp, -16         # save des registres
    sw      ra, 0(sp)
    sw      s0, 4(sp)
    sw      s1, 8(sp)
    sw      s2, 12(sp)
    mv s0,a0
    li  s1,1
    slli s1,s1,LED_PIN                # GPIO pin 25
    li s2,SIO_BASE
    sw	s1,GPIO_OE_SET(s2)
1:
    sw s1,GPIO_OUT_SET(s2)          # extinction led
    li a0,250
    call attendre
    sw s1,GPIO_OUT_CLR(s2)              # allumage led
    li a0,250
    call attendre
    
    addi s0,s0,-1               # décremente nombre eclats
    bgtz s0,1b                # et boucle 
    lw      ra, 0(sp)
    lw      s0, 4(sp)
    lw      s1, 8(sp)
    lw      s2, 12(sp)
    addi    sp, sp, 16          # restaur registres
    ret
/************************************/
/*       boucle attente            */
/***********************************/
/* a0 valeur en milliseconde   */
attendre:                     # INFO: attendre
    addi    sp, sp, -4        # save des registres
    sw      s0, 0(sp)

    slli s0,a0,13             # approximatif 
   # slli a0,a0,10
   #add a0,a0,t1
1:                            # loop 
    addi s0,s0, -1            # decrement indice
    bnez s0,1b
    lw      s0, 0(sp)
    addi    sp, sp, 4         # restaur registres
    ret 
/************************************/
/*       init debut              */
/***********************************/
initDebut:                   # INFO: initDebut
    addi    sp, sp, -8
    sw      ra, 0(sp) 
    la t1,iFlashdata
    lw t1,(t1)

    la t2,iRamdata
    lw t2,(t2)
    la t3,iRamBss
    lw t3,(t3)

1:                           # boucle de copie de la data en rom
    lw t0,(t1)               # vers la data en ram
    sw t0,(t2)
    addi t1,t1,4
    addi t2,t2,4
    bltu t2,t3,1b
                             #  initialisation  .bss
    la t2,iFinRamBss
    lw t2,(t2)
2:
    sw x0,(t3)
    addi t3,t3,4
    bltu t3,t2,2b

    lw      ra, 0(sp)
    addi    sp, sp, 8
    ret        

 
