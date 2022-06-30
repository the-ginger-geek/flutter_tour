import 'package:flutter/material.dart';

import 'card_position.dart';
import 'painter.dart';
import 'tour_target.dart';
import 'widget_position.dart';

class FlutterTour extends StatefulWidget {
  final List<TourTarget> tourTargets;
  final ScrollController? controller;

  const FlutterTour({Key? key, required this.tourTargets, this.controller}) : super(key: key);

  @override
  State<FlutterTour> createState() => _FlutterTourState();
}

class _FlutterTourState extends State<FlutterTour> {
  final double cardWidth = 250;
  int activePosition = 0;
  CardPosition cardPosition = CardPosition();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Stack(
      children: [
        CustomPaint(
          painter: Painter(widgetPosition: _getWidgetPosition()),
          size: size,
        ),
        Positioned(
          left: cardPosition.left,
          top: cardPosition.top,
          right: cardPosition.right,
          bottom: cardPosition.bottom,
          child: SizedBox(
            width: cardWidth,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Text(widget.tourTargets[activePosition].title),
                    Text(widget.tourTargets[activePosition].description),
                    OutlinedButton(onPressed: () => _showNextWidget(), child: const Text('Next'))
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future _showNextWidget() async {
    if (activePosition < widget.tourTargets.length - 1) {
      activePosition++;
    } else {
      activePosition = 0;
    }

    final widgetBuildContext = widget.tourTargets[activePosition].key.currentContext;
    if (widgetBuildContext != null) {
      Scrollable.ensureVisible(widgetBuildContext);
    }
    setState(() {});
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
}
