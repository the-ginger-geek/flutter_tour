import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_tour/arrow_anchor.dart';

import 'arrow_painter.dart';
import 'card_position.dart';
import 'overlay_painter.dart';
import 'tour_target.dart';
import 'widget_position.dart';

final keyCard = GlobalKey();

class FlutterTour extends StatefulWidget {
  final List<TourTarget> tourTargets;
  final ScrollController? controller;
  final Widget? child;
  final bool? showTour;
  final bool showBackButton;
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
  final void Function()? buttonTwoOnPressed;

  const FlutterTour({
    Key? key,
    required this.tourTargets,
    this.controller,
    this.child,
    this.showTour = false,
    this.showBackButton = false,
    this.cardTitleStyle,
    this.cardDescriptionStyle,
    this.cardBackgroundColor,
    this.cardButtonOneText,
    this.cardOptionalButtonText,
    this.cardButtonTwoText,
    this.cardButtonOneColor,
    this.cardButtonTwoColor,
    this.buttonTwoOnPressed,
    this.cardButtonTwoBorderColor,
    this.cardOptionalButtonColor,
  }) : super(key: key);

  @override
  State<FlutterTour> createState() => _FlutterTourState();
}

class _FlutterTourState extends State<FlutterTour> {
  final double cardWidth = 250;
  bool initialized = false;
  int activePosition = 0;
  late bool? tourVisible;
  CardPosition cardPosition = CardPosition();
  ArrowAnchor? arrowAnchors;

