/* Routines pour assembleur riscv pico2 */
/* version 2025 */
/*  */

.global initGpioLed,initHorloges,ledEclats,attendre,arretUrgent,attenteCourte,attenteCourteProg
.global attenteTresCourte,comparerChaines,resetUsbBootrom
/*******************************************/
/* CONSTANTES                              */
/*******************************************/ 
.include "./constantesPicoRisc.inc"
/*******************************************/
/* DONNEES INITIALISEES                    */
/*******************************************/ 
.data      

/***********************************************/
/* Données non initialisées                    */
/***********************************************/
.bss

/*******************************************/
/*  CODE PROGRAMME                         */
/*******************************************/  
.text

/************************************/       
/* comparaison de chaines           */
/************************************/      
/* a0 et a1 contiennent les adresses des chaines */
/* retour 0 dans r0 si egalite */
/* retour -1 si chaine r0 < chaine r1 */
/* retour 1  si chaine r0> chaine r1 */
comparerChaines:          # INFO: comparerChaines
    addi    sp, sp, -4
    sw      ra, 0(sp)

    li t0,0
1:
    add t1,t0,a0
    lb t1,(t1)
    add t2,t0,a1
    lb t2,(t2)
    beq t1,t2,2f
    bgt t1,t2,3f
    blt t1,t2,4f
2:                         # egal
    addi t0,t0,1
    bne t1,x0,1b           # fin chaine
    li a0,0                # egalité
    j 100f
3:                         # plus haut
    li a0,1
    j 100f
4:                         # plus bas
    li a0,-1
    j 100f
    
100:
    lw      ra, 0(sp)
    addi    sp, sp, 4
    ret
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

    slli s0,a0,15             # approximatif 
1:                            # loop 
    addi s0,s0, -1            # decrement indice
    bnez s0,1b
    lw      s0, 0(sp)
    addi    sp, sp, 4         # restaur registres
    ret 
/******************************************************************/
/*     initialisation   horloges                                          */ 
/******************************************************************/
initHorloges:                             # INFO: initHorloge
    addi    sp, sp, -4
    sw      ra, 0(sp)
    
    call initOscCristal

    /* init des PLL */
    call pll_init2
    call init_clk_sys2   
    call pll_usb_init2
    call init_clk_usb2
    
    lw      ra, 0(sp)
    addi    sp, sp, 4
    ret   
/******************************************************************/
/*     initialisation  cristal oscillateur                                          */ 
/******************************************************************/
initOscCristal:                     # INFO: initOscCristal
    addi    sp, sp, -8
    sw      ra, 0(sp)
    li t1,0
    li t0,CLOCKS_BASE
    li t2,CLOCKS_BASE
    sw t1,CLK_SYS_RESUS_CTRL(t2)
    li t2,XOSC_BASE
    li t3,0x2f                  # avant 301 ou 2f
    sw t3,XOSC_STARTUP(t2)      # A value of 47 for XOSC_DELAY would suffice,,
                                # but writing 0x301 to is saves one opcode.
    
    li t3,XOSC_ENABLE_12MHZ
    sw t3,XOSC_CTRL(t2)
    
1:                              # Wait for stable flag (in MSB)
    lw t0,XOSC_STATUS(t2)
    bge t0,x0,1b

    lw      ra, 0(sp)
    addi    sp, sp, 8
    ret
/***********************************/
/*       reset Pll SYS   */
/***********************************/
/* cf datasheet     8.6 PLL  */
pll_reset2:                   # INFO: pll_reset2 voir chapitre 8.6
    addi    sp, sp, -8         # save des registres
    sw      ra, 0(sp)
    
    li  t1,RESETS_RESET_PLL_SYS_BITS | RESETS_RESET_PLL_USB_BITS
    li t0,RESETS_BASE + 0x3000
    li t2,RESETS_BASE + 0x2000
    sw t1,RESETS_RESET(t2)
    sw t1,RESETS_RESET(t0)

    li t2,RESETS_BASE
1:                                 # boucle attente reset ok
    lw t3,RESETS_DONE(t2)
    and t3,t3,t1
    beq t3,x0,1b
    
    lw      ra, 0(sp)
    addi    sp, sp, 8               # restaur registres
    ret
