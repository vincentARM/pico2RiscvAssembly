# programme pour tester l'assembleur riscv raspberry pico2
# uniquement assembleur riscv
#
/*********************************************/
/*           CONSTANTES                      */
/********************************************/
.include "./constantesPicoRisc.inc"
.equ ADRESSEPILE,     0x20082000


/****************************************************/
/* macro d'affichage d'un libellé                   */
/****************************************************/
/* pas d'espace dans le libellé sinon mettre entre quotes    */
/* attention pas de save du registre d'état */
.macro afficherLib str 
    addi    sp, sp, -16   # reserve pile
    sw      ra, 0(sp)     # save des registres
    sw      a0, 4(sp) 
    sw      s1, 8(sp)
    sw      t1,12(sp)
    la a0,libaff1\@       # recup adresse libellé passé dans str
    call envoyerMessage   # affichage
    lw      ra, 0(sp)     # restaure des registres
    lw      a0, 4(sp)
    lw      s1, 8(sp)
    lw      t1,12(sp)
    addi    sp, sp, 16
    j smacroafficheMess\@      # pour sauter le stockage de la chaine.
.data    
.align 2
libaff1\@:     .asciz "\str\r\n"   # stockage de la chaine reçue dans str
.text
.align 2
smacroafficheMess\@:     
.endm                          # fin de la macro
/*******************************************/
/* DONNEES INITIALISEES                    */
/*******************************************/ 
.data
szMessDemStd:      .asciz "Demarrage normal riscv.\r\n"
szMessCmd:         .asciz "\r\nEntrez une commande (ou aide) : "
szCarriageReturn:  .asciz "\r\n"
szLibCmdAff:       .asciz "aff"
szLibCmdAide:      .asciz "aide"
szLibCmdTab:       .asciz "tab"
szLibCmdFin:       .asciz "fin"
szLibListeCom:     .asciz "aff\r\ntab\r\nfin\r\n"
szLibCommOK:       .asciz "Commande OK."
.align 2
tabnombre:         .int  1,2,3,4
.equ NBTABNOMBRE1,   . - tabnombre
.equ NBTABNOMBRE,   NBTABNOMBRE1 / 4

/*******************************************/ 
/* DONNEES NON INITIALISEES                    */
/*******************************************/ 
.bss
sZoneConv:        .skip 24
sZoneConvBin:     .skip 40
sBuffer:          .skip 80 
.align 2 
/************************************...-..--**/
/* SECTION CODE                              */
/**********************************************/
.text
.global main

main:                       # INFO: main
    call initDebut
    call initGpioLed
	li a0,2
	#call ledEclats
	
	call initHorloges       # lancement des horloges
	li a0,2
	#call ledEclats
	call initUsbDevice      # initialisation connexion usb
	li a0,2
	call ledEclats
	
    la t0,iConfigured       # top connexion
1:                          # boucle attente connexion putty com4
    lw t1,(t0)
    beqz t1,1b
	
	la a0,szMessDemStd
    call envoyerMessage     # envoi message à l'hote par connexion usb
    
2:
 
    la a0,szMessCmd
    call envoyerMessage
    la a0,sBuffer            # buffer reception message
    call recevoirMessage
    la a0,sBuffer
    la a1,szLibCmdAff        # INFO: commande aff
    call comparerChaines
    bne a0,x0,3f
	
	afficherLib  "Effacement d'un bit"
	li s0,0b1100             # mise à 1 des bits 2 et 3 
	bclri a0,s0,2            # position donnée par une valeur immediate
	la a1,sZoneConvBin
	call conversion2         # conversion binaire
	la a0,sZoneConvBin
	call envoyerMessage      # et affichage
	la a0,szCarriageReturn
	call envoyerMessage      # pour le retour ligne
	
	afficherLib  "Maj d'un bit"
	li s0,0b01100
	bseti a0,s0,4            # position donnée par une valeur immediate
	la a1,sZoneConvBin
	call conversion2
	la a0,sZoneConvBin
	call envoyerMessage
	la a0,szCarriageReturn
	call envoyerMessage	
	
	afficherLib  "Extraction d'un bit"
	li s0,0b01100
	li t0,3
	bext a0,s0,t0            # position donnée par le registre t0
	la a1,sZoneConvBin
	call conversion2
	la a0,sZoneConvBin
	call envoyerMessage
	la a0,szCarriageReturn
	call envoyerMessage
	
    afficherLib  "Inversion d'un bit"
	li s0,0b01100
	li t0,3
	binv a0,s0,t0            # position donnée par le registre t0
	la a1,sZoneConvBin
	call conversion2
	la a0,sZoneConvBin
	call envoyerMessage
	la a0,szCarriageReturn
	call envoyerMessage
	
	
	j 20f
