import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class CustomContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final Color color;
  final double screenWidth;

  // ignore: use_super_parameters
  const CustomContainer({
    Key? key,
    required this.child,
    this.padding = const EdgeInsets.all(16.0),
    this.borderRadius = 16.0,
    this.color = Colors.white,
    required this.screenWidth
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    bool isWeb = kIsWeb || screenWidth > 600;

    return Center(
        child :Container(
          width: isWeb ? screenWidth * 0.3 : screenWidth * 1, // Adjust width for web vs mobile
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          padding: padding,
          child: child,
        )
    );
  }
}