/***********************************/
/*       Init Pll SYS   */
/***********************************/
.equ PLL_PWR_PD_BITS,   1
.equ PLL_PWR_VCOPD_BITS,  0x00000020
.equ PLL_PWR_POSTDIVPD_BITS, 8
.equ PLL_CS_REFDIV_BITS, 0x3F
.equ PLL_CS_LOCK_N_BITS,   0x40000000
/* cf datasheet     8.6 PLL  */
/*  PLL SYS: 12 / 1 = 12MHz * 125 = 1500MHZ / 5 / 2 = 150MHz  */
pll_init2:                   # INFO: pll_init2 voir chapitre 8.6
    addi    sp, sp, -8         # save des registres
    sw      ra, 0(sp)
    
    call pll_reset2         # reset PLL obligatoire
    
    li t4,PLL_SYS_BASE + ATOMIC_SET   # Adresse PLL + set
    li t1,1
    sw t1,(t4)             # stocke ref (1) dans registre CS
    li t0,PLL_CS_LOCK_N_BITS
    li t4,PLL_SYS_BASE         # PLLSYSBASE
1:                           # attente lock 
    lw t2,(t4)               # charge registre CS
    and t2,t2,t0
    bne t2,x0,1b

    li t0,125                # frequence
    li t3,21
    sw t0,8(t4)                # stocke le résultat dans FBDIV_INT

    li t1,PLL_SYS_BASE + ATOMIC_CLEAR           #  pwr clear
    sw t3,4(t1)              # registre PWR
    
    li t3,PLL_CS_LOCK_N_BITS
2:
    lw t2,(t4)               # charge registre CS 
    and t2,t2,t3
    bne t2,x0,2b             # attente lock 
    
    li t3,PLL_PWR_POSTDIVPD_BITS
    li t0,2                    # diviseur 2
    sll t0,t0,12
    li t2,5                   # diviseur 1
    sll t2,t2,16 
    or t2,t2,t0  
    sw t2,12(t4)               # PRIM register
    
    sw t3,4(t1)              # registre PWR
    
    lw      ra, 0(sp)
    addi    sp, sp, 8          # restaur registres
    ret

/***********************************/
/*       Init hologe systeme    */
/***********************************/
init_clk_sys2:                     # INFO: init_clk_sys2
    addi    sp, sp, -8
    sw      ra, 0(sp)
    li t2,1
    slli t2,t2,16                 # bit 16 à 1
    li t3,CLOCKS_BASE #0x40010040       # CLK_SYS_DIV adresse diviseur horloge système
    sw t2,CLK_SYS_DIV(t3)            # met 1 dans le bit 16 du diviseur

1:
    li t1,1
    li t0,0b0000000011100001
    li t3,CLOCKS_BASE    #0x4001003c              # CLK_SYS_CTRL
    lw t2,CLK_SYS_CTRL(t3)
    li t4,CLOCKS_BASE + ATOMIC_CLEAR #0x4001303c              # CLK_SYS_CTRL + 0x3000
    sw t0,CLK_SYS_CTRL(t4)
    li a0,1
    call attendre                 # TODO: voir si necessaire
    
 
    li t1,0b0000001            # valeur 0 dans bits 5,6 et 1 dans bit 0
    li t4,CLOCKS_BASE + ATOMIC_SET # 0x4001203c           # CLK_SYS_CTRL + 0x2000
    sw t1,CLK_SYS_CTRL(t4)         # stocke nouvelle valeur dans les bits 0,1 6,7,8

    li t1,CLOCKS_BASE           #0x40010044  
    li t3,0b11                   # pour tester le bit 0 et 1
3:
    lw t2,CLK_SYS_SELECTED(t1)
    and t2,t2,t3             # test bit 0 et 1 
    beq  t2,x0,3b            # boucle attente

    lw      ra, 0(sp)
    addi    sp, sp, 8          # restaur registres
    ret   
