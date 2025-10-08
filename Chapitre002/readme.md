## Chapitre 2
Nous complétons notre premier programme en écrivant une routine qui affichera une chaîne de caractères et une routine qui convertira la valeur d’un registre en caractères hexadécimaux qui seront ensuite affichés.

Après l’initialisation et l’attente de la connexion, nous passons l’adresse de la chaîne d’accueil dans le registre a0 pour appeler la fonction afficherChaine.
Dans celle ci nous commençons par réserver 12 caractères sur la pile par l’instruction 
addi    sp, sp, -12
En fait il s’agit d’une soustraction car le langage ne dispose pas d’une instruction de soustraction de valeur immédiate. Donc pour les petites valeurs il faut additionner un nombre négatif. Pour les grandes valeurs, il faut mettre la valeur dans un registre et effectuer la soustraction par sub r2,r0,r1.

Ensuite nous sauvegardons les 3 registres ra,s0,et s1 sur la pile ce qui nécessite 12 octets.

L’instruction de stockage en mémoire est sw ra,4(sp) qui stocke un mot de 4 octets. Il existe sb pour stocker un octet et sh pour stocker 2 octets.

Le registre sp contient l’adresse de la pile et ici elle est initialisée par le SDK.

Le registre ra contient l’adresse de retour à la fonction appelante et il faut donc la sauvegarde si on appelle une autre fonction et c’est le cas ici. 

Personnellement,  je sauvegarde ce registre dans toutes mes fonctions car je peux ajouter une autre fonction ultérieurement sans problème.

Les registres s0 et s1 sont sauvegardés car ils sont utilisés dans la fonction et suivant la norme préconisée ils doivent être sauvegardés.

On trouve ensuite les instructions vues dans le chapitre 1 pour afficher les caractères. Nous utilisons les registres s0 et s1 car les autres registres peuvent être écrasés par l’appel à la fonction externe putchar.

Ceci est très important, car il vous fera veiller à bien utiliser les registres s0 à s11 lors d’un appel à une fonction externe pour conserver vos propres valeurs.

En fin de fonction, on remet les valeurs des 3 registres à partir de celles de la pile et on remet le pointeur de pile à son état initial.

Pour vérifier l’adresse de la pile, nous passons le pointeur de pile sp dans le registre a0 pour le convertir en hexadécimal par la fonction conversion16. Nous passons dans le registre a1, l’adresse de la zone qui contiendra le résultat de la conversion.

Dans la fonction conversion16, après la sauvegarde des registres ra et s0, nous trouvons un algorithme simple de conversion (les commentaires sont en anglais car c’est mieux pour certains sites par exemple rosetta code).

On y trouve une instruction and classique et les instructions srl et srli qui effectue un décalage à droite des bits d’un registre. Le décalage est donné soit par un registre (srl a0,a0,t0 ) soit par une valeur immédiate (srli t1,t1,4).

Cette fonction va nous servir à tester d’autres instructions risc-v.

La fonction alimente la zone sZoneConv et dans le programme principal, nous passons cette adresse à la fonction d’affichage.
L’adresse affichée lors de l’exécution est 0x20082000 ce qui est bien l’adresse du fond de la pile.

Ensuite nous testons la multiplication, la division et l’instruction max qui donne le maximum de 2 registres.
Je vous laisse le soin de découvrir maintenant les autres instructions risc-v.

