# programme pour tester l'assembleur riscv raspberry pico2
# uniquement assembleur riscv
# clignotement led utilisation multicoeur
/*********************************************/
/*           CONSTANTES                      */
/********************************************/
.equ ADRESSEPILE,     0x20082000
.equ TAILLESTACK,     0x800 
.equ LED_PIN,         25

.equ ATOMIC_XOR,      0x1000
.equ ATOMIC_SET,      0x2000
.equ ATOMIC_CLEAR,    0x3000

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

.equ GPIO_CTRL,       0x4
.equ PADS_BANK0_BASE, 0x40038000
.equ IO_BANK0_BASE,   0x40028000

.equ SIOBASE_FIF0_ST,     0x50
.equ SIOBASE_FIF0_WR,     0x54
.equ SIOBASE_FIF0_RD,     0x58
.equ SIO_FIFO_ST_RDY_BITS,   0x00000002
.equ SIO_FIFO_ST_VLD_BITS,   0x00000001
.equ SIO_IRQ_FIFO, 25


/*******************************************/
/* DONNEES INITIALISEES                    */
/*******************************************/ 
.data

.align 2
cmd_sequence:      .int 0,0,1,0,0,0,0          # séquence initialisation
iDelaiLed:           .int 500
/*******************************************/ 
/* DONNEES NON INITIALISEES                    */
/*******************************************/ 
.bss

/*************************************...-..--*/
/* SECTION CODE                              */
/**********************************************/
.text
.global main

main:                          # INFO: main
    call initDebut
    call initGpioLed
	
	la a0,execCore1              # fonction executée par le core1
    call multicore_init_core1    # mettre en commentaire pour voir la difference
	
	call clignoterLed            # clignotement led core0


100:                             # boucle finale
    j 100b
.align 2
iFlashdata:   .int _debutFlashData   
iRamdata:     .int _debutRamData 
iRamBss:      .int _debutRamBss
iFinRamBss:   .int _finRamBss	
iFinPile1:    .int _stack1
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
initGpioLed:                # INFO: initGpioLed
    addi    sp, sp, -4
    sw      ra, 0(sp)
	li t0,LED_PIN
    li t2,SIO_BASE
    li t1,1
    sll t1,t1,t0            # bit pin LED 
    sw  t1,GPIO_OE(t2)
	
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
/* pas de parametre   */
clignoterLed:                   # INFO: clignoterLed
    addi    sp, sp, -16         # save des registres
    sw      ra, 0(sp)
    sw      s0, 4(sp)
    sw      s1, 8(sp)
    sw      s2, 12(sp)
    li  s1,1
    slli s1,s1,LED_PIN          # GPIO pin 25
    li s2,SIO_BASE
    sw	s1,GPIO_OE_SET(s2)
    la  s0,iDelaiLed
1:
    sw s1,GPIO_OUT_SET(s2)      # extinction led
    lw a0,(s0)
    call attendre
    sw s1,GPIO_OUT_CLR(s2)      # allumage led
    lw a0,(s0)
    call attendre
    j 1b                         # boucle	
	
    lw      ra, 0(sp)
    lw      s0, 4(sp)
    lw      s1, 8(sp)
    lw      s2, 12(sp)
    addi    sp, sp, 16          # restaur registres
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

    slli s0,a0,12             # approximatif 
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
 /************************************/
/*       Exemple exec par le core1             */
/***********************************/
execCore1:                # INFO: execCore1
    addi    sp, sp, -8
    sw      ra, 0(sp)
	
	li a0,4000            # attente pour laisser le temps de clignoter long
    call attendre
	
	la t0,iDelaiLed       # modifier le delai depuis le core 1
    li t1,150
	sw t1,(t0)
1:
    j 1b                 # puis le core1 ne fait plus rien, il boucle
     
100:    
    lw      ra, 0(sp)
    addi    sp, sp, 8
    ret  
