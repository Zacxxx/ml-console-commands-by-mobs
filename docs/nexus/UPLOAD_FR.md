# Déposer ML Console Commands by Mobs sur Nexus

Ce dossier prépare une **première publication alpha 0.14.0-alpha.1**, ciblant Manor
Lords 0.8.117. Les fichiers sont prêts à sélectionner dans le formulaire. Aucune
page Nexus n'a été créée et aucun fichier n'a été envoyé par cet outil.

## Fichiers et champs

- Jeu : **Manor Lords**.
- Nom du mod : **ML Console Commands by Mobs**.
- Auteur affiché : **Mobs** ; le compte qui publie reste ton compte Nexus connecté.
- Version : **0.14.0-alpha.1**.
- Catégorie : celle indiquée dans FIELDS.json ; ne pas choisir une catégorie d'assets graphiques.
- Résumé : copier SUMMARY.txt.
- Description : copier DESCRIPTION_BBCODE.txt en mode BBCode, ou DESCRIPTION.md en texte.
- Fichier principal : ZIP se terminant par **-Nexus.zip**, catégorie Main Files.
- Sources : ZIP se terminant par **-Source.zip**, catégorie Miscellaneous/Optional Files,
  description « Source code — not required to play ».
- Journal de version : copier CHANGELOG.md (retirer les # si l'éditeur ne les gère pas).
- Image : images/cover-1600x900.png. C'est une couverture promotionnelle, pas une capture du jeu.
- Lien sources : https://github.com/Zacxxx/ml-console-commands-by-mobs ; il est
  déjà inséré dans la description préparée. Les téléchargements GitHub sont liés aussi.
- Permissions : suivre PERMISSIONS.txt et la licence MIT jointe.
- Dépendances : une installation UE4SS 3.0.1 fonctionnant avec 0.8.117, et
  ConsoleEnablerMod activé/configuré. Lien de référencement :
  https://www.nexusmods.com/manorlords/mods/229 ; sa compatibilité affichée peut
  être différente. Ne pas promettre que son fichier actuel convient à 0.8.117.

## Tags et transparence

Prévoir **AI-Generated Content** pour le code généré et **AI Media** pour le texte
et la couverture promotionnelle. Ces choix correspondent au travail réalisé ici ;
ne pas remplacer par « AI Assisted » en sous-estimant la part de génération.
La description inclut cette transparence. Sélectionner aussi les tags de gameplay/
cheat pertinents proposés par le formulaire, sans ajouter de tags sans rapport.

Référence vérifiée le 3 novembre 2026 :
https://help.nexusmods.com/article/28-file-submission-guidelines
Les règles de cette page indiquent une évolution au 2 janvier 2027 : les relire
si la publication est reportée jusque-là.

## Avant de rendre la page publique

Le kit ne présente pas la version comme « stable » ou « sans crash ». Les confirmations
utilisateur concernent surtout construction, piles et perks ; les variantes récentes
et l'autocomplétion ont encore des limites de vérification en jeu. Elles sont décrites
dans KNOWN_ISSUES.md et dans la page proposée.

Il reste à obtenir des captures en jeu de cette version si tu souhaites les ajouter.
Ne pas utiliser d'anciennes captures d'erreurs comme démonstration des fonctions,
ni faire passer la couverture fournie pour une capture. Les images ne contiennent
aucun logo, asset ni capture de jeu réutilisé.

Vérifie la prévisualisation de la page et les dépendances, puis publie depuis ton
compte lorsque tu es satisfait. Les choix de dons, récompenses et participation aux
programmes Nexus ne sont pas préremplis par ce kit.

## Ce que contient le ZIP principal

Un seul dossier MLConsoleCommandsByMobs à extraire dans
ManorLords/Binaries/Win64/ue4ss/Mods. Il contient Scripts, les cinq DLL natives
actuellement sélectionnées et leurs manifestes, Commands/example.txt, enabled.txt,
la licence et le guide utilisateur. Il ne contient ni sauvegarde, état de perks,
logs, anciens DLL, ancien mod original, dépendance UE4SS ou recherche privée.

CHECKSUMS.sha256 permet de comparer les archives et les textes préparés.
RELEASE_REPORT.json détaille les contenus et la portée des vérifications ; c'est
un document local de préparation, pas une preuve de validation intégrale en jeu.
