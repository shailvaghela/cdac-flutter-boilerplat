import 'package:flutter/material.dart';
// ignore: unnecessary_import
import 'package:flutter/services.dart';

  // build method for UI rendering
Widget customUserNameWidget( {required TextEditingController textEditController, required String hintText, required IconData icon}) {
    return TextField(
      keyboardType: TextInputType.name,
      controller: textEditController,
      maxLines: 1,
      style: const TextStyle(color: Colors.white),
      maxLength: 25,
      // inputFormatters: [
      //   FilteringTextInputFormatter.allow(RegExp(r'^[a-zA-Z0-9][a-zA-Z0-9_-]{2,18}[a-zA-Z0-9]$')), // Allow letters, spaces, and hyphen
      // ],
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white.withAlpha((0.1*255).toInt()),
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
