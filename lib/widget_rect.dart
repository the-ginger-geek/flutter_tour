import 'package:flutter/material.dart';

class WidgetRect {
  final double left;
  final double right;
  final double top;
  final double bottom;
  final Size size;

  WidgetRect({
    required this.left,
    required this.right,
    required this.top,
    required this.bottom,
    required this.size,
  });

  Rect getRect() => Rect.fromLTRB(left, top, right, bottom);
}
