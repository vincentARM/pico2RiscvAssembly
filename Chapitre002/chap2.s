# programme pour tester l'assembleur riscv raspberry pico2
# uniquement assembleur riscv
# affichage message
/*********************************************/
/*           CONSTANTES                      */
/********************************************/

/*******************************************/
/* DONNEES INITIALISEES                    */
/*******************************************/ 
.data
szMessStart:         .asciz "Programme riscv start.\r\n"
szCarriageReturn:    .asciz "\n" 
 
.align 2
/*******************************************/ 
/* DONNEES NON INITIALISEES                    */
/*******************************************/ 
.bss
sZoneConv:       .skip   24
.align 2
/**********************************************/
/* SECTION CODE                              */
/**********************************************/
.text
.global main

main:                          # INFO: main
    call stdio_init_all        # init général
1:
    li a0,0                    # raz registre argument
    call tud_cdc_n_connected   # fonction attente de connexion usb
    bne a0,x0,2f               # compare code retour à zero
	j 1b

2:  
    la a0,szMessStart          # adresse message
	call afficherChaine
	
	mv a0,sp
	la a1,sZoneConv
	call conversion16
	la a0,sZoneConv          # adresse zone conversion
	call afficherChaine
	
	la a0,szCarriageReturn
	call afficherChaine
	
	li a0,5
	li t1,10
	mul a0,a0,t1
	la a1,sZoneConv
	call conversion16
	la a0,sZoneConv          # adresse zone conversion
	call afficherChaine
	
	la a0,szCarriageReturn
	call afficherChaine
	
	li a0,100
	li t1,20
	div a0,a0,t1
	la a1,sZoneConv
	call conversion16
	la a0,sZoneConv          # adresse zone conversion
	call afficherChaine

	la a0,szCarriageReturn
	call afficherChaine
	
	li t0,100
	li t1,20
	max a0,t0,t1
	la a1,sZoneConv
	call conversion16
	la a0,sZoneConv          # adresse zone conversion
	call afficherChaine


100:                           # boucle finale
    j 100b
/**********************************************/
/* afficher une chaine de caracteres                   */
/**********************************************/
/* a0    adresse chaine */
afficherChaine:                # INFO: conversion16
    addi    sp, sp, -12         # reserve pile
    sw      ra, 0(sp)          # Adresse de retour 	Appelant
    sw      s0, 4(sp)       
    sw      s1, 8(sp)	
	mv s0,a0                   # save adresse chaine
	li s1,0                    # raz indice
1:  
	add t0,s0,s1               # position caractere dans chaine
	lbu a0,(t0)                # charge le caractere
	beqz a0,100f               # si zero final -> fin
	call putchar               # affichage caractère
	addi s1,s1,1               # incremente indice
	j 1b   	
	
100:
    lw      ra, 0(sp)         # restaur registre
    lw      s0, 4(sp)  
    lw      s1, 8(sp)
    addi    sp, sp, 12        # liberer pile
    ret	
	
/**********************************************/
/* conversion hexadecimale                    */
/**********************************************/
/* a0    nombre a convertir */
/* a1    adresse zone de conversion */
/* registres t0 t1 t2 non sauvegardés */
.equ LGZONECONV,   20
conversion16:              # INFO: conversion16
    addi    sp, sp, -8     # reserve pile
    sw      ra, 0(sp)      # Adresse de retour 	Appelant
    sw      s0, 4(sp)  
    li t0,28               # start bit position
    li t1,0xF0000000       # mask
    mv t2,a0               # save entry value
1:                         # start loop
    and a0,t2,t1           # value register and mask
    srl a0,a0,t0           # shift right 
    li s0,10               # move 10
    blt a0,s0,2f           # compare value
    addi a0,a0,55          # letters A-F
    j 3f
2:
    addi a0,a0,48          # number
3:
    
    sb a0,(a1)             # store digit on area and + 1 in area address
    addi a1,a1,1
    srli t1,t1,4           # shift mask 4 positions
    addi t0,t0,-4          #  counter bits - 4 <= zero  ?
    bge t0,x0,1b           #  no -> loop
    sb x0,(a1)             # store final zero
    li a0,8                # return size 
    
100:
    lw      ra, 0(sp)      # restaur registre
    lw      s0, 4(sp)
    addi    sp, sp, 8      # liberer pile
    ret

    

 