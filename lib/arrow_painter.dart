import 'package:flutter/material.dart';
import 'package:flutter_tour/card_position.dart';
import 'package:flutter_tour/arrow_anchor.dart';

import 'widget_position.dart';

class ArrowPainter extends CustomPainter {
  final WidgetPosition widgetPosition;
  final CardPosition cardPosition;
  final ArrowAnchor? widgetAnchors;
  final Color arrowColor;

  ArrowPainter(
      {required this.widgetPosition,
      required this.arrowColor,
      required this.cardPosition,
      required this.widgetAnchors});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = arrowColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // final bool cardPositionRight = (cardPosition.left ?? 0.0) > (cardPosition.right ?? 0.0);
    final bool cardPositionTop = (cardPosition.bottom ?? 0.0) > (cardPosition.top ?? 0.0);
    if (cardPositionTop == true) {

      final controlPointX = widgetAnchors?.arrowControlPoint?.x as double;
      final controlPointY = widgetAnchors?.arrowControlPoint?.y as double;
      final anchorEndX = widgetAnchors?.anchorEnd?.x as double;
      final anchorEndY = widgetAnchors?.anchorEnd?.y as double;

      Path path = Path();
      path.moveTo((widgetAnchors?.anchorStart?.x as double), widgetAnchors?.anchorStart?.y as double);
      path.quadraticBezierTo(controlPointX, controlPointY, anchorEndX, anchorEndY);
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
