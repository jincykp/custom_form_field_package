import 'package:flutter/material.dart';

/// Custom painter for drawing the required field indicator (asterisk)
class RequiredIndicatorPainter extends CustomPainter {
  final Color color;
  final double size;

  const RequiredIndicatorPainter({required this.color, required this.size});

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Draw asterisk symbol
    final textPainter = TextPainter(
      text: TextSpan(
        text: '*',
        style: TextStyle(
          color: color,
          fontSize: size,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(canvas, const Offset(2, -2));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is RequiredIndicatorPainter &&
        (oldDelegate.color != color || oldDelegate.size != size);
  }
}
