## Chapitre7.

Nous allons tester quelques instructions riscv et utiliser une macro pour afficher des libellés.

Par exemple l’instruction bclri a0,t1,2  qui met dans a0 la valeur du registre t1 après avoir mis à zéro le bit 2.
Mais cela entraîne une erreur de compilation : Error: unrecognized opcode `bclri a0,t1,2', extension `zbs' required

En riscv, certaines instructions ne sont disponibles qu’avec des options à préciser lors de la compilation comme ceci :
AOPS =   -mabi=ilp32 -march=rv32i_m_zbs_zicsr_f_zba_zbb

Nous testons les instructions pour mettre à jour un bit, extraire un bit et inverser un bit.

Nous avons crée un tableau de 4 nombres dans le .data tabnombre, et nous allons effectuer une boucle pour afficher les 4 nombres d’abord en utilisant une méthode classique pour calculer l’adresse de chaque élément (calcul du déplacement en multipliant le rang par 4 car les nombres sont des int sur 4 octets puis ajout à l’adresse de la table). 

Puis dans une deuxième boucle, utilisation de l’instruction sh2add qui effectue directement le calcul de l’adresse.

Pour afficher le titre de chaque test, nous utilisons une macro que nous appelons comme ceci :
afficherLib test   ou afficherLib "extraction d’un bit" s'il y a des espaces dans le libellé.

Les instructions de construction de la macro sont identiques à celles pour l’assembleur ARM.
Nous nous contentons de sauver les registres , de stocker la chaîne de caractères et d’appeler la routine d’affichage puis de restaurer les registres. 

La sauvegarde des registres permet d’appeler cette macro n’importe où dans le code.

Voici le résultat de l’exécution :
```
Demarrage normal riscv.

Entrez une commande (ou aide) : aide
Liste des commandes
aff
tab
fin

Entrez une commande (ou aide) : aff
Effacement d'un bit
00000000 00000000 00000000 00001000
Maj d'un bit
00000000 00000000 00000000 00011100
Extraction d'un bit
00000000 00000000 00000000 00000001
Inversion d'un bit
00000000 00000000 00000000 00000100

Entrez une commande (ou aide) : tab
affichage elements table  1
00000001
00000002
00000003
00000004
affichage elements table  2
00000001
00000002
00000003
00000004

Entrez une commande (ou aide) : fin
```

Maintenant à vous de jouer !! bon courage