  @override
  void initState() {
    super.initState();
    tourVisible = widget.showTour;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Future.delayed(const Duration(milliseconds: 500), () {
        initialized = true;
        setState(() {});
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (widget.child != null) widget.child as Widget,
        if (_tourVisible())
          CustomPaint(
            painter: OverlayPainter(widgetPosition: _getWidgetPosition()),
            size: MediaQuery.of(context).size,
          ),
        if (_tourVisible())
          CustomPaint(
            painter: ArrowPainter(
                arrowColor: Colors.white,
                cardPosition: cardPosition,
                widgetAnchors: arrowAnchors,
                widgetPosition: _getWidgetPosition()),
            size: MediaQuery.of(context).size,
          ),
        if (_tourVisible())
          Positioned(
            left: cardPosition.left,
            top: cardPosition.top,
            right: cardPosition.right,
            bottom: cardPosition.bottom,
            child: SizedBox(
              width: cardWidth,
              child: Card(
                key: keyCard,
                color: widget.cardBackgroundColor,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Text(widget.tourTargets[activePosition].title,
                          style: widget.cardTitleStyle, textAlign: TextAlign.center),
                      const SizedBox(height: 8.0),
                      Text(widget.tourTargets[activePosition].description,
                          style: widget.cardDescriptionStyle, textAlign: TextAlign.center),
                      const SizedBox(height: 8.0),
                      Row(
                        children: [
                          if (widget.showBackButton)
                            Expanded(
                              child: OutlinedButton(
                                  onPressed: () => _showPreviousWidget(),
                                  style: _buttonStyle(buttonColor: widget.cardOptionalButtonColor),
                                  child: widget.cardOptionalButtonText ?? const Text('')),
                            ),
                          if (widget.showBackButton) const SizedBox(width: 8.0),
                          Expanded(
                            flex: 1,
                            child: OutlinedButton(
                                onPressed: () => _showNextWidget(),
                                style: _buttonStyle(buttonColor: widget.cardButtonOneColor),
                                child: widget.cardButtonOneText ?? const Text('')),
                          ),
                        ],
                      ),
                      const SizedBox(),
                      if (widget.showBackButton) const SizedBox(),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                                onPressed: () {
                                  setState(() {
                                    tourVisible = false;
                                  });
                                },
                                style: _buttonStyle(
                                    buttonColor: widget.cardButtonTwoColor,
                                    buttonBorderColor: widget.cardButtonTwoBorderColor),
                                child: widget.cardButtonTwoText ?? const Text('')),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  bool _tourVisible() => tourVisible == true && initialized;

  void _showNextWidget({bool refreshState = true}) {
    if (activePosition < widget.tourTargets.length - 1) {
      activePosition++;
    } else {
      activePosition = 0;
    }

    final widgetBuildContext = widget.tourTargets[activePosition].key.currentContext;
    if (widgetBuildContext != null) {
      Scrollable.ensureVisible(widgetBuildContext);
    }
    if (refreshState) {
      setState(() {});
    }
  }

  void _showPreviousWidget({bool refreshState = true}) {
    if (activePosition < widget.tourTargets.length - 1 && activePosition > 0) {
      activePosition--;
    } else {
      activePosition = 0;
    }

    final widgetBuildContext = widget.tourTargets[activePosition].key.currentContext;
    if (widgetBuildContext != null) {
      Scrollable.ensureVisible(widgetBuildContext);
    }
    if (refreshState) {
      setState(() {});
    }
  }

  WidgetPosition _getWidgetPosition() {
    final mediaQuery = MediaQuery.of(context);
    final renderBox = widget.tourTargets[activePosition].key.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox?.hasSize ?? false) {
      final offset = ((widget.controller?.hasClients ?? false) ? widget.controller?.offset ?? 0.0 : 0.0);
      final position = renderBox?.localToGlobal(Offset(0, offset));
      if (position != null && renderBox != null) {
        final widgetPosition = WidgetPosition(
          left: position.dx,
          top: position.dy - offset,
          right: position.dx + renderBox.size.width,
          bottom: (position.dy - offset) + renderBox.size.height,
        );

        _positionCard(mediaQuery, widgetPosition, renderBox);
        return widgetPosition;
      }
    } else {
      _showNextWidget(refreshState: false);
      return _getWidgetPosition();
    }

    return WidgetPosition(left: 0, top: 0, right: 0, bottom: 0);
  }

  /*
  currentWidgetTop = widgetTop - scrollOffset (available space on top)
  currentWidgetBottom = (widgetTop + widgetHeight) - scrollOffset
  availableSpaceBottom = screenHeight - currentWidgetBottom
   */

  void _positionCard(MediaQueryData mediaQuery, WidgetPosition widgetPosition, RenderBox targetRenderBox) {
    final halfScreenSize = mediaQuery.size.height / 2;
    final cardHorizontalSpacing = mediaQuery.size.width - cardWidth;
    final validTargetWidget = targetRenderBox.size.height < halfScreenSize;
    if (validTargetWidget) {
      if (widgetPosition.bottom > halfScreenSize) {
        cardPosition = CardPosition(
          left: 16.0,
          right: cardHorizontalSpacing,
          bottom: mediaQuery.size.height - widgetPosition.top,
        );
      } else if (widgetPosition.top < halfScreenSize) {
        cardPosition = CardPosition(
          left: cardHorizontalSpacing,
          right: 16.0,
          top: widgetPosition.bottom,
        );
        final cardRenderBox = keyCard.currentContext?.findRenderObject() as RenderBox?;
        if (cardRenderBox?.hasSize ?? false) {
          final halfCardHeight = (cardRenderBox?.size.height ?? 0.0) / 2;
          final startArrowDx = (cardPosition.right ?? 0.0);
          final startArrowDy = (cardPosition.bottom ?? 0.0) + halfCardHeight;
          arrowAnchors?.anchorStart = Point(startArrowDx, startArrowDy);
          final endArrowDx = widgetPosition.left + (targetRenderBox.size.width * (3 / 4));
          final endArrowDy = widgetPosition.top;
          arrowAnchors?.anchorEnd = Point(endArrowDx, endArrowDy);

          const radian = 90.0 * ((2 * pi) / 360);

          Point controlPoint = Point(halfCardHeight * cos(radian), halfCardHeight * sin(radian));
          arrowAnchors?.arrowControlPoint = controlPoint;
        }
      }
    } else {
      cardPosition = CardPosition(
        left: 16.0,
        bottom: 16.0,
      );
    }
  }

  ButtonStyle _buttonStyle({Color? buttonColor, Color? buttonBorderColor}) {
    return ButtonStyle(
      backgroundColor: MaterialStateProperty.all(buttonColor),
      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18.0),
          side: BorderSide(color: buttonBorderColor ?? Colors.transparent, width: 5.0),
        ),
      ),
    );
  }
}