/***********************************/
/*       Init Pll USB   */
/***********************************/
.equ PLL_PWR_PD_BITS,   1
.equ PLL_PWR_VCOPD_BITS,  0x00000020
.equ PLL_PWR_POSTDIVPD_BITS, 8
.equ PLL_CS_REFDIV_BITS, 0x3F
.equ PLL_CS_LOCK_N_BITS,   0x40000000
/* cf datasheet     2.18 PLL  */
/*  PLL USB: 12 / 1 = 12MHz * 100 = 1200MHZ / 5 / 5 = 48MHz  */
pll_usb_init2:                 # INFO: pll_usb_init2 voir chapitre 8.6
    addi    sp, sp, -8         # save des registres
    sw      ra, 0(sp)
    
    li t4,PLL_USB_BASE         # 
    li t1,1
    sw t1,(t4)                 # stocke ref (1) dans registre CS
    li t0,PLL_CS_LOCK_N_BITS
1:                             # attente lock 
    lw t2,(t4)                 # charge registre CS
    and t2,t2,t0
    bne t2,x0,1b
 
    li t0,100                  # fréquence en khz
    li t3,21
    sw t0,8(t4)                # stocke le résultat dans FBDIV_INT
    li t1,PLL_USB_BASE + ATOMIC_CLEAR  # stocke 21 base + pwr + 0x3000
    sw t3,4(t1)                 # registre PWR
    
    li t3,PLL_CS_LOCK_N_BITS
2:
    lw t2,(t4)                    # charge registre CS 
    and t2,t2,t3
    bne t2,x0,2b                  # attente lock
    
    li t3,PLL_PWR_POSTDIVPD_BITS  # valeur 8
    li t0,5                       # diviseur 2
    sll t0,t0,12
    li t2,5                       # diviseur 1
    sll t2,t2,16 
    or t2,t2,t0  
    sw t2,12(t4)                   # PRIM register
    
    sw t3,4(t1)                    # stocke 8 dans base + pwr + 0x3000 clear

    
    lw      ra, 0(sp)
    addi    sp, sp, 8          # restaur registres
    ret
    
/***********************************/
/*       Init hologe systeme    */
/***********************************/
.equ CLOCKS_CLK_USB_CTRL_ENABLED_BITS,   0x10000000
init_clk_usb2:                     # INFO: init_clk_usb2
    addi    sp, sp, -8         # save des registres
    sw      ra, 0(sp)
    li t2,1
    slli t2,t2,16                 # bit 16 à 1
    li t3,CLOCKS_BASE + ATOMIC_SET  # CLK_USB_DIV  +0x2000 adresse diviseur horloge usb
    sw t2,CLK_USB_DIV(t3)                    # met 1 dans le bit 16 du diviseur
   
1:
    li    t1, 1
    li t2,CLOCKS_BASE + ATOMIC_CLEAR # CLK_USB_CTRL + 0x3000
    li t3,CLOCKS_BASE #0x40010060             # CLK_USB_CTRL
    slli t1,t1,11
    sw t1,CLK_USB_CTRL(t2)                   # clear le bit 11

    
    li t0,CLOCKS_CLK_USB_CTRL_ENABLED_BITS
2:
    lw t2,CLK_USB_CTRL(t3)
    and t2,t2,t0                # teste le bit 28
    bne t2,x0,2b
 
    li t1,1
    li t0,0b000000011100011        # valeur 3 dans bits 5,6,7 et 0 dans bit 0 et 1
    li t3,CLOCKS_BASE              # CLK_USB_CTRL
    lw t2,CLK_USB_CTRL(t3)
    li t4,CLOCKS_BASE + ATOMIC_CLEAR #0x40013060              # CLK_USB_CTRL + 0x3000
    sw t0,CLK_USB_CTRL(t4)
    li a0,10
    call attendre                 # TODO: voir si necessaire
    
 
    li t1,0b01100000            # valeur 3 dans bits 5,6,7 et 0 dans bit 0 et 1
    li t4,CLOCKS_BASE + ATOMIC_SET #0x40012060            # CLK_USB_CTRL + 0x2000
   # sw t1,CLK_USB_CTRL(t4)                 # stocke nouvelle valeur dans les bits 0,1 6,7,8
    li    t2,1
    slli  t2,t2,11               #  bit 11 à 1
    li t3,CLOCKS_BASE + ATOMIC_SET #0x40012060             # CLK_SYS_CTRL + 0x2000
    sw t2,CLK_USB_CTRL(t3)

    li t1,CLOCKS_BASE #0x40010060             # CLK_USB_CTRL
    li t3,CLOCKS_CLK_USB_CTRL_ENABLED_BITS
