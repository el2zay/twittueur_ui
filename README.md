# App Twittueur

> Ceci est un projet de NSI.

Ce repo contient le code source de l'application mobile Twittueur.

## Installation

<b>Il est conseillé de télécharger un des fichier APK (android) ou IPA (iOS) dans la section [releases](https://github.com/el2zay/twittueur_ui/releases) sur votre téléphone.</b>
___

1. Clonez le repo

`git clone https://github.com/el2zay/twittueur_ui.git` 

2. [Installez Flutter](https://flutter.dev/docs/get-started/install)

#### Sur un émulateur Android

3. [Installez Android Studio](https://developer.android.com/studio) et créez un émulateur.

4. Ouvrez le projet dans Android Studio et lancez l'émulateur.

### Sur un téléphone physique
3. Activez le mode développeur sur votre téléphone. (L'emplacement de ce paramètre dépend de l'OS de votre téléphone)
4. Connectez votre téléphone à votre ordinateur.
5. Dans un terminal exécutez la commande 

`flutter run -d <appareil>`.

## Arborescence
- `lib/` contient le code source de l'application (c'est le dossier le plus intéressant)
- `android/` contient les fichiers pour android
- `ios/` contient les fichiers pour iOS
- `pubspec.yaml` contient quelques informations et les dépendances du projet

## Fonctionnalités
- [x] Poster jusqu'à 1000 caractères
- [x] Liker un post (aussi en double-tap)
- [x] Enregistrer un post (aussi en long-tap)
- [x] Commenter un post
- [x] Avoir une photo de profil
- [x] Se connecter à l'aide d'une passphrase
- [x] Compatible iOS et Android