# example

Example Project for snap.


# snap

An extensive snap tool/widget for Flutter that allows very flexible snap management and snapping between your widgets. Inspired by WhatsApp's 
in-app Youtube player.

[Media](#media) | [Description](#description) | [How-to-Use](#howtouse)

<img src="https://img.shields.io/badge/Cosmos%20Software-Love%20Code-red"/>
<br>

[![Pub](https://img.shields.io/pub/v/snap?color=g)](https://pub.dev/packages/snap)
[![License](https://img.shields.io/github/license/aliyigitbireroglu/flutter-snap?color=blue)](https://github.com/aliyigitbireroglu/flutter-snap/blob/master/LICENSE)

## Recent
* **[flick](https://pub.dev/packages/flick) is now added. It is amazing! See [Media](#media) for examples.** 
* * *


<a name="media"></a>
## Media
*Videos*

* [v1.0.0 with Flick](https://youtu.be/vNTBsMg1NXg)
<br><br>
* [v0.1.0](https://youtu.be/anHHG3JJPrI)

*GIFs*
<br><br>
<img src="https://www.cosmossoftware.coffee/Common/Portfolio/GIFs/FlutterSnapNew.gif"/>
<br><br>


<a name="description"></a>
## Description
This is a very detailed snap tool/widget that allows very flexible snap management and snapping between your widgets. Just wrap your *snapper* 
widget with the SnapController widget, fill the parameters, define your *snappable* widget and this package will take care of everything else.


<a name="howtouse"></a>
## How-to-Use
*"The view is what is being moved. It is the widget that snaps to the bound. The bound is what the view is being snapped to."*

First, define two GlobalKeys- one for your view and one for your bound: 
 
```
GlobalKey bound = GlobalKey();
GlobalKey view = GlobalKey();
```

Then, create a SnapController as shown in the example project:

```
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Expanded(
      child: Align(
      key: bound,
      alignment: const Alignment(-1.0, -1.0),
      child: SnapController(
        normalBox(view, "Move & Snap", Colors.redAccent),
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
        ])))])

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
        borderRadius: const BorderRadius.all(const Radius.circular(10.0))),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 25))))));
}
```

In this excerpt, the bound is the Align widget which expands through the column. The view is the normalBox widget. The SnapController is confined 
between Offset.zero and Offset(1.0, 1.0). This means the view will not exceed the limits of the bound. The flexibility is confined between 
Offset(0.75, 0.75) and Offset(0.75, 0.75). This means that the view can be moved beyond the horizontal/vertical min/max constraints with a 
flexibility of 0.75 before it snaps. The snapTargets determine to where the view should snap once the movement is over. In this example:
   
1. The top left corner of the view can snap to the top left corner of the bound.
2. The top right corner of the view can snap to the top right corner of the bound.
3. The bottom left corner of the view can snap to the bottom left corner of the bound.
4. The bottom right corner of the view can snap to the bottom right corner of the bound.
5. The center of the view can snap to the center of the bound.

Keep in mind that these constant values are provided only for the ease of use. snapTargets can consist of any values you wish.

* * *
##It is highly recommended to read the documentation and the example project.

<br>

## Notes
I started using and learning Flutter only some weeks ago so this package might have some parts that don't make sense, 
that should be completely different, that could be much better, etc. Please let me know! Nicely! 

Any help, suggestion or criticism is appreciated! 

Cheers.

<br><br>
<img align="right" src="https://www.cosmossoftware.coffee/Common/Images/CosmosSoftwareIconTransparent.png" width="150" height="150"/>
<br><br>