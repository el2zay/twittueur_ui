import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:get_storage/get_storage.dart';
import 'package:twittueur/main.dart';
import 'package:twittueur/pages/bookmarks.dart';
import 'package:twittueur/pages/post.dart';
import 'package:twittueur/src/utils/common_utils.dart';
import 'package:twittueur/src/utils/requests_utils.dart';
import 'package:twittueur/src/widgets/common_widgets.dart';
import 'package:twittueur/src/widgets/post_card_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  AsyncSnapshot<List<Posts>>? _snapshot;
  final _scrollController =
      ScrollController(); // Contrôleur de défilement, permet de savoir où on est dans la liste
  List<Posts> _posts = []; // Liste des posts
  String _postIds = ""; // Liste des ids des posts
  Future<List<Posts>>? _postsFuture;
  bool _isLoading = false;
  var _isCopied = false;

  bool? activeConnection;
  Future checkUserConnection() async {
    // Vérifier si l'utilisateur a une connexion internet
    try {
      final result = await InternetAddress.lookup('example.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        setState(() {
          activeConnection = true;
        });
      }
    } on SocketException catch (_) {
      setState(() {
        activeConnection = false;
      });
      rethrow;
    }
  }

  @override
  void initState() {
    // Lorsque l'on arrive sur la page
    super.initState(); // On appelle la méthode initState de la classe parente
    checkUserConnection(); // On vérifie la connexion de l'utilisateur
    WidgetsBinding.instance.addObserver(this); // On ajoute un "observateur"
    _scrollController.addListener(
        _loadMorePosts); // Listener qui nous permettra de charger plus de posts
    _postsFuture =
        fetchPosts(context, _postIds, false); // On récupère les posts
    _postsFuture?.then((initialPosts) {
      // On récupère les nouveaux posts
      _posts = initialPosts;
    });
  }

  @override
  void dispose() {
    // Lorsque l'on quitte la page
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.removeListener(_loadMorePosts); // On retire le listener
  }

  // Cette fonction permettra de charger plus de posts
  void _loadMorePosts() async {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        !_isLoading) {
      // Si on est en bas de la liste et que l'on ne charge pas déjà
      setState(() {
        _isLoading = true; // Prévenir que l'on charge
      });

      var newPostIds =
          "$_postIds,${_posts.map((post) => post.id).join(",")}"; // On récupère les ids des posts
      var newPosts = await fetchPosts(
          context, newPostIds, false); // Pour éviter de charger les mêmes posts

      setState(() {
        // On met à jour les posts
        _posts = [..._posts, ...newPosts]; // On ajoute les nouveaux posts
        _postsFuture = Future.value(_posts);
        _isLoading = false; // On arrête de charger

        _postIds = newPostIds; // On met à jour les ids des posts
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Permet de savoir si l'application est en arrière plan
    if (_snapshot!.hasError) {
      // Si on a une erreur
      Phoenix.rebirth(context); // On redémarre l'application
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // barre du haut
        title: Image.asset(
          // Logo de l'application
          "assets/logo.png",
          width: 30,
          height: 30,
        ),
        backgroundColor: Colors.black, // Couleur de la barre
        leading: Builder(
          // Icone à gauche de la barre
          // Permet de créer un widget à partir du contexte actuel pour éviter les erreurs
          builder: (context) => GestureDetector(
              child: Container(
                margin: const EdgeInsets.all(12),
                child: CircleAvatar(
                  backgroundImage:
                      NetworkImage(user['avatar']), // Pdp de l'utilisateur
                ),
              ),
              onTap: () {
                Scaffold.of(context).openDrawer(); // Ouvre le menu latéral
              }),
        ),
      ),
      // Menu latéral
      drawer: Drawer(
        // Menu latéral
        backgroundColor: Colors.black,
        width: MediaQuery.of(context).size.width *
            0.6, // Largeur du menu (responsive)
        child: ListView(
          // Liste des éléments du menu
          children: [
            SizedBox(
              height: 200, // taille du drawerheader
              child: DrawerHeader(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(user['avatar'] ??
                        ""), // Affiche l'avatar de l'utilisateur
                    colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(
                          0.7), // Opacité de l'avatar, pour que le texte soit lisible
                      BlendMode.darken,
                    ),
                    fit: BoxFit.cover, // Remplir l'espace sans déformer l'image
                  ),
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start, // Alignement à gauche
                  children: [
                    Text(
                      user['name'] ??
                          "Une erreur s'est produite.", // Nom de l'utilisateur
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold), // Style du texte
                    ),
                    const SizedBox(height: 10),
                    Text(
                      user['username'] ?? "@???", // Pseudo de l'utilisateur
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            ListTile(
              title: Row(
                children: [
                  !_isCopied // Si le texte n'est pas copié
                      ? const Icon(Icons.copy,
                          size: 25) // On affiche l'icone de copie
                      : const Icon(Icons.done,
                          size: 25), // Sinon on affiche l'icone ok
                  Text(
                    // Si le texte n'est pas copié on affiche "Passphrase" sinon "Copié !"
                    !_isCopied ? '\tPassphrase' : '\tCopié !',
                    overflow: TextOverflow
                        .ellipsis, // Si le texte dépasse on affiche "..."
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              onTap: () {
                Clipboard.setData(ClipboardData(
                    text: getPassphrase())); // On copie la passphrase
                setState(() {
                  _isCopied = true; // On met à jour le texte copié
                });
                // Attendre 2 secondes avant de remettre le texte initial
                Future.delayed(const Duration(seconds: 2), () {
                  setState(() {
                    _isCopied = false; // On remet le texte initial
                  });
                });
              },
            ),
            const SizedBox(height: 10),
            ListTile(
                title: const Row(
                  children: [
                    Icon(Icons.bookmark_outline,
                        size: 25), // Icone des bookmarks
                    Text(
                      '\tSignets',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const BookmarksPage(), // Afficher la page des bookmarks
                    ),
                  );
                }),
            const SizedBox(height: 10),
            ListTile(
                title: const Row(
                  children: [
                    Icon(Icons.edit_outlined, size: 25),
                    Text(
                      '\tVos posts',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    // TODO afficher  les posts de l'utilisateur
                    MaterialPageRoute(
                      builder: (context) => const BookmarksPage(),
                    ),
                  );
                }),
            const SizedBox(height: 10),
            ListTile(
              title: const Row(
                children: [
                  Icon(Icons.exit_to_app_rounded, size: 25),
                  Text(
                    '\tDéconnexion',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              onTap: () {
                // Afficher une boite de dialogue pour confirmer la déconnexion
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog.adaptive(
                      title: const Text("Déconnexion"),
                      content: const Text(
                          "Êtes-vous sûr de vouloir vous déconnecter ?"),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(
                                context); // Si annuler Fermer la boite de dialogue
                          },
                          child: Text("Annuler",
                              style: TextStyle(
                                  color: defaultTargetPlatform ==
                                          TargetPlatform.iOS
                                      ? Colors.blue[500]
                                      : null)),
                        ),
                        TextButton(
                          onPressed: () {
                            GetStorage()
                                .remove("token"); // Sinon retirer le token
                            Phoenix.rebirth(
                                context); // Redémarrer l'application
                          },
                          child: Text("Se déconnecter",
                              // Si on est sur iOS afficher en rouge
                              style: TextStyle(
                                  color: defaultTargetPlatform ==
                                          TargetPlatform
                                              .iOS // Si on est sur iOS afficher en rouge
                                      ? Colors.red
                                      : null)),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),

      // Bouton en bas de l'application qui nous permettra de créé un post
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.lightBlue[700],
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const PostPage(
                comment: "",
              ),
              fullscreenDialog: true,
            ),
          );
        },
        //  bouton rond
        shape: const CircleBorder(),
        child: const Icon(
          Icons.add,
          color: Colors.white70,
          size: 30,
        ),
      ),

      backgroundColor: Colors.black,
      // Corps de l'application
      body: RefreshIndicator.adaptive(
        // Permet de rafraichir la page
        onRefresh: () async {
          Phoenix.rebirth(context); // On redémarre l'application
        },
        child: FutureBuilder<List<Posts>>(
          // Permet de construire la liste des posts
          future: _postsFuture, // On récupère les posts
          builder: (context, AsyncSnapshot<List<Posts>> snapshot) {
            _snapshot =
                snapshot; // On stocke les posts dans un snapshot prédéfini
            if (activeConnection == false) {
              // Si l'utilisateur n'a pas de connexion internet
              // Et on affiche un message d'erreur
              return Center(
                child: Column(
                  // Column permet de mettre plusieurs widgets les uns en dessous des autres
                  mainAxisAlignment:
                      MainAxisAlignment.center, // On centre le message
                  children: [
                    const Icon(
                      Icons.wifi_off_outlined,
                      size: 50,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Impossible de se connecter à Internet",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      // Bouton pour réessayer de se connecter
                      onPressed: () {
                        setState(() {
                          // Phoenix.rebirth(
                          //     context); // On redémarre l'application avec Phoenix
                        });
                      },
                      child: const Text("Réessayer"),
                    )
                  ],
                ),
              );
            } else if (snapshot.hasData) {
              return Center(
                child: ListView.builder(
                  shrinkWrap: false, // Évite d'étirer la liste
                  itemCount:
                      snapshot.data!.length, // Nombre d'élément à afficher
                  scrollDirection: Axis.vertical, // Direction de défilement
                  controller: _scrollController,
                  itemBuilder: (context, index) {
                    if (index == snapshot.data!.length - 1) {
                      // Si on est à la fin de la liste
                      return const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Center(
                          child: CupertinoActivityIndicator(
                            // On affiche un chargement
                            radius: 10,
                          ),
                        ),
                      );
                    }
                    // TODO: Rajouter ce message à la fin
                    // return const Padding(
                    //   padding: EdgeInsets.all(8.0),
                    //   child: Column(
                    //     children: [
                    //       Text(
                    //         "Tu as atteint la fin de la liste.",
                    //         style: TextStyle(
                    //           fontSize: 20,
                    //           fontWeight: FontWeight.w700,
                    //         ),
                    //       ),
                    //       SizedBox(height: 15),
                    //       Text(
                    //         "Si vous le souhaitez vous pouvez poster en cliquant sur le bouton bleu en bas de l'écran",
                    //         style: TextStyle(
                    //           fontSize: 15,
                    //           fontWeight: FontWeight.w500,
                    //         ),
                    //         textAlign: TextAlign.center,
                    //       )
                    //     ],
                    //   ),
                    // );
                    return PostCard(
                      subject: snapshot.data![index].subject!, // Le sujet
                      postId: snapshot.data![index].id!, // L'id du post
                      passphrase: snapshot.data![index]
                          .passphrase!, // La passphrase associé au post
                      date: snapshot.data![index].date!, // La date du post
                      device: snapshot.data![index]
                          .device!, // L'appareil (iPhone ou Android) utilisé pour poster
                    );
                  },
                ),
              );
            }
            return loader(); // S'il y a encore besoin de charger la page on affiche un loader
          },
        ),
      ),
    );
  }
}
