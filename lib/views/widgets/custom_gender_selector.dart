import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import 'custom_text_widget.dart';

class CustomGenderSelector extends StatelessWidget {
  final String? selectedGender;
  final ValueChanged<String?> onGenderChanged;
  final List<String> genderOptions;
  final String labelText;
  final bool isRequired;


  const CustomGenderSelector({
    Key? key,
    required this.selectedGender,
    required this.onGenderChanged,
    this.genderOptions = const ['Male', 'Female'], // Default options
    required this.labelText,
    required this.isRequired

  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(labelText, style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(width: 5), // Space between text and image
            isRequired == true?Text("*", style: TextStyle(fontWeight: FontWeight.bold,color: Colors.red)): SizedBox.shrink(),

          ],
        ),
        SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Container(
            padding: const EdgeInsets.all(4.0),
            decoration: BoxDecoration(
              color: AppColors.greyHundred,
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Row(
                  //mainAxisSize: MainAxisSize.max,
                  children: genderOptions.map((gender) {
                    return _buildGenderOption(
                      label: gender,
                      value: gender,
                      groupValue: selectedGender,
                      onChanged: onGenderChanged,
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderOption({
    required String label,
    required String value,
    required String? groupValue,
    required ValueChanged<String?> onChanged,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Radio<String>(
          activeColor: Colors.blue.shade700.withOpacity(0.8),
          value: value,
          groupValue: groupValue,
          onChanged: onChanged,
        ),
        Text(label),
      ],
    );
  }
}
