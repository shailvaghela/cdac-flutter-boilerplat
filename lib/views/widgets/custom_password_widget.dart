import 'package:flutter/material.dart';

Widget customPasswordWidget({
    required TextEditingController textEditController,
    required String hintText,
    required IconData icon,
    bool isPassword = false,
    required bool isPasswordVisible,
    VoidCallback? togglePasswordVisibility
  }) {
    return TextField(
      keyboardType: TextInputType.emailAddress,
      maxLines: 1,
      controller: textEditController,
      obscureText: isPassword ? !(isPasswordVisible) : false,
      style: const TextStyle(color: Colors.white),
      maxLength: 20,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white.withAlpha((0.1*255).toInt()),
        hintText:  hintText,
        counterText: "",
        hintStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white70),
        suffixIcon:  isPassword
            ? IconButton(
          icon: Icon(
           isPasswordVisible ? Icons.visibility : Icons.visibility_off,
            color: Colors.white70,
          ),
          onPressed:  togglePasswordVisibility,
        )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
