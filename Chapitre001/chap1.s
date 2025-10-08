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
szMessStart:         .asciz "Bonjour le monde en riscv"
szCarriageReturn:    .asciz "\n"  

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
    call stdio_init_all        # init général
1:
    li a0,0                    # raz registre argument
    call tud_cdc_n_connected   # fonction attente de connexion usb
    bne a0,x0,2f               # compare code retour à  zero
    j 1b                       # et boucle
2:  
    la s0,szMessStart          # adresse message
	li s1,0                    # raz indice
3:	
	add t0,s0,s1               # position caractere
	lbu a0,(t0)                # charge le caractere
	beq a0,x0,100f             # si zero final -> fin
	call putchar               # affichage caractère
	addi s1,s1,1               # incremente indice
	j 3b                       # et boucle

100:                           # boucle finale
    j 100b


    


 
