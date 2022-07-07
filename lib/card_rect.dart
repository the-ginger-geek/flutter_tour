import 'dart:ui';

class CardRect {
  final double? left;
  final double? right;
  final double? top;
  final double? bottom;
  Size? size;

  CardRect({
    this.left,
    this.right,
    this.top,
    this.bottom,
    this.size,
  });

  bool get isInitialised => left != null || right != null || top != null || bottom != null;
}
