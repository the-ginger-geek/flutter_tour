import 'package:flutter/material.dart';

class TourTheme {
  final TextStyle? cardTitleStyle;
  final TextStyle? cardDescriptionStyle;
  final Color? cardBackgroundColor;
  final Text? cardButtonNextText;
  final Color? cardButtonNextColor;
  final Text? cardButtonBackText;
  final Color? cardButtonBackColor;
  final bool? showBackButton;
  final Text? cardButtonSkipText;
  final Color? cardButtonSkipColor;
  final Color? cardButtonSkipBorderColor;
  final Text? cardButtonFinishText;
  final Color? cardButtonFinishColor;

  TourTheme({
    this.cardTitleStyle,
    this.cardDescriptionStyle,
    this.cardBackgroundColor,
    this.cardButtonNextText,
    this.cardButtonBackText,
    this.cardButtonSkipText,
    this.cardButtonNextColor,
    this.cardButtonSkipColor,
    this.cardButtonBackColor,
    this.cardButtonSkipBorderColor,
    this.showBackButton,
    this.cardButtonFinishText,
    this.cardButtonFinishColor,
  });
}
