import 'package:flutter/material.dart';

class CustomTextIconButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? iconColor;

  // ignore: use_super_parameters
  const CustomTextIconButton({
    Key? key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.backgroundColor = Colors.transparent,
    this.textColor = Colors.black,
    this.iconColor = Colors.black,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      icon: Icon(
        icon,
        color: iconColor,
      ),
      label: Text(
        label,
        style: TextStyle(color: textColor),
      ),
      onPressed: onPressed,
      style: TextButton.styleFrom(
        backgroundColor: backgroundColor,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
