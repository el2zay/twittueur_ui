import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

String getPassphrase() {
  if (GetStorage().read('token') == null || GetStorage().read('token') == "") {
    return "";
  }

  var tokenSplit = GetStorage().read('token').split('.')[1];
  var tokenSplitDecode = json.decode(
    utf8.decode(base64.decode(base64.normalize(tokenSplit))),
  );
  var passphrase = tokenSplitDecode['passphrase'];
  return passphrase ?? "";
}

void showSnackBar(BuildContext context, String message, IconData icon,
    [String? action]) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(width: 8.0),
          Flexible(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 16.0,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      behavior: SnackBarBehavior.floating,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(15)),
      ),
      duration: const Duration(milliseconds: 2500),
      backgroundColor: const Color.fromRGBO(28, 28, 28, 1),
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
    ),
  );
}