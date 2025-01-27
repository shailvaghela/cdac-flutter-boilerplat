import 'package:flutter/material.dart';

Widget customPasswordWidget({
  required TextEditingController textEditController,
  required String hintText,
  bool isPassword = false,
  required bool isPasswordVisible,
  VoidCallback? togglePasswordVisibility,
  bool showPrefixIcon = true,  // Add this parameter to control prefix icon visibility
}) {
  return TextField(
    keyboardType: TextInputType.emailAddress, // You can adjust this based on the use case
    maxLines: 1,
    controller: textEditController,
    obscureText: isPassword ? !isPasswordVisible : false,
    style: const TextStyle(color: Colors.white),
    maxLength: 20,
    decoration: InputDecoration(
      filled: true,
      fillColor: Colors.white.withAlpha((0.1 * 255).toInt()),
      hintText: hintText,
      counterText: "",
      hintStyle: const TextStyle(color: Colors.white70),
      prefixIcon: showPrefixIcon ? Icon(Icons.lock, color: Colors.white70) : null, // Control prefix icon visibility
      suffixIcon: isPassword
          ? IconButton(
        icon: Icon(
          isPasswordVisible ? Icons.visibility : Icons.visibility_off,
          color: Colors.white70,
        ),
        onPressed: togglePasswordVisibility,
      )
          : null,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    ),
  );
}
