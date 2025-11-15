import 'package:flutter/material.dart';

class NeonBackground extends StatelessWidget {
  final double width;
  final double height;
  final Alignment alignment;
  final Animation<double> animation;
  final List<Color> colors;

  const NeonBackground({
    super.key,
    required this.width,
    required this.height,
    required this.alignment,
    required this.animation,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: animation.value,
      child: Container(
        width: width * 1.5,
        height: height * 1.5,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors,
            begin: alignment,
            end: -alignment,
          ),
        ),
      ),
    );
  }
}