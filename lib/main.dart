import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:get_storage/get_storage.dart';
import 'package:twittueur/pages/first.dart';
import 'package:twittueur/pages/home.dart';
import 'package:twittueur/src/utils/requests_utils.dart';

Map<String, dynamic> user =
    {}; // On rend la variable user globale pour pouvoir l'utiliser partout

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  user = (await fetchUser()) ?? {};
  runApp(Phoenix(child: const MainApp()));
}

bool isBookmarkPage = false;

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Si le token est vide on affiche firstpage
      home: GetStorage().read("token") == null
          ? const FirstPage()
          : const HomePage(),

      // Theme sombre pour l'application
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.black,
        appBarTheme: const AppBarTheme(
            backgroundColor: Colors.black, foregroundColor: Colors.white),
        cardTheme: const CardTheme(
          color: Colors.black,
        ),
        scaffoldBackgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.blueGrey[400], size: 20),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        splashFactory: NoSplash.splashFactory,

        // Tous les textes des boutons
        textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(
            foregroundColor: MaterialStateProperty.all(Colors.white),
          ),
        ),
      ),
    );
  }
}
