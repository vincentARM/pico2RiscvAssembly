# Chapitre 6.

Dans ce chapitre nous allons passer à des choses plus sérieuses que le clignotement de la led. Nous allons établir la communication par le câble USB avec un logiciel comme putty sur windows11 ce qui nous permettra d’envoyer des commandes au pico et d’afficher ses messages.

Il nous faut donc écrire tout le protocole client USB pour arriver à cela mais il nous faut aussi lancer les horloges nécessaires à ce protocole.

Ces premiers programmes en assembleur riscv sans le SDK, ne se sont pas préoccupés de la vitesse de fonctionnement des cœurs mais si vous avez déjà fait clignoter des leds, vous vous êtes aperçus que le délai d’attente est relativement court ! En effet, par défaut l’horloge démarrée par la partie rom a une fréquence de 12mhz et normalement l’UC est prévue pour tourner à 150mhz et le protocole USB est prévue pour 48mhz.

Pour cela, nous restructurons notre dernier programme, pour mettre dans un fichier externe les constantes utilisées : constantesPicoRisc.inc et pour mettre aussi les routines utilisées dans le fichier routinesRisc.s comme ledEclats, initGpioLed, attendre.

Dans ces routines, nous écrivons le lancement de l’oscillateur, l’initialisation du PLL système qui va multiplier la fréquence de l’oscillateur, le lancement de l’horloge système, l’initialisation du PLL usb et l’horloge usb.

Nous ajoutons aussi une routine pour réinitialiser le pico et le mettre à l’état bootsel qui permet de transférer un nouveau fichier uf2.

Enfin, nous ajoutons le fichier routinesusbrisc.s qui contient les routines de la connexion USB. J’ai écrit ces fonctionnalités à partir de celles que j’ai écrites en ARM assembleur, elles peuvent donc certainement être améliorées. (remarque : il y a des parties qui concernent le protocole xmodem et donc qui ne sont pas à utiliser ici).

Pour compiler tout cela il faut ajouter dans le makefile les instructions :
```
routinesRisc.o : ./routinesRisc.s ./constantesPicoRisc.inc
	$(ARMGNU)-as  $(AOPS) ./routinesRisc.s -o ./routinesRisc.o
    
routinesusbriscv.o : ./routinesusbriscv.s ./constantesPicoRisc.inc
	$(ARMGNU)-as  $(AOPS) ./routinesusbriscv.s -o ./routinesusbriscv.o
```

et ajouter les objets crées dans l’instruction du  linker.

Il reste à préparer le programme principal en ajoutant l’initialisation des horloges avec

call initHorloges

l’initialisation de la connexion USB :

call initUsbDevice

puis nous trouvons une boucle pour attendre la connexion et nous envoyons un message d’accueil dès que celle ci est établie.
Si la led clignote 10 fois c’est qu’il y a un problème !!!

Après nous attendons que l’utilisateur saisisse une commande parmi les 2 que j’ai programmé  aff qui affiche un simple message et fin qui appelle la routine resetUsbBootrom qui relance le pico.

Maintenant, il suffit soit de compléter la commande aff soit d’écrire d’autres commandes en s’inspirant de ces instructions.
