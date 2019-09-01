# example

Example Project for snap.


# snap

[comment]: <> (Badges)
<a href="https://www.cosmossoftware.coffee">
   <img alt="Cosmos Software" src="https://img.shields.io/badge/Cosmos%20Software-Love%20Code-red" />
</a>
<a href="https://github.com/Solido/awesome-flutter">
   <img alt="Awesome Flutter" src="https://img.shields.io/badge/Awesome-Flutter-blue.svg?longCache=true&style=flat-square" />
</a>

[![Pub](https://img.shields.io/pub/v/snap?color=g)](https://pub.dev/packages/snap)
[![License](https://img.shields.io/github/license/aliyigitbireroglu/flutter-snap?color=blue)](https://github.com/aliyigitbireroglu/flutter-snap/blob/master/LICENSE)

[comment]: <> (Introduction)
An extensive snap tool/widget for Flutter that allows very flexible snap management and snapping between your widgets. 

Inspired by WhatsApp's in-app Youtube player.

**It is highly recommended to read the documentation and run the example project on a real device to fully understand and inspect the full range
 of capabilities.**

[comment]: <> (ToC)
[Media](#media) | [Description](#description) | [How-to-Use](#howtouse)

[comment]: <> (Notice)
## Notice
* **[flick](https://pub.dev/packages/flick) works as intended on actual devices even if it might appear to fail rarely on simulators. Don't be 
discouraged!**
* * *
[comment]: <> (Recent)
## Recent
* **[flick](https://pub.dev/packages/flick) is now added. It is amazing! See [Media](#media) for examples.** 
* * *


[comment]: <> (Media)
<a name="media"></a>
## Media

Watch on **Youtube**:

[v1.0.0 with Flick](https://youtu.be/vNTBsMg1NXg)
<br><br>
[v0.1.0](https://youtu.be/anHHG3JJPrI)
<br><br>
<img src="https://www.cosmossoftware.coffee/Common/Portfolio/GIFs/FlutterSnapNew.gif" height="450" max-height="450"/>
<br><br>


[comment]: <> (Description)
<a name="description"></a>
## Description
This is an extensive snap tool/widget for Flutter that allows very flexible snap management and snapping between your widgets. 

Just wrap your *snapper* widget with the SnapController widget, fill the parameters, define your *snappable* widget and this package will take care
 of everything else.


[comment]: <> (How-to-Use)
<a name="howtouse"></a>
## How-to-Use
*"The view is what is being moved. It is the widget that snaps to the bound. The bound is what the view is being snapped to."*

First, define two GlobalKeys- one for your view and one for your bound: 
 
```
GlobalKey bound = GlobalKey();
GlobalKey view = GlobalKey();
```

Then, create a SnapController such as:

```
SnapController(
  uiChild(),                //uiChild
  false,                    //useCache
  view,                     //viewKey
  bound,                    //boundKey
  Offset.zero,              //constraintsMin
  const Offset(1.0, 1.0),   //constraintsMax
  const Offset(0.75, 0.75), //flexibilityMin
  const Offset(0.75, 0.75), //flexibilityMax
 {Key key,
  customBoundWidth  : 0,
  customBoundHeight : 0,
  snapTargets       : [
    const SnapTarget(Pivot.topLeft, Pivot.topLeft),
    const SnapTarget(Pivot.topRight, Pivot.topRight),
    const SnapTarget(Pivot.bottomLeft, Pivot.bottomLeft),
    const SnapTarget(Pivot.bottomRight, Pivot.bottomRight),
    const SnapTarget(Pivot.center, Pivot.center)
  ],
  animateSnap       : true,
  useFlick          : true,
  flickSensitivity  : 0.075,
  onMove            : _onMove,
  onDragStart       : _onDragStart,
  onDragUpdate      : _onDragUpdate,
  onDragEnd         : _onDragEnd,
  onSnap            : _onSnap})

Widget uiChild() {
  return Container(
    key: view,
    ...
  ); 
}

void _onMove(Offset offset);

void _onDragStart(dynamic dragDetails);
void _onDragUpdate(dynamic dragDetails);
void _onDragEnd(dynamic dragDetails);

void _onSnap(Offset offset);
```

**Further Explanations:**

*For a complete set of descriptions for all parameters and methods, see the [documentation](https://pub.dev/documentation/snap/latest/).*

* Set [useCache] to true if your [uiChild] doesn't change during the Peek & Pop process.
* Consider the following example:

```
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Expanded(
      child: Align(
        key: bound,
        alignment: const Alignment(-1.0, -1.0),
        child: SnapController(
          uiChild(),
          true,
          view,
          bound,
          Offset.zero,
          const Offset(1.0, 1.0),
          const Offset(0.75, 0.75),
          const Offset(0.75, 0.75),
          snapTargets: [
            const SnapTarget(Pivot.topLeft, Pivot.topLeft),
            const SnapTarget(Pivot.topRight, Pivot.topRight),
            const SnapTarget(Pivot.bottomLeft, Pivot.bottomLeft),
            const SnapTarget(Pivot.bottomRight, Pivot.bottomRight),
            const SnapTarget(Pivot.center, Pivot.center)
          ]
        )
      )
    )
  ]
)
```

In this excerpt, the bound is an Align widget which expands through a Column widget. 

The SnapController is confined between Offset.zero and Offset(1.0, 1.0). This means the view will not exceed the limits of the bound. 

The flexibility is confined between Offset(0.75, 0.75) and Offset(0.75, 0.75). This means that the view can be moved beyond the horizontal/vertical
min/max constraints with a flexibility of 0.75 before it snaps. 
 
The snapTargets determine from where and to where the view should snap once the movement is over. In this example:
   
1. The top left corner of the view can snap to the top left corner of the bound.
2. The top right corner of the view can snap to the top right corner of the bound.
3. The bottom left corner of the view can snap to the bottom left corner of the bound.
4. The bottom right corner of the view can snap to the bottom right corner of the bound.
5. The center of the view can snap to the center of the bound.

Keep in mind that these constant values are provided only for the ease of use. snapTargets can consist of any values you wish.

* Use [SnapControllerState]'s [bool isMoved(double treshold)] method to determine if the view is moved or not where [treshold] is the distance at 
which the view should be considered to be moved.


[comment]: <> (Notes)
## Notes
I started using and learning Flutter only some weeks ago so this package might have some parts that don't make sense, that should be completely 
different, that could be much better, etc. Please let me know! Nicely! 

Any help, suggestion or criticism is appreciated! 

Cheers.

[comment]: <> (CosmosSoftware)
<br><br>
<img align="right" src="https://www.cosmossoftware.coffee/Common/Images/CosmosSoftwareIconTransparent.png" width="150" height="150"/>
<br><br>