3:  
    la a0,sBuffer
    la a1,szLibCmdFin        # INFO: commande fin
    call comparerChaines
    bne a0,x0,4f
    call resetUsbBootrom
	j 20f
4:                            # autres commandes   
    la a0,sBuffer
    la a1,szLibCmdTab        # INFO: commande tab
    call comparerChaines
    bne a0,x0,7f
	afficherLib "affichage elements table  1"
    la s0,tabnombre          # adresse du tableau
	li s1,0                  # indice n
	li s2,NBTABNOMBRE        # taille du tableau
5:
    slli t0,s1,2             # calcul deplacement n * 4
	add t0,t0,s0             # calcul adresse element n
	lw a0,(t0)               # charge valeur element n
	la a1,sZoneConv
	call conversion16        # conversion hexa
	la a0,sZoneConv
	call envoyerMessage      # et affichage
	la a0,szCarriageReturn
	call envoyerMessage	
	addi s1,s1,1             # incremente indice
	blt s1,s2,5b             # fin ? sinon boucle
	# idem mais utilisation de l'instruction sh2add pour calculer l'adresse
	afficherLib "affichage elements table  2"
    la s0,tabnombre
	li s1,0
	li s2,NBTABNOMBRE
6:
	sh2add t0,s1,s0           #  calcul adresse
	lw a0,(t0)
	la a1,sZoneConv
	call conversion16
	la a0,sZoneConv
	call envoyerMessage
	la a0,szCarriageReturn
	call envoyerMessage	
	addi s1,s1,1
	blt s1,s2,6b
	
	j 20f
7:                            # autres commandes 
    la a0,sBuffer
    la a1,szLibCmdAide        # INFO: commande Aide
    call comparerChaines
    bne a0,x0,8f
	afficherLib "Liste des commandes"
    la a0,szLibListeCom          # adresse liste 
	call envoyerMessage	
	
	j 20f
8:                           # autres commandes

   
15:                           # affichage commande inconnue
	la a0,sBuffer
	call envoyerMessage
20:
    j 2b                      # boucle commande


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

1:                           # boucle de copie de la data en ram
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
/*      binary  conversion          */
/***********************************/
/* a0 value   */
/* a1 result area address */
/*       size mini 33 character */
conversion2:                # INFO: conversion2
    addi    sp, sp, -8      # save registres
    sw      ra, 0(sp)
    li t2,0
    li t1,0    
1: 
    slt t3,a0,x0           # if negative  bit 31 is 1 

    slli a0,a0,1           # shift left one bit
    add t0,a1,t1           # compute indice to store char in area
    addi t3,t3,'0'         # conversion byte to ascii char
    sb t3,(t0)             # store char in area
    addi t1,t1,1           # next position
    li t0,7                # for add a space separation
    beq t2,t0,4f
    li t0,15               # for add a space 
    beq t2,t0,4f
    li t0,23               # for add a space 
    beq t2,t0,4f
    j 5f
    
4:                         # store space  
    li t3,' '
    add t0,a1,t1
    sb t3,(t0)
    addi t1,t1,1
5:
    addi t2,t2,1           # increment bit indice 
    li t0,32               # maxi ?
    blt t2,t0,1b           # and loop
    
    add t0,a1,t1
    sb x0,(t0)             # final zero
100:    
    lw      ra, 0(sp)
    addi    sp, sp, 8
    ret 
	