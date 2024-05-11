// ignore_for_file: use_build_context_synchronously

import 'package:twittueur/main.dart';
import 'package:twittueur/pages/post.dart';
import 'package:twittueur/pages/reader.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:twittueur/src/utils/requests_utils.dart';
import 'package:expandable_text/expandable_text.dart';

// Cette classe va nous permettre de récupérer les informations des posts.
class Posts {
  String? subject;
  String? image;
  String? id;
  String? passphrase;
  String? date;
  String? device;
  bool? isComment = false;

  Posts({
    this.subject,
    this.image,
    this.id,
    this.passphrase,
    this.date,
    this.device,
    this.isComment,
  });

  // On récupère les données du json à partir de la clé du json.
  // Et on associe chaque clé à une variable défini dans la class.
  Posts.fromJson(Map<String, dynamic> json)
      : subject = json['body'],
        image = json['image'],
        id = json['id'],
        passphrase = json['passphrase'],
        date = json['date'],
        device = json['device'],
        isComment = json['isComment'];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['body'] = subject;
    data['image'] = image;
    data['id'] = id;
    data['isComment'] = isComment ?? false;
    data['date'] = date;
    data['device'] = device;
    data['passphrase'] = passphrase;
    return data;
  }
}

// Cette classe va nous permettre de créer un widget pour chaque post.
// ignore: must_be_immutable
class PostCard extends StatefulWidget {
  final String subject;
  final String image;
  final String postId;
  final String date;
  final String device;
  final String passphrase;
  final bool showButtons;

  const PostCard({
    super.key,
    required this.subject,
    required this.image,
    required this.postId,
    required this.date,
    required this.device,
    required this.passphrase,
    required this.showButtons,
  });

  @override
  createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool isMounted =
      false; // On vérifie si le widget est monté pour éviter les erreurs
  // Et on initialise les variables.
  bool isLiked = false;
  bool isBookmarked = false;
  String username = "";
  String name = "";
  String avatar = "";

  @override
  void initState() {
    // Lorsque le widget est initialisé
    super.initState();
    isMounted = true; // On informe que le widget est monté
    checkStatus(context); // Et on vérifie le statut du post

    // On récupère les informations de l'utilisateur avec la passphrase donnée.
    fetchUser(context, widget.passphrase).then((value) {
      if (value == null) {
        return;
      }
      if (isMounted) {
        // Vérifiez si le widget est monté pour éviter les erreurs dans la console.
        setState(() {
          username = value['username'];
          name = value['name'];
          avatar = value['avatar'];
        });
      }
    });
  }

  @override // Lorsque le widget est détruit
  void dispose() {
    isMounted = false; // On informe que le widget n'est plus monté
    super.dispose();
  }

