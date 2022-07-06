import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_tour/arrow_anchor.dart';
import 'package:flutter_tour/globalkey_extension.dart';

import 'arrow_painter.dart';
import 'card_position.dart';
import 'overlay_painter.dart';
import 'tour_target.dart';
import 'tour_theme.dart';
import 'widget_position.dart';

final keyCard = GlobalKey();

class FlutterTour extends StatefulWidget {
  final List<TourTarget> tourTargets;
  final Widget? child;
  final bool? showTour;
  final TourTheme? tourTheme;
  final void Function()? buttonTwoOnPressed;

  const FlutterTour({
    Key? key,
    required this.tourTargets,
    this.tourTheme,
    this.child,
    this.showTour = false,
    this.buttonTwoOnPressed,
  }) : super(key: key);

  @override
  State<FlutterTour> createState() => _FlutterTourState();
}

class _FlutterTourState extends State<FlutterTour> {
  final double cardWidth = 250;
  int activePosition = 0;
  late bool? tourVisible = true;
  CardPosition cardPosition = CardPosition();
  ArrowAnchor? arrowAnchors;
  List<TourTarget> tourTargets = [];

  @override
  void initState() {
    super.initState();
    // tourVisible = widget.showTour;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      tourTargets.addAll(widget.tourTargets);
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (widget.child != null) widget.child as Widget,
        if (_tourVisible()) _buildOverlayPainter(context),
        if (_tourVisible()) _buildArrowPainter(context),
        if (_tourVisible() && cardPosition.isInitialised) _buildTourCard(),
      ],
    );
  }

  CustomPaint _buildOverlayPainter(BuildContext context) {
    return CustomPaint(
      painter: OverlayPainter(widgetPosition: _getWidgetPosition()),
      size: MediaQuery.of(context).size,
    );
  }

  CustomPaint _buildArrowPainter(BuildContext context) {
    return CustomPaint(
      painter: ArrowPainter(
          arrowColor: Colors.white,
          cardPosition: cardPosition,
          widgetAnchors: arrowAnchors,
          widgetPosition: _getWidgetPosition()),
      size: MediaQuery.of(context).size,
    );
  }

  Positioned _buildTourCard() {
    return Positioned(
      left: cardPosition.left,
      top: cardPosition.top,
      right: cardPosition.right,
      bottom: cardPosition.bottom,
      child: SizedBox(
        width: cardWidth,
        child: Card(
          key: keyCard,
          color: widget.tourTheme?.cardBackgroundColor,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Text(tourTargets[activePosition].title,
                    style: widget.tourTheme?.cardTitleStyle, textAlign: TextAlign.center),
                _buildSpacer(),
                Text(tourTargets[activePosition].description,
                    style: widget.tourTheme?.cardDescriptionStyle, textAlign: TextAlign.center),
                _buildSpacer(),
                _buildNavigationButtons(),
                _buildSkipButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Row _buildSkipButton() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              setState(() {
                tourVisible = false;
              });
            },
            style: _buttonStyle(
              buttonColor: widget.tourTheme?.cardButtonTwoColor,
              buttonBorderColor: widget.tourTheme?.cardButtonTwoBorderColor,
            ),
            child: widget.tourTheme?.cardButtonTwoText ?? const Text('Skip'),
          ),
        ),
      ],
    );
  }

  Row _buildNavigationButtons() {
    return Row(
      children: [
        if (widget.tourTheme?.showBackButton ?? false)
          Expanded(
            child: OutlinedButton(
              onPressed: () => _showPreviousWidget(),
              style: _buttonStyle(buttonColor: widget.tourTheme?.cardOptionalButtonColor),
              child: widget.tourTheme?.cardOptionalButtonText ?? const Text('Back'),
            ),
          ),
        if (widget.tourTheme?.showBackButton ?? false) const SizedBox(width: 8.0),
        Expanded(
          flex: 1,
          child: OutlinedButton(
            onPressed: () => _showNextWidget(),
            style: _buttonStyle(buttonColor: widget.tourTheme?.cardButtonOneColor),
            child: widget.tourTheme?.cardButtonOneText ?? const Text('Next'),
          ),
        ),
      ],
    );
  }

  SizedBox _buildSpacer() => const SizedBox(height: 8.0);

  bool _tourVisible() => tourVisible == true && tourTargets.isNotEmpty;

  void _showNextWidget({bool refreshState = true}) {
    if (activePosition < tourTargets.length - 1) {
      activePosition++;
    } else {
      activePosition = 0;
    }

    final widgetBuildContext = tourTargets[activePosition].key.currentContext;
    if (widgetBuildContext != null) {
      Scrollable.ensureVisible(widgetBuildContext);
    }
    if (refreshState) {
      setState(() {});
    }
  }

  void _showPreviousWidget({bool refreshState = true}) {
    if (activePosition < tourTargets.length - 1 && activePosition > 0) {
      activePosition--;
    } else {
      activePosition = 0;
    }

    final widgetBuildContext = tourTargets[activePosition].key.currentContext;
    if (widgetBuildContext != null) {
      Scrollable.ensureVisible(widgetBuildContext);
    }
    if (refreshState) {
      setState(() {});
    }
  }

  WidgetPosition _getWidgetPosition() {
    if (tourTargets.isNotEmpty && tourTargets.length > activePosition) {
      final mediaQuery = MediaQuery.of(context);
      final key = tourTargets[activePosition].key;
      final renderBox = key.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox?.hasSize ?? false) {
        final position = key.globalPaintBounds;
        if (position != null && renderBox != null) {
          final widgetPosition = WidgetPosition(
            left: position.left,
            top: position.top,
            right: position.right,
            bottom: position.bottom,
          );

          _positionCard(mediaQuery, widgetPosition, renderBox);
          return widgetPosition;
        }
      } else {
        _showNextWidget(refreshState: false);
        return _getWidgetPosition();
      }
    }

    return WidgetPosition(left: 0, top: 0, right: 0, bottom: 0);
  }

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
