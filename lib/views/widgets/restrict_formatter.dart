import 'package:flutter/services.dart';

class RestrictedWordFormatter extends TextInputFormatter {
  final RegExp restrictedPattern;

  RestrictedWordFormatter({required String restrictedRegex})
      : restrictedPattern = RegExp(restrictedRegex);

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // If the new value matches the restricted pattern, reject the change
    if (restrictedPattern.hasMatch(newValue.text)) {
      return oldValue; // Reject the change
    }
    // Otherwise, allow the new value
    return newValue;
  }
}