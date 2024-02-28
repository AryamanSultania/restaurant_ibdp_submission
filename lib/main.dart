import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'firebaseAuth.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'homePage.dart';
import 'teledart.dart';

void main() async {
  await initFire();
  teledartService().initTeledart();

  runApp(
    const MyApp(),
  );
}

Future<void> initFire() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return (const MyHomePage());
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    late Widget displayedPage;

    if (currentUser != null) {
      displayedPage = const homePage();
    } else {
      displayedPage = firebaseAuth();
    }

    const appTitle = 'Order system';
    return MaterialApp(
      title: appTitle,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text(appTitle),
        ),
        body: displayedPage,
      ),
    );
  }
}
