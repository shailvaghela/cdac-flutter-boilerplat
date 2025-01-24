import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../constants/app_colors.dart';

class CustomTextField extends StatelessWidget {
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
  final String labelText;
  final bool isRequired;
  final bool isNumberWithPrefix; // Flag to determine if specific number regex is required


  const CustomTextField({
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
    required this.labelText,
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
        Row(
          children: [
            Text(labelText, style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(width: 5), // Space between text and image
            isRequired == true
                ? Image.asset(
              'assets/images/asterisk.png', // Path to your asset
              width: 8, // Set the width of the image
              height: 8, // Set the height of the image
            )
                : SizedBox.shrink(),  // If condition is false, don't show the image
          ],
        ),
        SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Container(
            padding: const EdgeInsets.all(4.0),
            decoration: BoxDecoration(
              color: AppColors.greyHundred,
              borderRadius: BorderRadius.circular(12),
            ),
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
                hintText: label,
                border: InputBorder.none,
                filled: true,
                fillColor: AppColors.greyHundred,
                counterText: ""
              ),
            ),
          ),
        ),
      ],
    );
  }
}
