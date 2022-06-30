import 'package:flutter/material.dart';

class WidgetPosition {
  final double left;
  final double right;
  final double top;
  final double bottom;

  WidgetPosition({
    required this.left,
    required this.right,
    required this.top,
    required this.bottom,
  });

  Rect getRect() => Rect.fromLTRB(left, top, right, bottom);
}
