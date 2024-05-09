import 'package:flutter/material.dart';
import 'package:twittueur/src/utils/requests_utils.dart';

class ReaderPage extends StatefulWidget {
  final String subject;
  final String passphrase;
  final String infos;

  const ReaderPage({
    super.key,
    required this.subject,
    required this.passphrase,
    required this.infos,
  });

  @override
  createState() => _ReaderPageState();
}

class _ReaderPageState extends State<ReaderPage> {
  String username = "";
  String name = "";
  String avatar = "";

  @override
  void initState() {
    super.initState();
    fetchUser(context, widget.passphrase).then((value) {
      if (value == null) {
        return;
      }
      if (mounted) {
        // Vérifiez si le widget est monté pour éviter les erreurs dans la console.
        setState(() {
          username = value['username'];
          name = value['name'];
          avatar = value['avatar'];
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: SingleChildScrollView(
        child: Padding(
          // Ajouter du padding pour éviter de coller les bords
          padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                // Élements en ligne
                children: [
                  CircleAvatar(
                    // Avatar
                    radius: 22,
                    backgroundImage:
                        avatar.isNotEmpty ? NetworkImage(avatar) : null,
                    backgroundColor: Colors.grey,
                  ),
                  const SizedBox(width: 10), // Espace entre les éléments
                  Column(
                    // Élements en colonne dans la ligne
                    children: [
                      // Afficher le prénom et le @
                      Text(name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          )),
                      Text(username,
                          style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 25),
              Padding(
                padding: const EdgeInsets.only(
                    left: 5), // Rajouter du padding à gauche du texte
                child: SelectableText( // Rendre le texte sélectionnable
                  widget.subject, // Afficher le sujet
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Text(widget.infos,
                  style:
                      const TextStyle(color: Colors.grey)), // Afficher la date
              const Divider(
                color: Colors.white24,
              ) // Séparateur

              // TODO afficher les commentaires
            ],
          ),
        ),
      ),
    );
  }
}
