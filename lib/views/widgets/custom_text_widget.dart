import 'package:flutter/material.dart';

class CustomTextWidget extends StatelessWidget {
  final String text;
  final Color color;
  final double fontSize;
  final FontWeight fontWeight;
  final TextAlign textAlign;
  final TextOverflow overflow;
  final String? fontFamily;

  // Constructor to initialize the parameters
  const CustomTextWidget({
    Key? key,
    required this.text,
    this.color = Colors.black, // Default color
    this.fontSize = 16.0, // Default font size
    this.fontWeight = FontWeight.normal, // Default font weight
    this.textAlign = TextAlign.start, // Default text alignment
    this.overflow = TextOverflow.ellipsis, // Default overflow behavior
    this.fontFamily = 'Montserrat',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: color,
        fontSize: fontSize,
        fontWeight: fontWeight,
        fontFamily: fontFamily, // Explicitly include fontFamily
      ),
      textAlign: textAlign,
      overflow: overflow,
    );
  }
}
