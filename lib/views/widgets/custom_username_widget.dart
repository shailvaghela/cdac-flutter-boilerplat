import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

  // build method for UI rendering
Widget customUserNameWidget( {required TextEditingController textEditController, required String hintText, required IconData icon}) {
    return TextField(
      keyboardType: TextInputType.name,
      controller: textEditController,
      maxLines: 1,
      style: const TextStyle(color: Colors.white),
      maxLength: 25,
      inputFormatters: [],
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        counterText: "",
        hintText:  hintText,
        hintStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white70),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
