import 'package:flutter/material.dart';
import 'package:twittueur/src/utils/requests_utils.dart';
import 'package:twittueur/src/widgets/common_widgets.dart';
import 'package:twittueur/src/widgets/post_card_widget.dart';

class BookmarksPage extends StatefulWidget {
  const BookmarksPage({super.key});

  @override
  State<BookmarksPage> createState() => _BookmarksPageState();
}

class _BookmarksPageState extends State<BookmarksPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Signets",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: FutureBuilder<List>(
        future: fetchUserBookmarks(
            context), // Récupérer les signets de l'utilisateur
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            // Si on a des données
            if (snapshot.data!.isEmpty) {
              // Mais quelles sont vides
              return Center(
                // On affiche un message
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.bookmark,
                      color: Colors.blue,
                      size: 50,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Vous n'avez pas encore enregistré de posts.", // Qui informe
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    // RichText permet d'afficher une icone dans le texte
                    RichText(
                      textAlign: TextAlign.center,
                      strutStyle: const StrutStyle(fontSize: 25.0),
                      text: TextSpan(
                        style: Theme.of(context).textTheme.bodyMedium,
                        children: const [
                          TextSpan(
                              // Texte
                              text:
                                  'Lorsque vous souhaitez enregistrer un post, \ncliquez sur le bouton',
                              style: TextStyle(fontSize: 16.0)),
                          WidgetSpan(
                            // Widget qui est une icone
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 2.0),
                              child: Icon(Icons.bookmark_add_outlined),
                            ),
                          ),
                          TextSpan(
                              // Texte
                              text: 'du post.',
                              style: TextStyle(fontSize: 16.0)),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }
            return RawScrollbar(
              // Afficher une barre de défillement
              thumbColor: Colors.grey[600],
              radius: const Radius.circular(20),
              thickness: 5, // Epaisseur de la barre
              interactive: true, // Cliquable
              timeToFade: const Duration(seconds: 3), // Durée de la barre
              fadeDuration:
                  const Duration(milliseconds: 300), // Durée de la disparition
              child: ListView.builder(
                // Liste des posts
                shrinkWrap: false,
                itemCount: snapshot.data!.length, // Nombre de posts
                itemBuilder: (context, index) {
                  return PostCard(
                    subject: snapshot.data![index].subject!, // Le sujet
                    image: snapshot.data![index].image!, // L'image
                    postId: snapshot.data![index].id!, // L'id du post
                    passphrase: snapshot.data![index]
                        .passphrase!, // La passphrase associé au post
                    date: snapshot.data![index].date!, // La date du post
                    device: snapshot.data![index]
                        .device!, // L'appareil (iPhone ou Android) utilisé pour poster
                    showButtons: false,
                  );
                },
              ),
            );
          } else {
            // Si on est en attente
            return loader(); // On affiche un chargement
          }
        },
      ),
    );
  }
}
