import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

class CustomCharCountTextField extends StatelessWidget {
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

  const CustomCharCountTextField({
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
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(labelText, style: TextStyle(fontWeight: FontWeight.bold)),
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
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                hintText: label,
                border: InputBorder.none,
                filled: true,
                fillColor: AppColors.greyHundred,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