3:
    lw t2,CLK_USB_CTRL(t1)
    and t2,t2,t3                 # test bit 28
    beq  t2,x0,3b


    lw      ra, 0(sp)
    addi    sp, sp, 8          # restaur registres
    ret   
	
/************************************/
/*       appel des fonctions de la Rom            */
/***********************************/
.equ ROM_TABLE_LOOK_ENTRY,  0x00007dfa
.equ BOOTROM_ROMTABLE_START, 0x00007df6
/* a0 Code 1  */
/* a1 code 2  */
/* a2 parametre fonction 1 */
/* a3 parametre fonction 2 */
/* a4 parametre fonction 3 */
/* TODO: voir si plus de 3 paramètres */
/* 3.8.1.6. Alphabetical List of Instructions*/
appelFctRom:                   # INFO: appelFctRom
    addi    sp, sp, -16
    sw      ra, 0(sp)
    sw      a2, 4(sp)
    sw      a3, 8(sp)
    sw      a4, 12(sp)
    slli a1,a1,8                 # conversion des codes
    
    or a0,a0,a1
    li t1,ROM_TABLE_LOOK_ENTRY
    li t2,0
    lhu t2,0(t1)               # sur 2 octets seulement
 
    li t1,BOOTROM_ROMTABLE_START
    li t3,0
    lh t3,0(t1)                # sur 2 octets seulement

    li a1,1
   # li t1,0x13             # pour vérifier le code doit etre = 2
   # lbu t1,[t1]
   # affregtit fctRom
    jalr t2               # recherche adresse fonction
    mv t2,x10
 
    lw      a0, 4(sp)           # Comme r2 et r3 peuvent être écrasés par l appel précedent
    lw      a1, 8(sp)           # récupération des paramétres 1 et  2 pour la fonction
    lw      a2, 12(sp)
    li a3,0
    jalr t2                    # et appel de la fonction trouvée 

    lw      ra, 0(sp)
    
    addi    sp, sp, 16         # restaur registres
    ret
/************************************/
/*       relance demarrage usb bootrom              */
/***********************************/
resetUsbBootrom:              # INFO: resetUsbBootrom
    addi    sp, sp, -8
    sw      ra, 0(sp)
    li a0,'R'                 # code reset USB
    li a1,'B'
    li a2,0x102              # reboot mode bootsel
    li a3,100
    li a4,0
 
    call appelFctRom
    lw      ra, 0(sp)
    addi    sp, sp, 8         # restaur registres
    ret  	
	
/**********************************************/
/* attente courte                     */
/**********************************************/ 
attenteCourte:               # INFO: attenteCourte
    addi    sp, sp, -8
    sw      ra, 0(sp) 
    sw      t0, 4(sp)
    li t0,250
    slli t0,t0,6
1:
    addi t0,t0,-1
    bgt t0,x0,1b
    
    lw      t0, 4(sp)
    lw      ra, 0(sp)
    addi    sp, sp, 8
    ret 
	/**********************************************/
/* attente courte                     */
/**********************************************/ 
/* a0 contient la valeur d'attente */
/*  1  fait 656 cycles  soit 8 nanosecondes * 656  5,2 microsecondes */
attenteCourteProg:               # INFO: attenteCourteProg
    addi    sp, sp, -8
    sw      ra, 0(sp) 
    slli a0,a0,6
1:
    addi a0,a0,-1
    bgt a0,x0,1b
    
    lw      ra, 0(sp)
    addi    sp, sp, 8
    ret 
/**********************************************/
/* attente courte                     */
/**********************************************/ 
/* a0 contient la valeur d'attente */
attenteTresCourte:               # INFO: attenteTresCourte
    addi    sp, sp, -8
    sw      ra, 0(sp) 
    slli a0,a0,5
1:
    addi a0,a0,-1
    bgt a0,x0,1b
    
    lw      ra, 0(sp)
    addi    sp, sp, 8
    ret 	
	
/**********************************************/
/* arret d'urgence mettre registre powman      */
/**********************************************/
arretUrgent:                      # INFO: arretUrgent
    addi    sp, sp, -8
    sw      ra, 0(sp)    
 1:              # boucle 
    j  1b
    lw      ra, 0(sp)
    addi    sp, sp, 8
    ret   
	