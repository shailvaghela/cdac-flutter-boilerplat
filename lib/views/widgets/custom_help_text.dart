import 'package:flutter/material.dart';

class CustomHelpTextWidget extends StatelessWidget {
  final String text;
  final Color color;
  final double fontSize;
  final FontWeight fontWeight;
  final TextAlign textAlign;
  final TextOverflow overflow;
  final String? fontFamily;

  // Constructor to initialize the parameters
  // ignore: use_super_parameters
  const CustomHelpTextWidget({
    Key? key,
    required this.text,
    required this.color, // Default color
    required this.fontSize, // Default font size
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
