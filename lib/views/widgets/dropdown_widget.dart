import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';

class DropdownWidget extends StatelessWidget {
  final String labelText;
  final List<String> items;
  final String? selectedItem;
  final void Function(String?) onChanged;

  const DropdownWidget({
    Key? key,
    required this.labelText,
    required this.items,
    required this.selectedItem,
    required this.onChanged,
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
            padding: EdgeInsets.all(4.0),
            decoration: BoxDecoration(
              color: AppColors.greyHundred,
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonFormField<String>(
              value: selectedItem,
              items: items
                  .map((item) => DropdownMenuItem(
                value: item,
                child: Text(item),
              ))
                  .toList(),
              onChanged: onChanged,
              decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.greyHundred,
                  border: InputBorder.none

              ),
            ),
          ),
        ),
      ],
    );
  }
}
