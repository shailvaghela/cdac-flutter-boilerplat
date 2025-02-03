import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextFieldRegister extends StatelessWidget {
  final String label;
  final String? value;
  final Function(String)? onChanged;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final int maxLines;
  final int? maxLength;
  final TextEditingController? controller;
  final bool readOnly;
  final VoidCallback? onTap;
  final bool isRequired;
  final bool isNumberWithPrefix; // Flag to determine if specific number regex is required


  // ignore: use_super_parameters
  const CustomTextFieldRegister({
    Key? key,
    required this.label,
    this.value,
    this.onChanged,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.maxLength,
    this.controller,
    this.readOnly = false,
    this.onTap,
    required this.isRequired,
    this.isNumberWithPrefix = false, // Default to false
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<TextInputFormatter> inputFormatters = [];

    if (keyboardType == TextInputType.number) {
      if(isNumberWithPrefix){
        inputFormatters = [
          FilteringTextInputFormatter.allow(RegExp(r'^[987][0-9]*$')), // Only allow numbers starting with 9, 8, or 7
          LengthLimitingTextInputFormatter(maxLength), // Restrict the length of input
        ];
      }
      else{
        inputFormatters = [
          FilteringTextInputFormatter.allow(RegExp(r'[0-9]*$')), // Only allow numbers starting with 9, 8, or 7
          LengthLimitingTextInputFormatter(maxLength), // Restrict the length of input
        ];
      }
    }
    else if (keyboardType == TextInputType.name) {
      inputFormatters = [
        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')), // Allow letters, spaces, and hyphen
      ];
    }
    else if (keyboardType == TextInputType.text) {
      inputFormatters = [
        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s\-]')), // Allow letters, spaces, and hyphen
      ];
    }
    else if (keyboardType == TextInputType.emailAddress) {
      inputFormatters = [
        FilteringTextInputFormatter.allow(r'^[a-zA-Z0-9\s,.-/#]+$'), // Allow letters, spaces, and hyphen
      ];
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          // ignore: avoid_unnecessary_containers
          child: Container(
            child: TextFormField(
              controller: controller,
              onChanged: onChanged,
              maxLines: maxLines,
              maxLength: maxLength,
              keyboardType: keyboardType,
              validator: validator,
              readOnly: readOnly,
              onTap: onTap,
              inputFormatters:inputFormatters,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white.withAlpha((0.1*255).toInt()),
                counterText: "",
                hintText:  label,
                hintStyle: const TextStyle(color: Colors.white70),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
