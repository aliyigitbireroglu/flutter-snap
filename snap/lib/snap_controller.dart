//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// © Cosmos Software | Ali Yigit Bireroglu                                                                                                           /
// All material used in the making of this code, project, program, application, software et cetera (the "Intellectual Property")                     /
// belongs completely and solely to Ali Yigit Bireroglu. This includes but is not limited to the source code, the multimedia and                     /
// other asset files. If you were granted this Intellectual Property for personal use, you are obligated to include this copyright                   /
// text at all times.                                                                                                                                /
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//@formatter:off
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flick/flick.dart';
import 'misc.dart' as Misc;
import 'Export.dart';

///The widget that is responsible of ALL Snap related logic and UI. It is important to define two essential concepts used for this package:
///I) The view is what is being moved. It is the widget that snaps to the bound.
///II) The bound is what the view is being snapped to.
class SnapController extends StatefulWidget {
  ///The widget that is to be displayed on your UI.
  final Widget uiChild;

  ///Set this to true if your [uiChild] doesn't change at runtime.
  final bool useCache;

  ///The [GlobalKey] of the view.
  final GlobalKey viewKey;

  ///The [GlobalKey] of the bound.
  final GlobalKey boundKey;

  ///Use this value to set the lower left boundary of the movement.
  final Offset constraintsMin;

  ///Use this value to set the upper right boundary of the movement.
  final Offset constraintsMax;

  ///Use this value to set the lower left elasticity of the movement.
  final Offset flexibilityMin;

  ///Use this value to set the upper right elasticity of the movement.
  final Offset flexibilityMax;

  ///Use this value to set a custom bound width. If not set, [SnapController] will automatically calculate it via [boundKey].
  final double customBoundWidth;

  ///Use this value to set a custom bound height. If not set, [SnapController] will automatically calculate it via [boundKey].
  final double customBoundHeight;

  ///The list of [SnapTarget]s your view can snap to.
  final List<SnapTarget> snapTargets;

  ///Use this value to set whether the snapping should occur directly or via an animation.
  final bool animateSnap;

  ///Set this to true if you want to use flick.
  final bool useFlick;

  ///Use this value to set the sensitivity of flick.
  final double flickSensitivity;

  ///The callback for when the view moves.
  final Misc.MoveCallback onMove;

  ///The callback for when the drag starts.
  final Misc.DragCallback onDragStart;

  ///The callback for when the drag updates.
  final Misc.DragCallback onDragUpdate;

  ///The callback for when the drag ends.
  final Misc.DragCallback onDragEnd;

  ///The callback for when the view snaps.
  final SnapCallback onSnap;

  const SnapController(
      this.uiChild,
      this.useCache,
      this.viewKey,
      this.boundKey,
      this.constraintsMin,
      this.constraintsMax,
      this.flexibilityMin,
      this.flexibilityMax,
      {Key key,
      this.customBoundWidth: 0,
      this.customBoundHeight: 0,
      this.snapTargets,
      this.animateSnap: true,
      this.useFlick: true,
      this.flickSensitivity: 0.075,
      this.onMove,
      this.onDragStart,
      this.onDragUpdate,
      this.onDragEnd,
      this.onSnap})
      : super(key: key);

  @override
  SnapControllerState createState() {
    return SnapControllerState(
        useCache,
        viewKey,
        boundKey,
        constraintsMin,
        constraintsMax,
        flexibilityMin,
        flexibilityMax,
        snapTargets,
        animateSnap,
        useFlick,
        flickSensitivity,
        onMove,
        onDragStart,
        onDragUpdate,
        onDragEnd,
        onSnap);
  }
}

