// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';

class popScopeDialog extends StatelessWidget {
  late int levels;
  late String category;
  popScopeDialog({
    super.key,
    required this.levels,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      //checking if the kitchen view dialog is visible
      canPop: false,
      onPopInvoked: (bool didPop) {
        if (didPop) {
          return;
        }
        _showBackDialog(context, levels, category);
      },

      child: TextButton(
        onPressed: () {
          _showBackDialog(context, levels, category);
        },
        child: const Icon(Icons.home),
      ),
    );
  }
}

void _showBackDialog(BuildContext context, int levels, String category) {
  //"are you sure" help from Flutter documentation (https://api.flutter.dev/flutter/widgets/PopScope-class.html)

  late String title = "Are you sure about leaving?";
  late String content = "You may potentially lose data!";
  late String stayText = "Stay";
  late String exitText = "Leave";

  if (category == "waiter") {
    title = 'Discard order';
    content =
        'Are you sure you want to leave this page? This will abandon any order that has not been submitted!';
    stayText = 'Stay on the order page';
    exitText = 'Leave, discard order';
  } else {
    title = 'Leave order view?';
    content = '';
    stayText = 'Stay on the viewing page';
    exitText = 'Leave, return to home screen';
  }

  showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(
            title), //const used for better performance, indicator to Dart that this value will never change when running
        content: Text(content),
        actions: <Widget>[
          TextButton(
            style: TextButton.styleFrom(
              textStyle: Theme.of(context).textTheme.labelLarge,
            ),
            child: Text(stayText),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          TextButton(
            style: TextButton.styleFrom(
              textStyle: Theme.of(context).textTheme.labelLarge,
            ),
            child: Text(
              exitText,
              style: const TextStyle(color: Colors.red),
            ),
            onPressed: () {
              navigatorPop(context, levels);
            },
          ),
        ],
      );
    },
  );
}

void navigatorPop(BuildContext context, int levels) {
  for (int i = 0; i < levels; i++) {
    //if on root of ordering, then 2 will be needed, one for the popup dialog, another for the root view
    Navigator.pop(context);
  }
}
