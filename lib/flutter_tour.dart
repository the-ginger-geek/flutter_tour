import 'package:flutter/material.dart';
import 'package:flutter_tour/globalkey_extension.dart';

import 'arrow_painter.dart';
import 'card_rect.dart';
import 'overlay_painter.dart';
import 'tour_target.dart';
import 'tour_theme.dart';
import 'widget_rect.dart';

final keyCard = GlobalKey();

class FlutterTour extends StatefulWidget {
  final List<TourTarget> tourTargets;
  final Widget? child;
  final bool? showTour;
  final TourTheme? tourTheme;
  final void Function()? completeCallback;

  const FlutterTour({
    Key? key,
    required this.tourTargets,
    this.tourTheme,
    this.child,
    this.showTour = false,
    this.completeCallback,
  }) : super(key: key);

  @override
  State<FlutterTour> createState() => FlutterTourState();
}

class FlutterTourState extends State<FlutterTour> {
  final double cardWidth = 250;
  int activePosition = 0;
  late bool? tourVisible = true;
  CardRect cardRect = CardRect();
  List<TourTarget> tourTargets = [];

  @override
  void initState() {
    super.initState();
    tourVisible = widget.showTour;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      tourTargets.addAll(widget.tourTargets);
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final widgetRect = _getWidgetRect();
    // Card is drawn after the initial render so we need to wait for it to be drawn before we can get size
    final cardRenderBox = keyCard.currentContext?.findRenderObject() as RenderBox?;
    return Stack(
      children: [
        if (widget.child != null) widget.child as Widget,
        if (_tourVisible()) _buildOverlayPainter(context, widgetRect),
        if (_tourVisible() && (cardRenderBox?.hasSize ?? false))
          _buildArrowPainter(
            context,
            widgetRect,
            cardRenderBox?.size,
          ),
        if (_tourVisible() && cardRect.isInitialised) _buildTourCard(),
      ],
    );
  }

  void showTour(bool show) {
    tourVisible = show;
    setState(() {});
  }

  void updateTargets(List<TourTarget> targets) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      tourTargets.clear();
      tourTargets.addAll(targets);
      setState(() {});
    });
  }

  CustomPaint _buildOverlayPainter(BuildContext context, WidgetRect widgetRect) {
    return CustomPaint(
      painter: OverlayPainter(widgetRect: widgetRect),
      size: MediaQuery
          .of(context)
          .size,
    );
  }

  CustomPaint _buildArrowPainter(BuildContext context, WidgetRect widgetRect, Size? cardSize) {
    return CustomPaint(
      painter: ArrowPainter(
        arrowColor: Colors.white,
        arrowConfig: ArrowConfig(
          cardPosition: cardRect..size = cardSize ?? const Size(0, 0),
          widgetRect: widgetRect,
          screenSize: MediaQuery
              .of(context)
              .size,
        ),
      ),
      size: MediaQuery
          .of(context)
          .size,
    );
  }

  Widget _buildTourCard() {
    return Positioned(
      left: cardRect.left,
      top: cardRect.top,
      right: cardRect.right,
      bottom: cardRect.bottom,
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
    final isLastButton = activePosition == tourTargets.length - 1;
    return Row(
      children: [
        if (!isLastButton)
          Expanded(
            child: OutlinedButton(
              onPressed: _endTour,
              style: OutlinedButton.styleFrom(
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(24)),
                ),
                backgroundColor: widget.tourTheme?.cardButtonSkipColor,
                side: BorderSide(
                  color: widget.tourTheme?.cardButtonSkipBorderColor ?? Colors.black,
                  width: 0.8,
                ),
              ),
              child: widget.tourTheme?.cardButtonSkipText ?? const Text('Skip'),
            ),
          ),
      ],
    );
  }

  Row _buildNavigationButtons() {
    final isNotLastButton = activePosition < tourTargets.length - 1;
    final backButtonVisible = (widget.tourTheme?.showBackButton ?? false) && activePosition > 0;
    return Row(
      children: [
        if (backButtonVisible)
          Expanded(
            child: OutlinedButton(
              onPressed: () => _showPreviousWidget(),
              style: _buttonStyle(buttonColor: widget.tourTheme?.cardButtonBackColor),
              child: widget.tourTheme?.cardButtonBackText ?? const Text('Back'),
            ),
          ),
        if (backButtonVisible) const SizedBox(width: 8.0),
        Expanded(
          flex: 1,
          child: OutlinedButton(
            onPressed: isNotLastButton ? () => _showNextWidget() : _endTour,
            style: _buttonStyle(buttonColor: isNotLastButton ? widget.tourTheme?.cardButtonNextColor : widget.tourTheme
                ?.cardButtonFinishColor),
            child: isNotLastButton ? widget.tourTheme?.cardButtonNextText ?? const Text('Next') :
            widget.tourTheme?.cardButtonFinishText ?? const Text('Finish'),
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
    if (activePosition < tourTargets.length && activePosition > 0) {
      activePosition--;
    }

    final widgetBuildContext = tourTargets[activePosition].key.currentContext;
    if (widgetBuildContext != null) {
      Scrollable.ensureVisible(widgetBuildContext);
    }
    if (refreshState) {
      setState(() {});
    }
  }

  WidgetRect _getWidgetRect() {
    if (tourTargets.isNotEmpty && tourTargets.length > activePosition) {
      final key = tourTargets[activePosition].key;
      final renderBox = key.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox?.hasSize ?? false) {
        final position = key.globalPaintBounds;
        if (position != null && renderBox != null) {
          final widgetRect = WidgetRect(
            left: position.left,
            top: position.top,
            right: position.right,
            bottom: position.bottom,
            size: renderBox.size,
          );

          _positionCard(widgetRect);
          return widgetRect;
        }
      }
    }

    return WidgetRect(
      left: 0,
      top: 0,
      right: 0,
      bottom: 0,
      size: const Size(0.0, 0.0),
    );
  }

  void _positionCard(WidgetRect widgetRect) {
    final screenSize = MediaQuery
        .of(context)
        .size;
    final halfScreenSize = screenSize.height / 2;
    final cardHorizontalSpacing = screenSize.width - cardWidth;
    final validTargetWidget = widgetRect.size.height < halfScreenSize;
    if (validTargetWidget) {
      if (widgetRect.bottom > halfScreenSize) {
        const padding = 16.0;
        final drawCardOnRight = widgetRect.right < (padding + cardHorizontalSpacing);
        final bottom = screenSize.height - widgetRect.top;
        cardRect = CardRect(
          left: drawCardOnRight ? cardHorizontalSpacing : padding,
          right: drawCardOnRight ? padding : cardHorizontalSpacing,
          bottom: bottom,
        );
      } else if (widgetRect.top < halfScreenSize) {
        const padding = 16.0;
        final drawCardOnRight = widgetRect.right < (padding + cardHorizontalSpacing);
        final top = widgetRect.bottom;
        cardRect = CardRect(
          left: drawCardOnRight ? cardHorizontalSpacing : padding,
          right: drawCardOnRight ? padding : cardHorizontalSpacing,
          top: top,
        );
      }
    } else {
      cardRect = CardRect(
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

  void _endTour() {
    setState(() {
      tourVisible = false;
    });
    widget.completeCallback?.call();
  }
}
