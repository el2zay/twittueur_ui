import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

Widget loader({size = 20.0}) {
  return defaultTargetPlatform == TargetPlatform.iOS
      ? Center(
          child: CupertinoActivityIndicator(
            radius: size,
          ),
        )
      : Center(
          child: CircularProgressIndicator(
            // Taille
            strokeWidth: size/10.0,
          ),
        );
}