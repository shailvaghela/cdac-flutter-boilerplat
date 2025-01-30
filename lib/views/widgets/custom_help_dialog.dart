

import 'package:flutter/material.dart';

void ShowCustomHelpDialog({
  required BuildContext context,
  required String content,
  required String title,
}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return SimpleDialog(
        title: Text(title),
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(content,
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      );
    },
  );
}