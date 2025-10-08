## Chapitre 1 : 

Dans ce chapitre, nous allons créer un premier programme pour simplement afficher une chaîne de caractère. L’affichage s’effectuera par le port USB en établissant une connexion avec le logiciel putty sous windows11.
Pour l'instant, nous utiliserons le SDK pour compiler linker, et créer le fichier uf2 à charger sur le pico2.
Le programme source peut être écrit ou modifier avec n’importe quel éditeur (comme notepad++) voir le programme chap1.s. L’extension .s est identique à l’assembleur arm.

Le programme commence par des commentaires signalés soit par des # soit par /*   */ si plusieurs lignes. Le symbole @ et le symbole // ne sont pas acceptés comme commentaires.

Ensuite nous trouvons la .data et la description des variables avec leur valeurs. La syntaxe est identique à l’assembleur Arm.
Puis nous avons la .bss inutilisée ici, la section .text comme pour l’assembleur arm.

Dans la fonction main (déclarée global) nous commençons par appeler la fonction d’initialisation du sdk stdio_init_all en utilisant la pseudo instruction call. Celle ci remplace en fait l’instruction : jal (jump address ) saute à l’adresse et sauve l’adresse de retour dans le registre ra).
Ensuite l’instruction li a0,0 (load immediat) initialise le registre a0 à zéro. Les registres a0 à a7 sont réservés au passage des paramètres aux fonctions et ne sont pas sauvegardés dans ces fonctions.
(voir les noms des registres et leur utilisation dans la documentation risc-v ou dans la datasheet : 3.8.1.3.1. Register conventions).

Puis nous appelons la fonction du sdk tud_cdc_n_connected qui teste si une connexion usb est établie et retourne dans le registre a0 le code retour. Nous testons si ce code est égal à zéro et nous bouclons sur l’appel de la fonction tant qu’une connexion n’est pas établie.

Vous remarquerez la particularité en risc-v du registre x0 qui est toujours égal à 0. L’instruction bne a0,x0,2f peut être simplifiée en bnez a0,2f.

Puis nous chargeons l’adresse du message dans le registre s0 avec l’instruction  la s0,szMessStart (load address) et initialisons l’indice de balayage des caractères à 0.

La boucle suivante extrait un caractère de la chaîne et appelle la fonction putchar pour l’envoyer à la connexion usb. La boucle s’arrête quand le caractère de fin de chaîne 0 est chargé.

Vous remarquerez plusieurs différences par rapport à l’assembleur arm pour lire un caractère de la mémoire. Tout d’abord il faut calculer l’adresse du caractère en additionnant l’adresse de début de chaîne et l’indice car les instructions d’accès à la mémoire n’admettent pas l’utilisation de plusieurs registres (base et déplacement). En fait elles n’admettent que des valeurs immédiates comme ceci : lbu a0,5(s0)  qui lit le 5ieme caractères de la chaîne.
Lbu pour Load Byte Unsigned qui charge un seul octet. Attention à l’utilisation de lb qui charge un octet mais qui complète les autres bits du registre avec des 1 ce qui peut poser des problèmes lors de tests ultérieurs.

Pour charger 2 octets, il existe l’instruction lh (load half word) et pour charger 4 octets l’instruction lw (load word).

Nous augmentons l’indice de 1 et nous bouclons pour charger un autre caractère. La aussi vous remarquerez la différence entre les 2 instructions d’addition . Le add additionne 2 registres alors que le addi additionne une valeur immédiate avec un registre.

Le programme se termine par une boucle sans fin car on ne fait plus rien ici.

Pour compiler et créer le fichier uf2, nous devons créer un fichier CmakeLists.txt qui est semblable aux fichiers habituels pour l’assembleur ARM ou le C.

Il faut ajouter dans le répertoire le fichier pico_sdk_import.make et créer un répertoire build.

La compilation se lance par :
```
cmake   -DPICO_PLATFORM=rp2350-riscv -DPICO_TOOLCHAIN_PATH=C:\PrincipalA\Outils\tools\bin  -G "NMake Makefiles" .. 
```

puis par nmake.

On précise la plateforme et le langage avec la directive : -DPICO_PLATFORM=rp2350-riscv.

Le chemin d’un répertoire est aussi ajouté pour indiquer le compilateur risc-v à utiliser car le SDK ne fournit pas ce compilateur ni les librairies associées. Celui ci est à récupérer ici :
https://github.com/raspberrypi/pico-sdk-tools/releases/download/v2.0.0-2/riscv-toolchain-14-x64-win.zip

Le programme source, le  fichier CmakeLists.txt sont dans ce repertoire, il suffit de les copier dans votre propre répertoire.
N’oubliez pas de créer le build et de vous y positionner pour compiler.
