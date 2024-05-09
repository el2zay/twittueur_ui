import 'package:flutter/material.dart';
import 'package:twittueur/main.dart';
import 'package:twittueur/src/utils/requests_utils.dart';
import 'package:twittueur/src/widgets/common_widgets.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passphraseController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          "assets/logo.png",
          width: 30,
          height: 30,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (_formKey.currentState?.validate() == false) {
            // Tant que le formulaire n'est pas valide on ne fait rien
            return;
          }
          showDialog(
            // On affiche un loader dans un dialog
            context: context,
            barrierDismissible: false,
            builder: (context) => Center(
              child: loader(),
            ),
          );
          await login(
              // Executer la fonction login
              context,
              _usernameController.text,
              _passphraseController.text);
          setState(() async {
            user = (await fetchUser()) ??
                {}; // Changer la valeur de la variable user user
          });
        },
        // Tant que le nom d'utilisateur n'a pas 4 caractères ou que la passphrase n'a pas 20 mots
        backgroundColor: _usernameController.text.length < 4 ||
                _passphraseController.text.split(" ").length != 20
            ? Colors.white70 // On grise le bouton (70 = 70% d'opacité)
            : Colors.white,
        foregroundColor:
            const Color.fromARGB(255, 80, 66, 66), // Couleur de l'icone
        child: const Icon(Icons.arrow_forward_ios), // Icone du bouton
      ),
      body: SingleChildScrollView(
        // Rendre la page scrollable
        child: Padding(
          // Marges
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 35),
          child: Column(
            children: [
              const Text("Connectez-vous.",
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
              const SizedBox(height: 40),
              Form(
                key: _formKey, // Clé du formulaire pour vérifier sa validité
                child: Column(
                  children: [
                    TextFormField(
                      controller: _usernameController, // Contrôleur du champ
                      validator: (value) {
                        // Les vérifications à effectuer
                        if (value!.isEmpty) {
                          return 'Ce champ ne peut pas être vide';
                        } else if (value.length < 4) {
                          return 'Le nom d\'utilisateur doit contenir au moins 4 caractères.';
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                        // Le style du champ
                        hintText: "Entrez votre nom d'utilisateur",
                        hintStyle: TextStyle(color: Colors.grey),
                        contentPadding: EdgeInsets.all(20), // Marge intérieure
                      ),
                      autocorrect:
                          false, // Désactiver la correction automatique
                      onChanged: (value) => setState(
                          () {}), // Actualiser la page à chaque changement
                    ),
                    const SizedBox(height: 30),
                    TextFormField(
                      controller: _passphraseController, // Contrôleur du champ
                      validator: (value) {
                        // Les vérifications à effectuer
                        if (value!.isEmpty) {
                          // Les vérifications a effectuer
                          return 'Ce champ ne peut pas être vide';
                        } else if (value.split(" ").length != 20) {
                          return 'La passphrase doit contenir 20 mots.';
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                        // Le style du champ
                        hintText: "Entrez votre passphrase",
                        hintStyle: TextStyle(color: Colors.grey),
                        contentPadding: EdgeInsets.all(20), // Marge intérieure
                      ),
                      cursorColor: Colors.blue, // Couleur du curseur
                      onChanged: (value) => setState(
                          () {}), // Actualiser la page à chaque changement
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
