// ignore_for_file: use_build_context_synchronously

import 'package:twittueur/pages/login.dart';
import 'package:twittueur/pages/register.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FirstPage extends StatefulWidget {
  const FirstPage({super.key});

  @override
  State<FirstPage> createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  @override
  void didChangeDependencies() { // Fonction qui se déclenche lorsque l'état de l'application change
    super.didChangeDependencies();
    // Cela nous permet de vérifier si l'utilisateur est sur un appareil mobile ou non.
    var shortestSide = MediaQuery.of(context).size.shortestSide;
    final bool useMobileLayout = shortestSide < 550;
    if (useMobileLayout) {
      // Si c'est le cas alors on bloque l'orientation en mode portrait.
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Mettre une couleur personnalisée en fond, comme une couleur dégradée
        decoration: BoxDecoration(
            gradient: LinearGradient(
          // Dégradé linéaire
          begin: Alignment.topRight, // Qui commence de en haut à droite
          end: Alignment.bottomLeft, // Jusqu'à en bas à gauche
          colors: [
            Colors.blue[900]!,
            Colors.black
          ], // Avec les couleurs bleu[900] et noir
        )),
        child: Center(
          // Centrer le tout
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center, // Centrer verticalement
            children: [
              Image.asset(
                'assets/logo.png', // Afficher le logo
                width: MediaQuery.of(context).size.width *
                    0.25, // Taille Responsive
              ),
              SizedBox(
                  height: MediaQuery.of(context).size.height *
                      0.1), // Espacement responsive
              const Text(
                // Texte de bienvenue
                "Bienvenue sur Twittueur !",
                style: TextStyle(
                    fontSize: 27,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const Text(
                "Merci d'avoir télécharger l'application !",
                style: TextStyle(fontSize: 12, color: Colors.white),
              ),
              const SizedBox(height: 70),
              ElevatedButton(
                // Bouton pour s'inscrire
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            const RegisterPage()), // Qui redirige vers la page d'inscription
                  );
                },
                style: ElevatedButton.styleFrom(
                    // Style du bouton
                    backgroundColor: Colors.indigo[800], // Couleur bleu indigo
                    shape: RoundedRectangleBorder(
                      // Forme du bouton
                      borderRadius: BorderRadius.circular(
                          32.0), // Rectangle arrondi à 32°
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 115)), // Longueur du bouton
                child: const Text(
                  "S'INSCRIRE", // Label du bouton
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 35),
              ElevatedButton(
                // Bouton pour se connecter
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            const LoginPage()), // Qui redirige vers la page de connexion
                  );
                },
                style: ElevatedButton.styleFrom(
                    // Style du bouton
                    backgroundColor: Colors.grey[900], // Couleur grise
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          32.0), // Rectangle arrondi à 32°
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 100)), // Longueur du bouton
                child: const Text(
                  "SE CONNECTER", // Label du bouton
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
