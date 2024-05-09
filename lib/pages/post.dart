import 'package:flutter/material.dart';
import 'package:twittueur/src/utils/requests_utils.dart';

class PostPage extends StatefulWidget {
  final String comment;
  // Paramètre comment que l'on ajoute afin de savoir si l'utilisateur commente ou poste.
  const PostPage({super.key, required this.comment});

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  final TextEditingController _postController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  // Ouvrir le clavier dès qu'on arrive sur la page.
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Bouton à droite
        leading: TextButton(
          child: const Text(
            "Annuler",
            style: TextStyle(fontSize: 15),
          ),
          onPressed: () {
            // Quitter la page
            Navigator.pop(context);
          },
        ),
        leadingWidth: 100,
        // Bouton à gauche
        actions: [
          SizedBox(
            height: 35, // Changer la hauteur du bouton
            child: ElevatedButton(
              // Bouton basique
              onPressed: () {
                if (_postController.text.trim().isEmpty) {
                  return;
                } else {
                  postData(context, _postController.text, widget.comment, "");
                  Navigator.pop(context);
                }
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(
                    _postController.text.trim().isEmpty
                        ? Colors.blueGrey
                        : Colors.blue),
                padding: MaterialStateProperty.all(
                    const EdgeInsets.symmetric(horizontal: 20)),
              ),
              child: Text(widget.comment == "" ? "Poster" : "Commenter",
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
      body: // Barre de défilement
          Scrollbar(
        controller: _scrollController,
        child: TextField(
          controller: _postController,
          focusNode: _focusNode,
          decoration: const InputDecoration(
            border: InputBorder.none, // Sans bordure
            hintText: "Quoi de neuf ?", // Texte d'exemple
            hintStyle: TextStyle(color: Colors.grey),
            contentPadding: EdgeInsets.all(20), // Marge intérieure
          ),
          cursorColor: Colors.blue, // Couleur du curseur
          maxLines: null, // Nombre de lignes infini
          maxLength: 1000,
          textCapitalization: TextCapitalization.sentences,
          onChanged: (value) {
            setState(() {});
          },
        ),
      ),
    );
  }
}
