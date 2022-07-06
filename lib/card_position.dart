class CardPosition {
  final double? left;
  final double? right;
  final double? top;
  final double? bottom;

  CardPosition({
    this.left,
    this.right,
    this.top,
    this.bottom,
  });

  bool get isInitialised => left != null || right != null || top != null || bottom != null;
}
