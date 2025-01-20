import 'package:flutter/material.dart';

class SearchTextField extends StatelessWidget {
  final String labelText;
  final Color fillColor;
  final Color borderColor;
  final double borderRadius;
  final IconData prefixIcon;
  final Function(String)? onChanged;
  final TextEditingController? controller;

  const SearchTextField({
    Key? key,
    this.labelText = 'Search...',
    this.fillColor = Colors.white,
    this.borderColor = Colors.blueAccent,
    this.borderRadius = 12.0,
    this.prefixIcon = Icons.search,
    this.onChanged,
    this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: fillColor,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: labelText,
            prefixIcon: Icon(prefixIcon, color: borderColor),
            border: InputBorder.none,
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: borderColor, width: 1.5),
              borderRadius: BorderRadius.circular(borderRadius),
            ),
          ),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