/************************************/
/*       initialisation Core 1            */
/***********************************/
#.extern _stack1,STACK_SIZE_C1
/* a0  adresse de la fonction à executer par le core 1 */
multicore_init_core1:        # INFO: multicore_launch_core1
    addi    sp, sp, -16      # save registres
    sw      ra, 0(sp)
    sw      s0, 4(sp)
    sw      s1, 8(sp)
    sw      s2, 12(sp)

    la t1,iFinPile1          # adresse pile pour le core1
    lw t3,(t1)
                             # invalidation interruption
    li t2,SIO_IRQ_FIFO       # IRQ FIFO 25
    li t1,1                  # partie haute du registre
    sll t2,t1,t2             # soit la valeur 0x02000000
    add t2,t2,1              # page 1

    csrc    0xbe2,t2         # MEIFA Register
    csrc    0xbe0,t2         # clear MEIEA Register  

    csrr  t2,mtvec          # recup adresse VECTOR
    addi t5,t3,-16          # fin de pile - 16 octets
    sw a0,(t5)              # stocke  adresse fonction
    addi t5,t3,-12          # fin de pile - 12 octets
    sw t3,(t5)              # stocke  fin de pile
    addi t5,t3,-8           # fin de pile - 8 octets
    sw x0,(t5)              # initialise à zero

    la t1,cmd_sequence
    sw t2,12(t1)            # stocke adresse vtor dans la sequence
    sw t3,16(t1)            # stocke adresse fin de pile - 12 octets dans la sequence de commande
    sw a0,20(t1)            # stocke l'adresse de la fonction
  
    li s0,0
    la s1,cmd_sequence      # adresse de la sequence d initialisation
1:
    sll t0,s0,2             #  déplacement
    
    add t0,t0,s1
    lw s2,(t0)
    bne s2,x0,2f
    call multicore_fifo_drain    # vide la file d'attente lecture fifo
 
2:
    mv a0,s2                    # adresse element séquence
    call  multicore_fifo_write  # envoi élément séquence
    call multicore_fifo_read    # réponse
    beq a0,s2,3f                # retour egal envoi ?
    li s0,0
    j 4f
    
3:
    addi s0,s0,1
4:
    li t1,5
    ble s0,t1,1b
    li a0,5
    call attendre
     
                             # autorisation interruption
    li t2,SIO_IRQ_FIFO       # IRQ FIFO 25
    li t1,1                  # partie haute du registre
    sll t2,t1,t2             # soit la valeur 0x02000000
    add t2,t2,1              # page 1

    csrc    0xbe2,t2          # MEIFA Register
    csrs    0xbe0,t2          # set MEIEA Register  

100:    
    lw      s0, 4(sp)
    lw      s1, 8(sp)
    lw      s2, 12(sp)
    lw      ra, 0(sp)
    addi    sp, sp, 16
    ret  
/************************************/
/* vidage de la file d'attente lecture FIFO              */
/***********************************/
multicore_fifo_drain:                 # INFO:  multicore_fifo_drain
    addi    sp, sp, -8                # save registres
    sw      ra, 0(sp)
    li t1,SIO_BASE
1:  
    lw t3,SIOBASE_FIF0_ST(t1)
    and t3,t3,SIO_FIFO_ST_VLD_BITS      #   soit 1
    beq t3,x0,2f
    lw t3,SIOBASE_FIF0_RD(t1)
    j 1b
2:    

100:    
    lw      ra, 0(sp)
    addi    sp, sp, 8
    ret 
/************************************/
/*         ecriture FIFO             */
/***********************************/
/* a0  contient la valeur à écrire */
multicore_fifo_write:            # INFO: multicore_fifo_write
    addi    sp, sp, -8           # save registres
    sw      ra, 0(sp)
    li t1,SIO_BASE
1:  
    lw t3,SIOBASE_FIF0_ST(t1)     # etat de la pile fifo
    and t3,t3,SIO_FIFO_ST_RDY_BITS
    beq t3,x0,1b                  # bit 1 à 2 ? et boucle
    sw a0,SIOBASE_FIF0_WR(t1)     # écriture dans la file FIFO 
  
    sgtz zero,ra                  # evenement vers l autre coeur
   
100: 
    lw      ra, 0(sp)
    addi    sp, sp, 8
    ret 
/************************************/
/*     lecture FIFO             */
/***********************************/
/* a0  retourne la valeur */
multicore_fifo_read:             # multicore_fifo_read
                                 # nom sdk : multicore_fifo_pop_blocking
    addi    sp, sp, -8           # save registres
    sw      ra, 0(sp)
    li t2,SIO_FIFO_ST_VLD_BITS
    la t1,SIO_BASE
    
1:  
    lw t3,SIOBASE_FIF0_ST(t1)     # etat de la pile fifo
    and t3,t3,t2
    bne t3,x0,3f                  #

2:
    sltz	zero,zero             # revoir le code de cette instruction
    lw t3,SIOBASE_FIF0_ST(t1)     # etat de la pile fifo
    and t3,t3,t2
    beq t3,x0,2b    #
    
3:
    lw a0,SIOBASE_FIF0_RD(t1)        # lecture fifo
    
100:    
    lw      ra, 0(sp)
    addi    sp, sp, 8
    ret 
	