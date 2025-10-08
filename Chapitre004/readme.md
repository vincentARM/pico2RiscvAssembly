## Chapitre 4.

Nous recopions le programme précédent et nous effectuons une petite modification. Au lieu de charger le registre a0 avec une valeur immédiate, nous déclarons le nombre d’éclairs dans une variable de la .data et nous alimentons le registre a0 comme ceci :
```
	la t0,nbEclairs
	lw a0,(t0)
	call ledEclats
```

La compilation est correcte mais l’exécution ne donne pas le résultat attendu ! 

Et oui, maintenant à chaque fois, il faut penser que nous ne passons plus par les fonctions du SDK et que c’est à notre programme d’effectuer les initialisations nécessaires.
Maintenant, le programme est chargé dans la mémoire flash et donc la  .data aussi. Mais pour pouvoir être modifiées éventuellement les données de la .data doivent être recopiées dans la ram dès le début de l’exécution du programme.

Nous ajoutons donc une routine de copie à partir des informations données par le fichier memmap.ld.

Nous en profitons aussi pour initialiser avec des 0 binaires la section .bss.
