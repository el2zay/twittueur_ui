import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:twittueur/src/utils/common_utils.dart';
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
  File? _image;

  // Ouvrir le clavier dès qu'on arrive sur la page.
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final File imageFile = File(pickedFile.path);
      final int fileSize = await imageFile.length();
      // Convertir la taille du fichier en MB
      final double fileSizeInMB = fileSize / (1024 * 1024);
      // Récupérer le height et le width

      if (fileSizeInMB > 10) {
        showSnackBar(
            // ignore: use_build_context_synchronously
            context,
            "L'image ne doit pas dépasser les 10MB",
            Icons.error);
      } else {
        setState(() {
          _image = imageFile;
        });
      }
    }
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
                  postData(context, _postController.text, widget.comment,
                      _image?.path ?? "");
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
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                children: [
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
                  // Afficher l'image
                  if (_image != null)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        constraints: const BoxConstraints(
                          maxHeight: 200, // Hauteur maximale de 200
                          maxWidth: 150, // Largeur maximale de 200
                        ),
                        margin:
                            const EdgeInsets.only(left: 20), // Marge à gauche
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(15), // Coins arrondis
                          image: DecorationImage(
                            image: FileImage(_image!), // Image
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          // Afficher une barre avec le bouton image
          Container(
            height: 50,
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.grey[800]!, width: 0.5),
              ),
            ),
            child: Row(
              children: [
                const SizedBox(width: 20),
                IconButton(
                  icon: const Icon(
                    Icons.image_outlined,
                    color: Colors.white,
                    size: 25,
                  ),
                  onPressed: () {
                    _focusNode.unfocus(); // Fermer le clavier
                    _pickImage(); // Ouvrir la galerie
                  },
                ),
                const Text("Évitez les images carrés",
                    style: TextStyle(
                        color: Colors.grey, overflow: TextOverflow.ellipsis)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
