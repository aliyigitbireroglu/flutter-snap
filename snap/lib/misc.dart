// © Cosmos Software | Ali Yigit Bireroglu All material used in the making of this code, project, program, application,
// software et cetera (the "Intellectual Property") belongs completely and solely to Ali Yigit Bireroglu. This includes but
// is not limited to the source code, the multimedia and other asset files. If you were granted this Intellectual Property
// for personal use, you are obligated to include this copyright text at all times.
// Copyright © 2019 Ali Yigit Bireroglu (https://www.cosmossoftare.coffee) All rights reserved.

//@formatter:off
import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:snap/Export.dart';

typedef SnapBuilder = Widget Function(BuildContext context);
typedef MoveCallback = void Function(Offset offset);
typedef SnapCallback = void Function(Offset offset);

class Pivot {
	///Use this value if you want your view to snap to the closest horizontal side (Left/Right).
	static Offset closestHorizontal = Offset(12345, 0);
	///Use this value if you want your view to snap to the closest vertical side (Top/Bottom).
	static Offset closestVertical =  Offset(0, 12345);
	///Use this value if you want your view to snap to the closest side (Left/Right/Left/Right).
	static Offset closestAny =  Offset(12345, 12345);
	static bool isClosestHorizontal(Offset offset) => offset == closestHorizontal;
	static bool isClosestVertical(Offset offset) => offset == closestVertical;
	static bool isClosestAny(Offset offset) => offset == closestAny;
	
	///Use this value to easily assign a top left corner pivot to your view or your bound.
	static const Offset topLeft = const Offset(0,0);
	///Use this value to easily assign a top right corner pivot to your view or your bound.
	static const Offset topRight = const Offset(1,0);
	///Use this value to easily assign a bottom left corner pivot to your view or your bound.
	static const Offset bottomLeft = const Offset(0,1);
	///Use this value to easily assign a bottom right corner pivot to your view or your bound.
	static const Offset bottomRight = const Offset(1,1);
	///Use this value to easily assign a center pivot to your view or your bound.
	static const Offset center = const Offset(0.5, 0.5);
}

///A simple class for organising pivot values. Your view will snap to your bound through the closest [SnapTarget.viewPivot] and [SnapTarget.boundPivot] 
///match. For example, consider the following:
///I) [SnapTarget.viewPivot] = (0.1, 0.1)
///II) [SnapTarget.boundPivot] = (0.75, 0.75)
///These values determine that your view will snap to your bound at:
///I) The coordinate of the view at (10% [SnapControllerState.viewWidth], 10% [SnapControllerState.viewHeight].
///II) The coordinate of the bound at (75% [SnapControllerState.boundWidth], 75% [SnapControllerState.boundHeight].
///(All values consider the coordinate plane to start at (0,0) from the top left corner of the view or the bound.)
///See the provided example for further clarification.
class SnapTarget{
	final Offset viewPivot;
	final Offset boundPivot;
	
	const SnapTarget(this.viewPivot, this.boundPivot);
}