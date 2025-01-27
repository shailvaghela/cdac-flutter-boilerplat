import 'package:flutter/material.dart';

class GradientContainer extends StatelessWidget {
  final Widget? child;
  final List<Color> gradientColors;
  final Alignment begin;
  final Alignment end;
  final double? width; // Optional width
  final double? height; // Optional height

  // ignore: use_super_parameters
  const GradientContainer({
    Key? key,
    this.child,
    this.gradientColors = const [
      Color(0xFF085078),
      Color(0xFF1C6EA4),
      Color(0xFF85D8CE),
    ],
    this.begin = Alignment.topLeft,
    this.end = Alignment.bottomRight,
    this.width, // Default is null
    this.height, // Default is null
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width, // If null, takes the parent's size
      height: height, // If null, takes the parent's size
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: begin,
          end: end,
        ),
      ),
      child: child,
    );
  }

/*
//splash
decoration: BoxDecoration(
  gradient: LinearGradient(
  colors: [Color(0xFF085078),Colors.blue.shade700.withOpacity(0.9), Color(0xFF85D8CE)],//colors: [Colors.blue.shade700, Colors.purple.shade100],
  // Colors.purple.shade300],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  // colors: [Color(0xFF85D8CE), Color(0xFF085078)],
  // begin: Alignment.topCenter,
  // end: Alignment.bottomCenter,
  ),
  ),
  //login
  Container(
            decoration:  BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF085078),Colors.blue.shade700.withOpacity(0.9), Color(0xFF85D8CE)],//  colors: [Color(0xFF85D8CE), Color(0xFF085078)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
  */
}
