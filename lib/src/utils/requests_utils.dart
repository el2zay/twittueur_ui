import 'dart:convert';
import 'dart:io';
import 'package:twittueur/pages/home.dart';
import 'package:twittueur/src/utils/common_utils.dart';
import 'package:twittueur/src/widgets/post_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

/* 
Type de requêtes :
- GET : Récupérer des données
- POST : Envoyer des données
 */

var box = GetStorage();

// Bookmarks

Future<List> fetchBookmarks(context, id) async {
  var request = http.MultipartRequest(
      'GET', Uri.parse('https://twittueur.bassinecorp.fr/bookmarks'));
  request.fields.addAll({'id': id});

  request.headers.addAll({
    'Authorization': 'Bearer ${box.read('token')}',
    'Content-Type': 'application/json',
  });

  http.StreamedResponse response = await request.send();

  if (response.statusCode == 200) {
    var responseString = await response.stream.bytesToString();
    var data = jsonDecode(responseString)['data'];
    return data ?? [];
  } else if (response.statusCode == 400) {
    return [];
  } else {
    showSnackBar(context, "Une erreur est survenue : ${response.reasonPhrase}",
        Icons.error);
    return [];
  }
}

Future savePost(context, id) async {
  var request = http.MultipartRequest(
      'POST', Uri.parse('https://twittueur.bassinecorp.fr/bookmarks'));
  request.fields.addAll({'id': id});

  request.headers.addAll({
    'Authorization': 'Bearer ${box.read('token')}',
    'Content-Type': 'application/json',
  });
  final response = await request.send();

  if (response.statusCode != 200) {
    return showSnackBar(context,
        "Une erreur est survenue : ${response.reasonPhrase}", Icons.error);
  }
}

// Likes

Future<List> fetchLikes(context, id) async {
  var request = http.MultipartRequest(
      'GET', Uri.parse('https://twittueur.bassinecorp.fr/likes'));
  request.fields.addAll({'id': id});

  request.headers.addAll({
    'Authorization': 'Bearer ${box.read('token')}',
    'Content-Type': 'application/json',
  });

  http.StreamedResponse response = await request.send();

  if (response.statusCode == 200) {
    var responseString = await response.stream.bytesToString();
    var data = jsonDecode(responseString)['data'];
    return data;
  } else if (response.statusCode == 400) {
    return [];
  } else {
    showSnackBar(context, "Une erreur est survenue : ${response.reasonPhrase}",
        Icons.error);
    return [];
  }
}

Future likesPost(context, id) async {
  var request = http.MultipartRequest(
      'POST', Uri.parse('https://twittueur.bassinecorp.fr/likes'));
  request.fields.addAll({'id': id});

  request.headers.addAll({
    'Authorization': 'Bearer ${box.read('token')}',
    'Content-Type': 'application/json',
  });
  final response = await request.send();

  if (response.statusCode != 200) {
    return showSnackBar(context,
        "Une erreur est survenue : ${response.reasonPhrase}", Icons.error);
  }
}

// Posts

Future postData(context, body, comment, image) async {
  var request = http.MultipartRequest(
      'POST', Uri.parse('https://twittueur.bassinecorp.fr/posts'));

  String formattedDate =
      DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.now());

  String deviceType = Platform.isIOS ? 'iPhone' : 'Android';

  request.fields.addAll({
    'body': body,
    'date': formattedDate,
    'comment': comment,
    'device': deviceType,
  });
  if (image.isNotEmpty) {
    request.files.add(await http.MultipartFile.fromPath('image', image));
  }
  request.headers.addAll({
    'Authorization': 'Bearer ${box.read('token')}',
    'Content-Type': 'application/json',
  });

  http.StreamedResponse response = await request.send();
  String responseBody = await response.stream.bytesToString();
  Map<String, dynamic> jsonData = jsonDecode(responseBody);

  if (response.statusCode == 200) {
    return;
  } else {
    return showSnackBar(
        context,
        "Une erreur est survenue : ${jsonData['message']}",
        Icons.error_outline_outlined);
  }
}

Future<List<Posts>> fetchPosts(context, postIds, showComments) async {
  final response = await http.get(Uri.parse(
      'https://twittueur.bassinecorp.fr/posts?ids=$postIds&showComments=$showComments')); // On envoie une requête GET au serveur

  if (response.statusCode == 200) {
    // S'il n'y a pas d'erreur
    final List<dynamic> jsonData = json.decode(utf8
        .decode(response.bodyBytes)); // On décode le body de la réponse en JSON
    return jsonData
        .map((e) => Posts.fromJson(e as Map<String, dynamic>))
        .toList(); // On retourne une liste de Posts
  } else {
    return []; // Sinon on retourne une liste vide
  }
}

