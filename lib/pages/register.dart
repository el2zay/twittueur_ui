import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:twittueur/main.dart';
import 'package:twittueur/src/utils/requests_utils.dart';
import 'package:twittueur/src/widgets/common_widgets.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<
      FormState>(); // Cette variable nous servira à vérifier si le formulair a bien été rempli
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  File? _profileImage;

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

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
        onPressed: () {
          if (_formKey.currentState?.validate() == false) {
            return;
          }
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => Center(
              child: loader(),
            ),
          );
          register(
            context,
            _firstNameController.value.text,
            _usernameController.value.text,
            _profileImage?.path ?? "",
          );
          Navigator.pop(context); // Fermer le loader
          setState(() {
            user = {
              "username": _usernameController.value.text,
              "name": _firstNameController.value.text,
              "avatar": "https://twittueur.bassinecorp.fr/avatars/${_usernameController.value.text}.png"
            };
          });
        },
        backgroundColor: _firstNameController.value.text != "" &&
                _usernameController.value.text.length >= 4
            ? Colors.white
            : Colors.white70,
        foregroundColor: const Color.fromARGB(255, 80, 66, 66),
        child: const Icon(Icons.arrow_forward_ios),
      ),
      body: // Rendre la page scrollable
          SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 35),
          child: Column(
            children: [
              const Text("Créer un compte",
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _firstNameController,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Ce champ ne peut pas être vide';
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                        labelText: "Prénom",
                        hintText: "Entrez le prénom",
                      ),
                      textCapitalization: TextCapitalization.words,
                      onChanged: (value) => setState(() {}),
                      maxLength: 20,
                    ),
                    const SizedBox(height: 30),
                    TextFormField(
                      controller: _usernameController,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Ce champ ne peut pas être vide';
                        } else if (value.length < 4) {
                          return "Le nom d'utilisateur doit contenir au moins 4 caractères";
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                        labelText: "Nom d'utilisateur",
                        hintText: "Entrez votre nom d'utilisateur",
                      ),
                      autocorrect: false,
                      inputFormatters: [
                        FilteringTextInputFormatter.deny(
                            RegExp(r'\s')), // Empêcher les espaces
                        // Empecher l'utf-8, et autoriser . _ et -
                        FilteringTextInputFormatter.allow(
                            RegExp(r'[a-z0-9-_.\-]')),
                      ],
                      maxLength: 13,
                      onChanged: (value) => setState(() {}),
                    ),
                    const SizedBox(height: 40),
                    GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: _profileImage != null
                            ? FileImage(_profileImage!)
                                as ImageProvider<Object>?
                            : const AssetImage("assets/empty.png"),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text("Choisir une photo de profil"),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
