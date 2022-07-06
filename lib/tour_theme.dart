import 'package:flutter/material.dart';

class TourTheme {
  final TextStyle? cardTitleStyle;
  final TextStyle? cardDescriptionStyle;
  final Color? cardBackgroundColor;
  final Text? cardButtonOneText;
  final Text? cardOptionalButtonText;
  final Text? cardButtonTwoText;
  final Color? cardButtonOneColor;
  final Color? cardButtonTwoColor;
  final Color? cardOptionalButtonColor;
  final Color? cardButtonTwoBorderColor;
  final bool? showBackButton;

  TourTheme({
    this.cardTitleStyle,
    this.cardDescriptionStyle,
    this.cardBackgroundColor,
    this.cardButtonOneText,
    this.cardOptionalButtonText,
    this.cardButtonTwoText,
    this.cardButtonOneColor,
    this.cardButtonTwoColor,
    this.cardOptionalButtonColor,
    this.cardButtonTwoBorderColor,
    this.showBackButton,
  });
}
