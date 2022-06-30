import 'package:flutter/material.dart';
import 'package:flutter_tour/flutter_tour.dart';
import 'package:flutter_tour/tour_target.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  ScrollController scrollController = ScrollController();

  final colors = [
    Colors.amber,
    Colors.redAccent,
    Colors.blueAccent,
    Colors.cyan,
    Colors.deepOrangeAccent,
    Colors.deepPurpleAccent,
    Colors.green,
    Colors.pinkAccent,
    Colors.amberAccent,
    Colors.red,
    Colors.blue,
    Colors.deepOrange,
  ];

  final sizes = [
    100.0,
    100.0,
    100.0,
    100.0,
    100.0,
    100.0,
    100.0,
    100.0,
  ];

  final GlobalKey appBarkey = GlobalKey();
  final GlobalKey bottomBarkey = GlobalKey();
  final GlobalKey bottomBarItem1key = GlobalKey();
  final GlobalKey bottomBarItem2key = GlobalKey();
  final GlobalKey bottomBarItem3key = GlobalKey();

  final keys = [
    GlobalKey(),
    GlobalKey(),
    GlobalKey(),
    GlobalKey(),
    GlobalKey(),
    GlobalKey(),
    GlobalKey(),
    GlobalKey(),
  ];

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            key: appBarkey,
            title: Text(widget.title),
          ),
          bottomNavigationBar: Material(
            key: bottomBarkey,
            elevation: 4.0,
            child: Container(
              height: 65.0,
              color: Colors.blueGrey,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(child: _buildNavBarItem(bottomBarItem1key, 1)),
                  Expanded(child: _buildNavBarItem(bottomBarItem2key, 2)),
                  Expanded(child: _buildNavBarItem(bottomBarItem3key, 3)),
                ],
              ),
            ),
          ),
          body: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                keys.length,
                    (index) => _buildText(index),
              ),
            ),
          ),
        ),
        FlutterTour(tourTargets: _getTargets()),
      ],
    );
  }

  Widget _buildText(int index) {
    return Container(
      key: keys[index],
      color: colors[index],
      width: MediaQuery.of(context).size.width,
      height: sizes[index],
      alignment: Alignment.center,
      child: Text(
        'This is text position $index',
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 18.0,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildNavBarItem(Key key, int i) {
    return Container(
      key: key,
      height: 55.0,
      alignment: Alignment.center,
      child: Text(
        'Item $i',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  List<TourTarget> _getTargets() {
    List<TourTarget> targets = [TourTarget(key: appBarkey, title: 'App Bar', description: 'This is the app bar')];
    for (int i = 0; i < keys.length; i++) {
      targets.add(TourTarget(key: keys[i], title: 'Item $i', description: 'Description for item $i'));
    }
    targets.add(TourTarget(key: bottomBarkey, title: 'Bottom Nav Bar', description: 'This is the bottom nav bar'));
    targets.add(TourTarget(key: bottomBarItem1key, title: 'Item 1', description: 'This is the bottom nav bar item 1'));
    targets.add(TourTarget(key: bottomBarItem2key, title: 'Item 2', description: 'This is the bottom nav bar item 2'));
    targets.add(TourTarget(key: bottomBarItem3key, title: 'Item 3', description: 'This is the bottom nav bar item 3'));

    return targets;
  }
}
