import 'package:flutter/material.dart';

class NoteWidget extends StatelessWidget {
  final String noteText;
   String? noteTextTitle;

   NoteWidget({Key? key, this.noteTextTitle, required this.noteText}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: noteTextTitle,
            style: TextStyle(
                fontWeight: FontWeight.bold, color: Colors.red),
          ),
          TextSpan(text:noteText),
        ],
      ),
    );

  }
}
