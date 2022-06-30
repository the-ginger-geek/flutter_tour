import 'package:flutter/material.dart';

import 'widget_position.dart';

class Painter extends CustomPainter {
  final WidgetPosition widgetPosition;

  Painter({required this.widgetPosition});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..color = Colors.black54.withOpacity(0.5);
    canvas.drawPath(
        Path.combine(
          PathOperation.difference,
          Path()
            ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
            ..close(),
          Path()..addRRect(RRect.fromRectAndRadius(widgetPosition.getRect(),const Radius.circular(15.0))),
        ),
        paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