class SnapControllerState extends State<SnapController>
    with SingleTickerProviderStateMixin {
  Widget uiChild;
  final bool useCache;
  final GlobalKey viewKey;
  final GlobalKey boundKey;

  Offset constraintsMin;
  Offset constraintsMax;
  Offset normalisedConstraintsMin;
  Offset normalisedConstraintsMax;
  final Offset flexibilityMin;
  final Offset flexibilityMax;
  final List<SnapTarget> snapTargets;

  bool canMove = true;
  final bool animateSnap;
  bool useFlick;
  final double flickSensitivity;

  final Misc.MoveCallback onMove;
  final Misc.DragCallback onDragStart;
  final Misc.DragCallback onDragUpdate;
  final Misc.DragCallback onDragEnd;
  final SnapCallback onSnap;

  RenderBox viewRenderBox;
  double viewWidth = -1;
  double viewHeight = -1;
  Offset viewOrigin;
  RenderBox boundRenderBox;
  double boundWidth = -1;
  double boundHeight = -1;
  Offset boundOrigin;

  Offset beginDragPosition;
  Offset updateDragPosition;
  Offset delta = Offset.zero;
  Offset overrideDelta = Offset.zero;

  ///The [AnimationController] used to move the view during snapping if [SnapController.animateSnap] is set to true.
  AnimationController animationController;
  Animation<Offset> animation;
  final ValueNotifier<Offset> deltaNotifier =
      ValueNotifier<Offset>(Offset.zero);

  ///Use this value to determine the depth of debug logging that is actually only here for myself and the Swiss scientists.
  int _debugLevel = 0;

  SnapControllerState(
      this.useCache,
      this.viewKey,
      this.boundKey,
      this.constraintsMin,
      this.constraintsMax,
      this.flexibilityMin,
      this.flexibilityMax,
      this.snapTargets,
      this.animateSnap,
      this.useFlick,
      this.flickSensitivity,
      this.onMove,
      this.onDragStart,
      this.onDragUpdate,
      this.onDragEnd,
      this.onSnap);

  @override
  void initState() {
    super.initState();

    if (!animateSnap) useFlick = false;

    if (useCache) uiChild = wrapper();

    animationController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 333),
        lowerBound: 0,
        upperBound: 1)
      ..addListener(() {
        deltaNotifier.value = animation.value;
        if (onMove != null) onMove(deltaNotifier.value);
      })
      ..addStatusListener((_) {});
    animation = Tween(begin: Offset.zero, end: Offset.zero).animate(
        CurvedAnimation(
            parent: animationController, curve: Curves.fastOutSlowIn));

    checkViewAndBound();
  }

  @override
  void dispose() {
    animationController.removeListener(() {
      deltaNotifier.value = animation.value;
    });
    animationController.removeStatusListener((_) {});
    animationController.dispose();

    reset();

    super.dispose();
  }

  void checkViewAndBound() {
    if (!viewIsSet)
      setView();
    else
      checkViewOrigin();
    if (!boundIsSet)
      setBound();
    else
      checkBoundOrigin();
  }

  void setView() {
    try {
      if (viewKey.currentContext == null) return;
      if (viewRenderBox == null)
        viewRenderBox = viewKey.currentContext.findRenderObject();

      if (viewRenderBox != null) {
        if (viewRenderBox.hasSize) {
          if (viewWidth == -1) viewWidth = viewRenderBox.size.width;
          if (viewHeight == -1) viewHeight = viewRenderBox.size.height;
        }

        if (viewOrigin == null)
          viewOrigin = viewRenderBox.localToGlobal(Offset.zero);
      }
    } catch (_) {}
  }

  bool get viewIsSet =>
      !(viewWidth == -1 || viewHeight == -1 || viewOrigin == null);

  void setBound() {
    try {
      if (boundKey.currentContext == null) return;
      if (boundRenderBox == null)
        boundRenderBox = boundKey.currentContext.findRenderObject();

      if (boundRenderBox != null) {
        if (boundRenderBox.hasSize) {
          if (boundWidth == -1)
            boundWidth = boundRenderBox.size.width + widget.customBoundWidth;
          if (boundHeight == -1)
            boundHeight = boundRenderBox.size.height + widget.customBoundHeight;

          if (boundWidth != -1 && boundHeight != -1) normaliseConstraints();
        }
      }
      if (boundOrigin == null)
        boundOrigin = boundRenderBox.localToGlobal(Offset.zero);
    } catch (_) {}
  }

  bool get boundIsSet =>
      !(boundWidth == -1 || boundHeight == -1 || boundOrigin == null);

  void checkViewOrigin() {
    if (viewOrigin !=
        viewRenderBox.localToGlobal(Offset.zero) - deltaNotifier.value)
      viewOrigin =
          viewRenderBox.localToGlobal(Offset.zero) - deltaNotifier.value;
  }

  void checkBoundOrigin() {
    if (boundOrigin != boundRenderBox.localToGlobal(Offset.zero))
      boundOrigin = boundRenderBox.localToGlobal(Offset.zero);
  }

  void normaliseConstraints() {
    double constraintsMinX = constraintsMin.dx == double.negativeInfinity
        ? double.negativeInfinity
        : boundWidth * constraintsMin.dx;
    double constraintsMinY = constraintsMin.dy == double.negativeInfinity
        ? double.negativeInfinity
        : boundHeight * constraintsMin.dy;
    double constraintsMaxX = constraintsMax.dx == double.infinity
        ? double.infinity
        : boundWidth * constraintsMax.dx;
    double constraintsMaxY = constraintsMax.dy == double.infinity
        ? double.infinity
        : boundHeight * constraintsMax.dy;
    constraintsMin = Offset(constraintsMinX, constraintsMinY);
    constraintsMax = Offset(constraintsMaxX, constraintsMaxY);
  }

  void beginDrag(dynamic dragStartDetails) {
    if (!canMove) return;
    if (animationController.isAnimating) return;

    if (_debugLevel > 0) print("BeginDrag");

    checkViewAndBound();

    delta = deltaNotifier.value;
    beginDragPosition = dragStartDetails.localPosition;

    if (onDragStart != null) onDragStart(dragStartDetails);
  }

  void updateDrag(dynamic dragUpdateDetails) {
    if (!canMove) return;
    if (animationController.isAnimating) return;

    if (_debugLevel > 0) print("UpdateDrag");

    checkViewAndBound();

    if (beginDragPosition == null) beginDrag(dragUpdateDetails);
    updateDragPosition = dragUpdateDetails.localPosition;
    setDelta();

    if (onDragUpdate != null) onDragUpdate(dragUpdateDetails);
  }

  void endDrag(dynamic dragEndDetails) {
    if (!canMove) return;
    if (animationController.isAnimating) return;

    if (_debugLevel > 0) print("EndDrag");

    if (onDragEnd != null) onDragStart(dragEndDetails);

    if (!useFlick) snap();
  }

  void onFlick(Offset offset) {
    snap();
  }

  void setDelta() {
    if (beginDragPosition == null || updateDragPosition == null) return;
    if (!viewIsSet || !boundIsSet) return;

    Offset _delta = delta +
        Offset(updateDragPosition.dx - beginDragPosition.dx,
            updateDragPosition.dy - beginDragPosition.dy);
    normalisedConstraintsMin = constraintsMin - viewOrigin + boundOrigin;
    normalisedConstraintsMax = constraintsMax -
        viewOrigin +
        boundOrigin -
        Offset(viewWidth, viewHeight);
    if (_delta.dx < normalisedConstraintsMin.dx)
      _delta = Offset(
          normalisedConstraintsMin.dx -
              pow((_delta.dx - normalisedConstraintsMin.dx).abs(),
                  flexibilityMin.dx) +
              1.0,
          _delta.dy);
    if (_delta.dx > normalisedConstraintsMax.dx)
      _delta = Offset(
          normalisedConstraintsMax.dx +
              pow((_delta.dx - normalisedConstraintsMax.dx).abs(),
                  flexibilityMax.dx) -
              1.0,
          _delta.dy);
    if (_delta.dy < normalisedConstraintsMin.dy)
      _delta = Offset(
          _delta.dx,
          normalisedConstraintsMin.dy -
              pow((_delta.dy - normalisedConstraintsMin.dy).abs(),
                  flexibilityMin.dy) +
              1.0);
    if (_delta.dy > normalisedConstraintsMax.dy)
      _delta = Offset(
          _delta.dx,
          normalisedConstraintsMax.dy +
              pow((_delta.dy - normalisedConstraintsMax.dy).abs(),
                  flexibilityMax.dy) -
              1.0);

    deltaNotifier.value = _delta;

    if (onMove != null) onMove(deltaNotifier.value);
  }

  double get maxLeft => boundOrigin.dx - viewOrigin.dx;

  double get maxRight =>
      boundWidth + boundOrigin.dx - viewWidth - viewOrigin.dx;

  double get maxTop => boundOrigin.dy - viewOrigin.dy;

  double get maxBottom =>
      boundHeight + boundOrigin.dy - viewHeight - viewOrigin.dy;

  Future snap() async {
    checkViewAndBound();
    Offset snapTarget = getSnapTarget();
    if (animateSnap) {
      await move(snapTarget);
      deltaNotifier.value = snapTarget;
    } else
      deltaNotifier.value = snapTarget;

    delta = Offset.zero;
    beginDragPosition = null;
    updateDragPosition = null;
    overrideDelta = Offset.zero;

    if (onSnap != null) onSnap(deltaNotifier.value);
  }

  Offset getSnapTarget() {
    if (snapTargets == null)
      return deltaNotifier.value;
    else {
      Map<Offset, double> map = Map<Offset, double>();
      snapTargets.forEach((SnapTarget snapTarget) {
        if (Pivot.isClosestHorizontal(snapTarget.viewPivot) ||
            Pivot.isClosestAny(snapTarget.viewPivot)) {
          Offset left = Offset(0 - viewOrigin.dx + boundOrigin.dx,
              deltaNotifier.value.dy.clamp(maxTop, maxBottom));
          map[left] = Point(deltaNotifier.value.dx, deltaNotifier.value.dy)
              .distanceTo(Point(left.dx, left.dy));
          if (_debugLevel > 1) {
            print("--------------------");
            print("Left");
            print(snapTarget.boundPivot);
            print(snapTarget.viewPivot);
            print(boundWidth);
            print(boundHeight);
            print(boundOrigin);
            print(viewWidth);
            print(viewHeight);
            print(viewOrigin);
            print(left);
            print("--------------------");
          }
          Offset right = Offset(
              boundWidth + -viewOrigin.dx + boundOrigin.dx - viewWidth,
              deltaNotifier.value.dy.clamp(maxTop, maxBottom));
          map[right] = Point(deltaNotifier.value.dx, deltaNotifier.value.dy)
              .distanceTo(Point(right.dx, right.dy));
          if (_debugLevel > 1) {
            print("--------------------");
            print("Right");
            print(snapTarget.boundPivot);
            print(snapTarget.viewPivot);
            print(boundWidth);
            print(boundHeight);
            print(boundOrigin);
            print(viewWidth);
            print(viewHeight);
            print(viewOrigin);
            print(right);
            print("--------------------");
          }
        }
        if (Pivot.isClosestVertical(snapTarget.viewPivot) ||
            Pivot.isClosestAny(snapTarget.viewPivot)) {
          Offset top = Offset(
            deltaNotifier.value.dx.clamp(maxLeft, maxRight),
            0 - viewOrigin.dy + boundOrigin.dy,
          );
          map[top] = Point(deltaNotifier.value.dx, deltaNotifier.value.dy)
              .distanceTo(Point(top.dx, top.dy));
          if (_debugLevel > 1) {
            print("--------------------");
            print("Top");
            print(snapTarget.boundPivot);
            print(snapTarget.viewPivot);
            print(boundWidth);
            print(boundHeight);
            print(boundOrigin);
            print(viewWidth);
            print(viewHeight);
            print(viewOrigin);
            print(top);
            print("--------------------");
          }
          Offset bottom = Offset(
              deltaNotifier.value.dx.clamp(maxLeft, maxRight),
              boundHeight + -viewOrigin.dy + boundOrigin.dy - viewHeight);
          map[bottom] = Point(deltaNotifier.value.dx, deltaNotifier.value.dy)
              .distanceTo(Point(bottom.dx, bottom.dy));
          if (_debugLevel > 1) {
            print("--------------------");
            print("Bottom");
            print(snapTarget.boundPivot);
            print(snapTarget.viewPivot);
            print(boundWidth);
            print(boundHeight);
            print(boundOrigin);
            print(viewWidth);
            print(viewHeight);
            print(viewOrigin);
            print(bottom);
            print("--------------------");
          }
        }
        if (!Pivot.isClosestHorizontal(snapTarget.viewPivot) &&
            !Pivot.isClosestVertical(snapTarget.viewPivot) &&
            !Pivot.isClosestAny(snapTarget.viewPivot)) {
          Offset offset = Offset(
              boundWidth * snapTarget.boundPivot.dx +
                  boundOrigin.dx -
                  viewWidth * snapTarget.viewPivot.dx -
                  viewOrigin.dx,
              boundHeight * snapTarget.boundPivot.dy +
                  boundOrigin.dy -
                  viewHeight * snapTarget.viewPivot.dy -
                  viewOrigin.dy);
          if (_debugLevel > 1) {
            print("--------------------");
            print(snapTarget.boundPivot);
            print(snapTarget.viewPivot);
            print(boundWidth);
            print(boundHeight);
            print(boundOrigin);
            print(viewWidth);
            print(viewHeight);
            print(viewOrigin);
            print(offset);
            print("--------------------");
          }
          map[offset] = Point(deltaNotifier.value.dx, deltaNotifier.value.dy)
              .distanceTo(Point(offset.dx, offset.dy));
        }
      });

      return map.keys.firstWhere((Offset offset) {
        return map[offset] == map.values.reduce(min);
      });
    }
  }

  Future move(Offset snapTarget) async {
    animation = Tween(begin: deltaNotifier.value, end: snapTarget).animate(
        CurvedAnimation(
            parent: animationController, curve: Curves.fastOutSlowIn));
    animationController.forward(from: 0);
    await Future.delayed(Duration(milliseconds: 333));
    return;
  }

  ///Use this function to determine if the view is moved or not.
  bool isMoved(double treshold) {
    return deltaNotifier.value.dx.abs() > treshold ||
        deltaNotifier.value.dy.abs() > treshold;
  }

  void reset() {
    delta = Offset.zero;
    beginDragPosition = null;
    updateDragPosition = null;
    overrideDelta = Offset.zero;
    deltaNotifier.value = Offset.zero;
  }

  Widget wrapper() {
    if (useFlick)
      return FlickController(widget.uiChild, useCache, viewKey,
          boundKey: boundKey,
          constraintsMin: constraintsMin,
          constraintsMax: constraintsMax,
          flexibilityMin: flexibilityMin,
          flexibilityMax: flexibilityMax,
          sensitivity: 0.075,
          onDragStart: beginDrag,
          onDragUpdate: updateDrag,
          onDragEnd: endDrag,
          onFlick: onFlick);
    else
      return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onVerticalDragStart: beginDrag,
          onVerticalDragUpdate: updateDrag,
          onVerticalDragEnd: endDrag,
          onHorizontalDragStart: beginDrag,
          onHorizontalDragUpdate: updateDrag,
          onHorizontalDragEnd: endDrag,
          child: widget.uiChild);
  }

  @override
  Widget build(BuildContext context) {
    checkViewAndBound();

    return ValueListenableBuilder(
        child: useCache ? uiChild : null,
        builder: (BuildContext context, Offset delta, Widget cachedChild) {
          return Transform.translate(
              offset: delta, child: useCache ? cachedChild : wrapper());
        },
        valueListenable: deltaNotifier);
  }
}
