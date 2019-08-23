//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// © Cosmos Software | Ali Yigit Bireroglu                                                                                                           /
// All material used in the making of this code, project, program, application, software et cetera (the "Intellectual Property")                     /
// belongs completely and solely to Ali Yigit Bireroglu. This includes but is not limited to the source code, the multimedia and                     /
// other asset files. If you were granted this Intellectual Property for personal use, you are obligated to include this copyright                   /
// text at all times.                                                                                                                                /
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//@formatter:off

import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:snap/snap.dart';

List<GlobalKey> bounds = List<GlobalKey>();
List<GlobalKey> views = List<GlobalKey>();

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Snap Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: MyHomePage(title: 'Snap Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  double bottom = -200.0;

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 6; i++) {
      bounds.add(GlobalKey());
      views.add(GlobalKey());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: PageView(
        onPageChanged: (int index) {
          if (index == 1)
            setState(() {
              bottom = 0.0;
            });
          else
            setState(() {
              bottom = -200.0;
            });
        },
        children: [
          Scaffold(
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                description("The box will snap to the corners or the center."),
                gap(),
                Expanded(
                  child: Align(
                    key: bounds[0],
                    alignment: const Alignment(-1.0, -1.0),
                    child: SnapController(
                      firstNormalBoxView(),
                      true,
                      views[0],
                      bounds[0],
                      Offset.zero,
                      const Offset(1.0, 1.0),
                      const Offset(0.75, 0.75),
                      const Offset(0.75, 0.75),
                      snapTargets: [
                        const SnapTarget(Pivot.topLeft, Pivot.topLeft),
                        const SnapTarget(Pivot.topRight, Pivot.topRight),
                        const SnapTarget(Pivot.bottomLeft, Pivot.bottomLeft),
                        const SnapTarget(Pivot.bottomRight, Pivot.bottomRight),
                        const SnapTarget(Pivot.center, Pivot.center),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Scaffold(
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                description("The box will snap to the closest side regardless of animation."),
                gap(),
                Expanded(
                  child: Align(
                    key: bounds[1],
                    alignment: const Alignment(-1.0, -1.0),
                    child: Stack(
                      children: [
                        AnimatedPositioned(
                          left: 0,
                          bottom: bottom,
                          duration: Duration(milliseconds: 300),
                          child: SnapController(
                            animatedBoxView(),
                            true,
                            views[1],
                            bounds[1],
                            Offset.zero,
                            const Offset(1.0, 1.0),
                            const Offset(0.75, 0.75),
                            const Offset(0.75, 0.75),
                            snapTargets: [
                              const SnapTarget(Pivot.closestAny, Pivot.closestAny),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Scaffold(
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                description("The box will snap to the closest matching color."),
                gap(),
                Expanded(
                  child: Stack(
                    children: [
                      Align(
                        key: bounds[2],
                        alignment: const Alignment(-1.0, -1.0),
                        child: SnapController(
                          dottedBoxView(),
                          true,
                          views[2],
                          bounds[2],
                          Offset.zero,
                          const Offset(1.0, 1.0),
                          const Offset(0.75, 0.75),
                          const Offset(0.75, 0.75),
                          snapTargets: [
                            const SnapTarget(const Offset(0.1, 0.1), const Offset(0.1, 0.1)),
                            const SnapTarget(const Offset(0.9, 0.1), const Offset(0.85, 0.465)),
                            const SnapTarget(const Offset(0.1, 0.9), const Offset(0.1, 0.9)),
                          ],
                        ),
                      ),
                      Align(
                        alignment: const Alignment(-0.85, -0.85),
                        child: Container(
                          width: 10,
                          height: 10,
                          color: Colors.orangeAccent,
                        ),
                      ),
                      Align(
                        alignment: const Alignment(0.75, -0.1),
                        child: Container(
                          width: 10,
                          height: 10,
                          color: Colors.black,
                        ),
                      ),
                      Align(
                        alignment: const Alignment(-0.85, 0.85),
                        child: Container(
                          width: 10,
                          height: 10,
                          color: Colors.deepPurpleAccent,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Scaffold(
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                description("The box will snap to the corners or the center while maintaining the initial offset"),
                gap(),
                Expanded(
                  child: Align(
                    key: bounds[3],
                    alignment: const Alignment(-1.0, -1.0),
                    child: SnapController(
                      translatedBoxView(),
                      true,
                      views[3],
                      bounds[3],
                      Offset(50.0 / MediaQuery.of(context).size.width, 50.0 / MediaQuery.of(context).size.height),
                      Offset(1.0, 1.0) - Offset(50.0 / MediaQuery.of(context).size.width, 50.0 / MediaQuery.of(context).size.height),
                      const Offset(0.75, 0.75),
                      const Offset(0.75, 0.75),
                      snapTargets: [
                        SnapTarget(Pivot.topLeft, Offset(50.0 / MediaQuery.of(context).size.width, 50.0 / MediaQuery.of(context).size.height)),
                        SnapTarget(Pivot.topRight, Offset(1.0 - 50.0 / MediaQuery.of(context).size.width, 50.0 / MediaQuery.of(context).size.height)),
                        SnapTarget(
                            Pivot.bottomLeft, Offset(50.0 / MediaQuery.of(context).size.width, 1.0 - 50.0 / MediaQuery.of(context).size.height)),
                        SnapTarget(Pivot.bottomRight,
                            Offset(1.0, 1.0) - Offset(50.0 / MediaQuery.of(context).size.width, 50.0 / MediaQuery.of(context).size.height)),
                        const SnapTarget(Pivot.center, Pivot.center),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Scaffold(
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                description("The box will snap to the closest side or the center within its container."),
                gap(),
                Container(
                  width: 300,
                  height: 300,
                  color: Colors.orangeAccent,
                  child: Align(
                    key: bounds[4],
                    alignment: const Alignment(-1.0, -1.0),
                    child: SnapController(
                      smallBoxView(),
                      true,
                      views[4],
                      bounds[4],
                      Offset.zero,
                      const Offset(1.0, 1.0),
                      const Offset(0.15, 0.15),
                      const Offset(0.15, 0.15),
                      snapTargets: [
                        const SnapTarget(Pivot.closestAny, Pivot.closestAny),
                        const SnapTarget(Pivot.center, Pivot.center),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Scaffold(
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                description("The box will snap to the corners or the center without animation."),
                gap(),
                Expanded(
                  child: Align(
                    key: bounds[5],
                    alignment: const Alignment(-1.0, -1.0),
                    child: SnapController(
                      secondNormalBoxView(),
                      false,
                      views[5],
                      bounds[5],
                      Offset.zero,
                      const Offset(1.0, 1.0),
                      const Offset(0.75, 0.75),
                      const Offset(0.75, 0.75),
                      snapTargets: [
                        const SnapTarget(Pivot.topLeft, Pivot.topLeft),
                        const SnapTarget(Pivot.topRight, Pivot.topRight),
                        const SnapTarget(Pivot.bottomLeft, Pivot.bottomLeft),
                        const SnapTarget(Pivot.bottomRight, Pivot.bottomRight),
                        const SnapTarget(Pivot.center, Pivot.center),
                      ],
                      animateSnap: false,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Widget description(String text) {
  return Container(
    constraints: const BoxConstraints.expand(height: 75),
    color: Colors.green,
    child: Center(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    ),
  );
}

Widget gap() {
  return Container(
    constraints: const BoxConstraints.expand(height: 25),
    color: Colors.transparent,
    child: Center(
      child: const Text(
        "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - ",
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
        textAlign: TextAlign.center,
      ),
    ),
  );
}

Widget firstNormalBoxView() {
  return normalBox(
    views[0],
    "Move & Snap",
    Colors.redAccent,
  );
}

Widget animatedBoxView() {
  return normalBox(
    views[1],
    "Move & Snap",
    Colors.redAccent,
  );
}

Widget dottedBoxView() {
  return dottedBox(
    views[2],
    "Move & Snap",
    Colors.redAccent,
  );
}

Widget translatedBoxView() {
  return translatedBox(
    views[3],
    "Move & Snap",
    Colors.redAccent,
  );
}

Widget smallBoxView() {
  return smallBox(
    views[4],
    "*",
    Colors.redAccent,
  );
}

Widget secondNormalBoxView() {
  return normalBox(
    views[5],
    "Move & Snap",
    Colors.redAccent,
  );
}

Widget thirdNormalBoxView() {
  return normalBox(
    views[6],
    "Move & Snap",
    Colors.redAccent,
  );
}

Widget normalBox(Key key, String text, Color color) {
  return Container(
    key: key,
    width: 200,
    height: 200,
    color: Colors.transparent,
    child: Padding(
      padding: const EdgeInsets.all(5),
      child: Container(
        constraints: BoxConstraints.expand(),
        decoration: BoxDecoration(
          color: color,
          borderRadius: const BorderRadius.all(const Radius.circular(10.0)),
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 25,
            ),
          ),
        ),
      ),
    ),
  );
}

Widget translatedBox(Key key, String text, Color color) {
  return Transform.translate(
    offset: const Offset(50, 50),
    child: Container(
      key: key,
      width: 200,
      height: 200,
      color: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Container(
          constraints: BoxConstraints.expand(),
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.all(const Radius.circular(10.0)),
          ),
          child: Center(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 25,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

Widget smallBox(Key key, String text, Color color) {
  return Container(
    key: key,
    width: 50,
    height: 50,
    color: Colors.transparent,
    child: Padding(
      padding: const EdgeInsets.all(5),
      child: Container(
        constraints: BoxConstraints.expand(),
        decoration: BoxDecoration(
          color: color,
          borderRadius: const BorderRadius.all(const Radius.circular(0.0)),
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 25,
            ),
          ),
        ),
      ),
    ),
  );
}

Widget dottedBox(Key key, String text, Color color) {
  return Transform.translate(
    offset: const Offset(75, 100),
    child: Container(
      key: key,
      width: 200,
      height: 200,
      color: Colors.transparent,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(5),
            child: Container(
              constraints: BoxConstraints.expand(),
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.all(const Radius.circular(10.0)),
              ),
              child: Center(
                child: Text(
                  text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 25,
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: const Alignment(-0.9, -0.9),
            child: Container(
              width: 10,
              height: 10,
              color: Colors.orangeAccent,
            ),
          ),
          Align(
            alignment: const Alignment(0.9, -0.9),
            child: Container(
              width: 10,
              height: 10,
              color: Colors.black,
            ),
          ),
          Align(
            alignment: const Alignment(-0.9, 0.9),
            child: Container(
              width: 10,
              height: 10,
              color: Colors.deepPurpleAccent,
            ),
          ),
        ],
      ),
    ),
  );
}
