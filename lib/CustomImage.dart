//this class is needed because for some reason, images stored on firebase can't be shown with the normal InternetImage() in flutter for CanvasKit, but works on HTML.
//To use the higher performance of CanvasKit while still showing images from firebase storage, this workaround has been used from the internet.

// ignore_for_file: prefer_const_constructors

// ignore: avoid_web_libraries_in_flutter
import 'dart:html';
import 'package:flutter/material.dart';
import 'dart:ui_web' as ui;
import 'package:restaurant_ibdp_submission/FirebaseFirestoreClass.dart';

class CustomImage {
  //ADAPTED FROM https://github.com/flutter/flutter/issues/49725#issuecomment-825882047

  FutureBuilder<String> finalInternetImage(
      String mainCategory, String subCategory, String specificItem) {
    return FutureBuilder<String>(
      //help from Google Bard
      future: FirebaseFirestoreClass()
          .getImageURL(mainCategory, subCategory, specificItem),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return displayInternetImage(snapshot.data!);
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }

  HtmlElementView displayInternetImage(String imageUrl) {
    ui.platformViewRegistry.registerViewFactory(
        imageUrl,
        (int viewId) => ImageElement()
          ..src = imageUrl
          ..width = 200
          ..height = 200
          ..style.width = '100%'
          ..style.height = '100%'
        //style size help from https://github.com/flutter-mapbox-gl/maps/issues/795#issuecomment-983637338

        );
    return HtmlElementView(
      viewType: imageUrl,
    );
  }
}
