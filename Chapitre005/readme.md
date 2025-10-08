## Chapitre 5

Nous allons continuer à jouer avec la led. Nous allons la faire clignoter indéfiniment mais nous allons modifier sa fréquence par l’intermédiaire du 2ieme cœur hazard3.

Nous écrivons une fonction de clignotement de la led clignoterLed dans laquelle nous récupérons le délai d’attente entre chaque éclair dans la variable iDelaiLed déclarée dans la .data avec la valeur 500. Le clignotement de départ sera donc lent.

Puis nous écrivons une routine qui sera exécutée par le core 1 : execCore1 dans laquelle nous attendons quelques secondes pour voir le clignotement lent de la led puis nous mettons à jour la variable iDelailed avec la valeur 150 ce qui fera clignoter la led rapidement. Puis le cœur ne faisant plus rien, nous le maintenons en vie avec une boucle.

Ensuite il nous faut écrire la fonction d’initialisation du core1 et j’ai ajouté les fonctions de communication entre les cœurs par l’intermédiaire des files FIFO mais elles resteront inutilisés ici.

La fonction d’initialisation est assez complexe et je l’ai réécrite à partir de celle fournie par le SDK.

En gros, le cœur 0 envoie une séquence de données au cœur 1 pour le réveiller. Il lui transmet surtout l’adresse de la pile qui lui est réservée et l’adresse de la fonction a exécuter donc l’adresse de execCore1.

Il ne nous reste plus dans la fonction main d’appeler les fonctions d’initialisation déjà vues puis d’appeler la fonction d’initialisation du core1 en lui passant l’adresse de la fonction à exécuter dans le registre a0 puis nous lançons le clignotement de la led qui ne se terminera pas !!

La compilation s’effectue avec make et l’exécution montre le clignotement lent de la Led pendant quelques secondes puis son accélération.