// Length

Future<int> globalPostsLength() async {
  final responseGlobal = await http.get(
    Uri.parse('https://twittueur.bassinecorp.fr/globalPostsLength'),
  );

  final Map<String, dynamic> jsonDataGlobal = json.decode(responseGlobal.body);
  final int lengthGlobal = jsonDataGlobal['message'];

  return lengthGlobal;
}

Future userPostsLength() async {
  var request = http.MultipartRequest(
    'GET',
    Uri.parse('https://twittueur.bassinecorp.fr/userPostsLength'),
  );

  request.fields.addAll({'passphrase': getPassphrase()});

  http.StreamedResponse response = await request.send();

  if (response.statusCode == 200) {
    var responseString = await response.stream.bytesToString();
    var data = jsonDecode(responseString)['message'];
    return data;
  } else {
    debugPrint(response.reasonPhrase);
  }

  return 0;
}

// User
Future<Map<String, dynamic>?> fetchUser([context, passphrase]) async {
  // Map est un type permettant de faire des clé-valeur.
  var request = http.MultipartRequest(
    'GET',
    Uri.parse('https://twittueur.bassinecorp.fr/user'),
  );
  request.fields.addAll({'passphrase': passphrase ?? getPassphrase()});

  http.StreamedResponse response = await request.send();

  if (response.statusCode == 200) {
    var responseString = await response.stream.bytesToString();
    var data = jsonDecode(responseString)['data'];
    // Remplacer db par https://twittueur.bassinecorp.fr/ dans name
    data['avatar'] =
        data['avatar'].replaceAll('db', 'https://twittueur.bassinecorp.fr');
    return {
      'username': '@${data['username']}',
      'name': data['name'],
      'avatar': data['avatar'],
    };
  } else {
    // Si il y a une passphrase en paramètre
    if (passphrase != null) {
      showSnackBar(
        context,
        response.reasonPhrase.toString(),
        Icons.error,
      );
      debugPrint(response.reasonPhrase);

      return null;
    }
    debugPrint(response.reasonPhrase);
    return null;
  }
}

// Register

Future register(context, name, username, avatar) async {
  final request = http.MultipartRequest(
      'POST', Uri.parse('https://twittueur.bassinecorp.fr/register'));
  request.fields.addAll({'username': username, 'name': name});

  // Si avatar n'est pas vide on ajoute le fichier
  if (avatar.toString().isNotEmpty) {
    request.files.add(await http.MultipartFile.fromPath('avatar', avatar));
  }

  http.StreamedResponse response = await request.send();
  String responseBody = await response.stream.bytesToString();
  Map<String, dynamic> jsonData = jsonDecode(responseBody);
  if (response.statusCode == 200) {
    final String token = jsonData['message'];
    box.write('token', token); // Ecrire le token dans le cache
    Navigator.pushAndRemoveUntil(
      // Rediriger vers la page HomePage sans retour possible.
      context,
      MaterialPageRoute(builder: (context) => const HomePage()),
      (route) => false,
    );
    return token;
  } else {
    debugPrint(jsonData['message']);
    return showSnackBar(context, jsonData['message'], Icons.error);
  }
}

// Login

Future login(context, username, passphrase) async {
  final request = http.MultipartRequest(
      'POST', Uri.parse('https://twittueur.bassinecorp.fr/login'));
  request.fields.addAll({'username': username, 'passphrase': passphrase});

  http.StreamedResponse response = await request.send();
  String responseBody = await response.stream.bytesToString();
  Map<String, dynamic> jsonData = jsonDecode(responseBody);
  if (response.statusCode == 200) {
    final String token = jsonData['message'];
    box.write('token', token); // Ecrire le token dans le cache
    Navigator.pushAndRemoveUntil(
      // Rediriger vers la page HomePage sans retour possible.
      context,
      MaterialPageRoute(builder: (context) => const HomePage()),
      (route) => false,
    );
    return token;
  } else {
    debugPrint(jsonData['message']);
    Navigator.pop(context);
    return showSnackBar(context, jsonData['message'], Icons.error);
  }
}
