import 'package:flutter/material.dart';

import 'card_position.dart';
import 'painter.dart';
import 'tour_target.dart';
import 'widget_position.dart';

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
            painter: Painter(widgetPosition: _getWidgetPosition()),
            size: MediaQuery
                .of(context)
                .size,
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
                          Expanded(
                            child: OutlinedButton(
                                onPressed: () => _showNextWidget(),
                                style: _buttonStyle(buttonColor: widget.cardButtonOneColor),
                                child: widget.cardButtonOneText ?? const Text('')),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8.0),
                      if (widget.showBackButton)
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                  onPressed: () => _showPreviousWidget(),
                                  style: _buttonStyle(buttonColor: widget.cardOptionalButtonColor),
                                  child: widget.cardOptionalButtonText ?? const Text('')),
                            ),
                          ],
                        ),
                      if (widget.showBackButton)
                        const SizedBox(
                          height: 8.0,
                        ),
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
          )
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

        _positionCard(mediaQuery, widgetPosition);
        return widgetPosition;
      }
    } else {
      _showNextWidget(refreshState: false);
      return _getWidgetPosition();
    }

    return WidgetPosition(left: 0, top: 0, right: 0, bottom: 0);
  }

  void _positionCard(MediaQueryData mediaQuery, WidgetPosition widgetPosition) {
    final halfScreenSize = mediaQuery.size.height / 2;
    final cardHorizontalSpacing = mediaQuery.size.width - cardWidth;
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
