import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_tour/card_rect.dart';
import 'package:flutter_tour/arrow_anchor.dart';

import 'widget_rect.dart';

class ArrowPainter extends CustomPainter {
  final ArrowConfig arrowConfig;
  final Color arrowColor;

  ArrowPainter({
    required this.arrowConfig,
    required this.arrowColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = arrowColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final anchors = _calculateArrowAnchor();
    final controlPointX = anchors.arrowControlPoint?.x as double;
    final controlPointY = anchors.arrowControlPoint?.y as double;
    final anchorEndX = anchors.anchorEnd?.x as double;
    final anchorEndY = anchors.anchorEnd?.y as double;

    Path path = Path();
    path.moveTo((anchors.anchorStart?.x as double), anchors.anchorStart?.y as double);
    path.quadraticBezierTo(controlPointX, controlPointY, anchorEndX, anchorEndY);
    _buildArrowHead(path, anchorEndX, anchorEndY);
    canvas.drawPath(path, paint);
  }

  void _buildArrowHead(
    Path path,
    double anchorEndX,
    double anchorEndY,
  ) {
    final cardPosition = arrowConfig.cardPosition;
    final cardOnLeft = cardPosition.right == null || (cardPosition.left ?? 0) < (cardPosition.right ?? 0);
    final isLargeWidget = arrowConfig.widgetRect.size.height > arrowConfig.screenSize.height * 0.5;
    final cardOnTop = arrowConfig.cardPosition.bottom == null;

    if (isLargeWidget) {
      path.addPolygon([
        Offset(anchorEndX - 5, anchorEndY + 3),
        Offset(anchorEndX - 3, anchorEndY - 5),
        Offset(anchorEndX + 5, anchorEndY - 3),
      ], false);
    } else if (cardOnTop) {
      path.addPolygon([
        Offset(anchorEndX - 5, anchorEndY - (cardOnLeft ? -3 : 3)),
        Offset(anchorEndX + (cardOnLeft ? -3 : 3), anchorEndY + (cardOnTop ? -5 : 5)),
        Offset(anchorEndX + 5, anchorEndY + (cardOnLeft ? -3 : 3)),
      ], false);
    } else {
      path.addPolygon([
        Offset(anchorEndX - 5, anchorEndY - (cardOnLeft ? 3 : -3)),
        Offset(anchorEndX - (cardOnLeft ? 3 : -3), anchorEndY + 5),
        Offset(anchorEndX + 5, anchorEndY + (cardOnLeft ? 3 : -3)),
      ], false);
    }
  }

  ArrowAnchor _calculateArrowAnchor() {
    ArrowAnchor arrowAnchors = ArrowAnchor(
      anchorStart: const Point(0.0, 0.0),
      anchorEnd: const Point(0.0, 0.0),
      arrowControlPoint: const Point(0.0, 0.0),
    );

    final widgetRect = arrowConfig.widgetRect;
    final isLargeWidget = widgetRect.size.height > arrowConfig.screenSize.height * 0.5;
    final cardPosition = arrowConfig.cardPosition;
    final cardOnTop = cardPosition.bottom == null;
    final cardOnLeft = cardPosition.right == null || (cardPosition.left ?? 0) < (cardPosition.right ?? 0);
    final halfCardHeight = (cardPosition.size?.height ?? 0.0) / 2;
    final cardVerticalPosition = cardPosition.bottom ?? cardPosition.top ?? 0;
    final cardHorizontalPosition =
        cardOnLeft ? cardPosition.left ?? 0 : cardPosition.right ?? 0;

    final startArrowDx = cardOnLeft
        ? cardHorizontalPosition + (cardPosition.size?.width ?? 0)
        : arrowConfig.screenSize.width - (cardPosition.size?.width ?? 0);
    final startArrowDy = cardOnTop
        ? (cardPosition.top ?? 0) + halfCardHeight
        : arrowConfig.screenSize.height - cardVerticalPosition - halfCardHeight;
    arrowAnchors.anchorStart = Point(startArrowDx, startArrowDy);

    final endPositionOnBottomOfWidget = isLargeWidget || cardOnTop;
    final endArrowDx = arrowConfig.widgetRect.left + (arrowConfig.widgetRect.size.width * (cardOnLeft ? 0.9 : 0.1));
    final endArrowDy = endPositionOnBottomOfWidget ? arrowConfig.widgetRect.bottom + 10 : arrowConfig.widgetRect.top
        - 10;
    arrowAnchors.anchorEnd = Point(endArrowDx, endArrowDy);

    final cardWidth = cardPosition.size?.width ?? 0;
    if (cardWidth != 0) {
      final controlPointDx = !cardOnLeft ? startArrowDx - (cardWidth / 2) : startArrowDx + (cardWidth / 2);
      final controlPointDy = endPositionOnBottomOfWidget
          ? arrowConfig.widgetRect.bottom + halfCardHeight
          : arrowConfig.widgetRect.top - halfCardHeight;
      arrowAnchors.arrowControlPoint = Point(controlPointDx, controlPointDy);
    }
    return arrowAnchors;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class ArrowConfig {
  final Size screenSize;
  final WidgetRect widgetRect;
  final CardRect cardPosition;

  ArrowConfig({
    required this.screenSize,
    required this.widgetRect,
    required this.cardPosition,
  });
}
