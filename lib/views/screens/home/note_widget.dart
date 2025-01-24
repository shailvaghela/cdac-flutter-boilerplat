import 'package:flutter/material.dart';

// ignore: must_be_immutable
class NoteWidget extends StatelessWidget {
  final String noteText;
   String? noteTextTitle;

   // ignore: use_super_parameters
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
