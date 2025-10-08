
# Programmation risc-v sur le pico2 rp2350

## Introduction.
Le pico 2 possédé 2 cœurs hazard3 qui peuvent être programmé en langage assembleur risc-v. Ce répertoire est le récit de mon expérience de la découverte de ce langage tout d’abord en utilisant le SDK C++ puis ensuite en développant directement en assembleur sans le SDK.

Vous trouverez donc ici tous les programmes que je décris dans ce récit. Pour les compiler, je donne toutes les ressources nécessaires au fil des chapitres.

Attention, je ne suis pas un professionnel de ce langage et donc j’ai pu commettre des erreurs ou être imprécis dans la description de ce langage. D’autre part, j’ai fait cela pour mes loisirs et ces programmes ne sont pas optimisés pour une utilisation professionnelle. De plus j’utilise windows11 pour la compilation et donc il peut avoir des différences sur les systèmes Linux.

Je vous conseille de télécharger sur le site de raspberry pi la datasheet du rp2350 et si vous n’avez jamais utilisé un pico toute la documentation sur le SDK C++.

Vous trouverez aussi sur internet, la documentation sur les cœurs hazard3 et des descriptions et des cours sur le risc-v mais déjà vous pouvez consulter la description des instructions du cœur hazard3 du pico au chapitre 3.8  de la datasheet. (la liste des instructions risc-v est à la page 237).

[Chapitre1: ](https://github.com/vincentARM/pico2RiscvAssembly/tree/main/Chapitre001)    Affichage message avec le SDK.

[Chapitre2: ](https://github.com/vincentARM/pico2RiscvAssembly/tree/main/Chapitre002)    Routines conversion hexadécimal
