import 'package:flutter/material.dart';

class ClipOverlayPainter extends CustomPainter {
  ClipOverlayPainter(
      {this.height,
      this.width,
      this.outerHeight,
      this.outerWidth,
      this.top,
      this.left});
  final double height, width;
  final double outerHeight, outerWidth;
  final double top, left;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    paint.color = Colors.black.withOpacity(.5);
    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()
          ..addRRect(RRect.fromLTRBR(
              0, 0, outerWidth, outerHeight, Radius.circular(0))),
        Path()
          ..addRRect(RRect.fromLTRBR(left, top, left+width, top + height, Radius.circular(0)))
          ..close(),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
