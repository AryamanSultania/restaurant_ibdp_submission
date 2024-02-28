// ignore_for_file: avoid_web_libraries_in_flutter, use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:html' as html;

class firebaseAuth extends StatelessWidget {
  void logUserOut() {
    FirebaseAuth.instance.signOut();
    html.window.location.reload();
    //https://stackoverflow.com/a/59631291/15997993
  }

  Future<void> attemptLogIn(String submittedEmail, String submittedPassword,
      BuildContext context) async {
    if (!submittedEmail.contains("@")) {
      submittedEmail = "$submittedEmail@internal.internal";
    }
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: submittedEmail, password: submittedPassword);

      html.window.location.reload();
    } on FirebaseAuthException catch (e) {
      if (e.code == "invalid-credential") {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Incorrect account details. Try reentering."),
        ));
      } else if (e.code == "invalid-email") {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              "The email/username is not acceptable. Check the format please."),
        ));
      } else if (e.code == "missing-password") {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("No password given. Please enter a password."),
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Error with authentication. ${e.code}, ${e.message}"),
        ));
      }
    }
  }

  Widget build(BuildContext context) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        //the mediaqueries are for making sure the elements are in the center
        //think of sizedbox as padding, they're invisible
        SizedBox(
          width: 0.1 * MediaQuery.of(context).size.width,
        ),
        Expanded(
          child: Column(
            children: [
              SizedBox(
                height: 0.20 * MediaQuery.of(context).size.height,
              ),
              Expanded(
                flex: 2,
                child: TextField(
                  autofillHints: const [AutofillHints.username],
                  //https://medium.com/@debasishkumardas5/streamline-user-input-with-flutter-auto-fill-integration-a-comprehensive-guide-37058a597e3e
                  controller: emailController,
                  maxLines: 1,
                  decoration: InputDecoration(
                    labelText: "Email or username",
                    fillColor: Colors.blueAccent,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(6),
              ),
              Expanded(
                flex: 2,
                child: TextField(
                  autofillHints: const [AutofillHints.password],
                  controller: passwordController,
                  maxLines: 1,
                  decoration: InputDecoration(
                    labelText: "Password",
                    fillColor: Colors.blueAccent,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                  obscureText: true,
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(6),
              ),
              Expanded(
                flex: 1,
                child: ElevatedButton(
                  child: const Text("Log in"),
                  onPressed: () {
                    String submittedEmail = emailController.text;
                    String submittedPassword = passwordController.text;
                    attemptLogIn(submittedEmail, submittedPassword, context);
                  },
                ),
              ),
              SizedBox(
                height: 0.20 * MediaQuery.of(context).size.height,
              ),
            ],
          ),
        ),
        SizedBox(
          width: 0.1 * MediaQuery.of(context).size.width,
        ),
      ],
    );
  }
}