  // cette fonction va nous permettre de vérifier le statut du post. (si il est liké ou bookmarked)
  Future<void> checkStatus(context) async {
    if (isMounted) {
      // On fait la vérification si le widget est monté pour éviter les erreurs
      List likesIds =
          await fetchLikes(context, widget.postId); // On récupère les likes
      List bookmarksIds = await fetchBookmarks(
          context, widget.postId); // On récupère les bookmarks
      setState(() {
        // On vérifie si l'utilisateur a déjà liké ou bookmark le post.
        isLiked = likesIds.contains(user['username']
            .replaceFirst('@', '')); // On retire le @ pour éviter les erreurs.
        isBookmarked =
            bookmarksIds.contains(user['username'].replaceFirst('@', ''));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      // Notre post sera une Card
      margin: const EdgeInsets.only(top: 18), // On ajoute une marge en haut
      elevation:
          0.5, // L'élévation de la card pour que la séparation soit visible
      shadowColor: Colors.white, // Séparation en blanc
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero, // Pas de bord arrondi
      ),
      child: GestureDetector(
        // Si l'utilisateur double tap sur le post
        onDoubleTap: () async {
          HapticFeedback.lightImpact(); // On ajoute un effet haptique
          await likesPost(context, widget.postId); // On like le post
          checkStatus(context); // On vérifie le statut
        },
        onLongPress: () async {
          // Si l'utilisateur appuie longtemps sur le post
          HapticFeedback.selectionClick(); // On ajoute un effet haptique
          await savePost(context, widget.postId); // On bookmark le post
          checkStatus(context); // On vérifie le statut
        },
        onTap: () async {
          // Si l'utilisateur tape sur le post
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ReaderPage(
                // On redirige vers la page ReaderPage
                subject: widget.subject,
                image: widget.image,
                passphrase: widget.passphrase,
                infos: "${widget.date} • Twittueur for ${widget.device}",
                id: widget.postId,
              ),
            ),
          );
        },
        child: Column(
          children: [
            ListTile(
              isThreeLine: true,
              // On affiche la photo de profil de l'utilisateur
              // À gauche du post
              leading: CircleAvatar(
                backgroundImage:
                    avatar.isNotEmpty ? NetworkImage(avatar) : null,
                backgroundColor: Colors.grey,
              ),
              title: Row(
                // Sur une même ligne
                children: [
                  Text(
                    name, // On affiche le nom
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    username, // Le nom d'utilisateur
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              subtitle: Padding(
                // On ajoute du padding pour laisser un espace
                padding:
                    const EdgeInsets.only(top: 5.0), // Entre le nom et le post
                child: ExpandableText(
                  // Si le texte fait plus de 6 lignes, il sera réduit
                  widget.subject, // On affiche le post
                  expandText: 'Voir plus',
                  collapseText: '\nVoir moins',
                  maxLines: 6,
                  animation: false,
                  linkColor: Colors.blue,
                ),
              ),
            ),
            // Afficher une image en dessous
            widget.image.isNotEmpty
                ? Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(left: 25),
                    constraints: const BoxConstraints(
                      maxHeight: 500, // Hauteur maximale de 500
                      maxWidth: 500, // Largeur maximale de 500
                    ),
                    child: Image.network(
                      widget.image,
                      fit: BoxFit.cover,
                    ),
                  ))
                : const SizedBox(),
            widget.showButtons != true
                ? // Si l'on ne souhaite pas afficher les boutons
                const SizedBox(
                    // On affiche un espace blanc
                    height: 15,
                  )
                : Row(
                    // Les éléments seront espacés entre eux
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      // Bouton pour les commentaire
                      IconButton(
                        onPressed: () {
                          // Lorsque l'utilisateur appuie sur le bouton
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PostPage(
                                // On affiche la page pour poster
                                comment: widget
                                    .postId, // On ajoute le post id pour informer que c'est un commentaire
                              ),
                              fullscreenDialog: true, // En plein écran
                            ),
                          );
                        },
                        icon: Image.asset(
                          'assets/comments.png', // L'icone
                          color: Colors.blueGrey[400], // Sa couleur
                          // Sa taille
                          width: 18,
                          height: 18,
                        ),
                      ),
                      IconButton(
                        // Bouton pour liker le post
                        onPressed: () async {
                          HapticFeedback.selectionClick(); // Effet haptique
                          await likesPost(
                              context, widget.postId); // On like le post
                          checkStatus(context); // On vérifie le statut
                        },
                        icon: isLiked // Si le post est liké
                            ? const Icon(
                                // On affiche l'icone en rose
                                Icons.favorite,
                                color: Color.fromARGB(255, 249, 24, 128),
                                size: 18,
                              )
                            : const Icon(
                                // Sinon on l'affiche vide
                                Icons.favorite_outline,
                                size: 18,
                              ),
                      ),
                      IconButton(
                        onPressed: () async {
                          // Bouton pour bookmark le post
                          HapticFeedback.selectionClick(); // Effet haptique
                          await savePost(
                              context, widget.postId); // On bookmark le post
                          checkStatus(context); // On vérifie le statut
                        },
                        icon: isBookmarked // Si le post est bookmarké
                            ? const Icon(
                                // On affiche l'icone en bleu
                                Icons.bookmark,
                                color: Colors.blue,
                                size: 18,
                              )
                            : const Icon(
                                // Sinon on l'affiche vide
                                Icons.bookmark_add_outlined,
                                size: 18,
                              ),
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}
