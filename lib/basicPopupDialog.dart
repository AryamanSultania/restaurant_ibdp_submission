//function which is called on a few times, clean up code

import 'package:flutter/material.dart';

class basicTextDialog {
  dynamic getTextDialog(String inputText, BuildContext context) {
    late String displayText = "";
    displayText = inputText;

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          height: 70,
          width: 70,
          child: AlertDialog(
            content: Text(displayText),
          ),
        );
      },
    );
  }
}
