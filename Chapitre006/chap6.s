# programme pour tester l'assembleur riscv raspberry pico2
# uniquement assembleur riscv
# clignotement led utilisation multicoeur
/*********************************************/
/*           CONSTANTES                      */
/********************************************/
.include "./constantesPicoRisc.inc"
.equ ADRESSEPILE,     0x20082000

/*******************************************/
/* DONNEES INITIALISEES                    */
/*******************************************/ 
.data
szMessDemStd:      .asciz "Demarrage normal riscv.\r\n"
szMessCmd:         .asciz "\r\nEntrez une commande (ou aide) : "
szCarriageReturn:  .asciz "\r\n"
szLibCmdAff:       .asciz "aff"
szLibCmdFin:       .asciz "fin"
szLibCommOK:       .asciz "Commande OK."
.align 2

/*******************************************/ 
/* DONNEES NON INITIALISEES                    */
/*******************************************/ 
.bss
sBuffer:          .skip 80 
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
    la a1,szLibCmdAff        # commande aff
    call comparerChaines
    bne a0,x0,3f
	la a0,szLibCommOK
	call envoyerMessage
	j 20f
3:  
    la a0,sBuffer
    la a1,szLibCmdFin        # commande fin
    call comparerChaines
    bne a0,x0,4f
    call resetUsbBootrom
	j 20f
4:                            # autres commandes   

   
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

	