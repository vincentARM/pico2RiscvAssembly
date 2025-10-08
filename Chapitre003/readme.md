## Chapitre 3 
L’utilisation du SDK facilite beaucoup la programmation en assembleur riscv mais nous allons voir maintenant la programmation sans faire appel aux fonctions du SDK.
Pour commencer, nous allons faire clignoter la led intégrée car cela ne nécessite pas de connexion USB.


Dans le programme, nous commençons par définir les constantes GPIO nécessaires.

A la fin de la section principale, nous définissons un bloc de données obligatoire qui indique que le fichier uf2 est un fichier riscv, l’adresse de la pile et l’adresse de l’instruction qui doit être exécutée en premier. 

Ce bloc doit être placé dans les 4096 premiers caractères de la section .text 
(voir le chapitre 5.9 et 5.9.5. Minimum viable image metadata de la datasheet).

Dans le programme principal, nous trouvons 2 appels à la fonction d’initialisation du GPIO led et la fonction qui allume et éteint la LED.

Maintenant il faut compiler le programme sans le SDK. Pour cela nous créons un fichier memmap.ld qui va préciser au linker les régions de la mémoire et un fichier makefile qui va lancer le compilateur puis le linker puis picotool qui va créer le fichier uf2.

Voici son contenu :
```
ARMGNU ?= "C:\PrincipalA\Outils\tools\bin\riscv32-unknown-elf"

AOPS =   -mabi=ilp32

all : chap3.uf2

chap3.uf2: chap3.elf
	C:\PrincipalA\Outils\picotool uf2 convert chap3.elf chap3.uf2 --abs-block 0x10010000 --family 0xE48BFF57 --offset 0x10000000
    
chap3.o : chap3.s 
	$(ARMGNU)-as  $(AOPS) chap3.s -o chap3.o
    
    
chap3.elf : chap3.o  
	$(ARMGNU)-ld  -T memmap.ld  chap3.o -o chap3.elf  -M >chap3_map.txt
	$(ARMGNU)-objdump -D chap3.elf > chap3.list
```

Pour récupérer l’exécutable picotool, il suffit d’aller dans le répertoire build d’un programme précédent compilé avec le SDK, sous le répertoire \_deps\picotool et copier le picotool.exe.

Il faut modifier les chemins des exécutables as, ld et picotool avec vos propres chemins. 

Vous remarquerez que notre programme est chargé à l’adresse 0x10000000.

La compilation est lancée avec make (si vous ne l’avez pas, il faut le  télécharger depuis internet).

Après correction des erreurs éventuelles, il suffit de copier le fichier uf2 sur le pico2 pour voir la led lancer 5 éclairs.
