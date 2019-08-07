// © Cosmos Software | Ali Yigit Bireroglu All material used in the making of this code, project, program, application,
// software et cetera (the "Intellectual Property") belongs completely and solely to Ali Yigit Bireroglu. This includes but
// is not limited to the source code, the multimedia and other asset files. If you were granted this Intellectual Property
// for personal use, you are obligated to include this copyright text at all times.
// Copyright © 2019 Ali Yigit Bireroglu (https://www.cosmossoftare.coffee) All rights reserved.

//@formatter:off
import 'dart:ui';

typedef MoveCallback = void Function(Offset offset);
typedef SnapCallback = void Function(Offset offset);

class Pivot {
	static Offset closestHorizontal = Offset(12345, 0);
	static Offset closestVertical =  Offset(0, 12345);
	static Offset closestAny =  Offset(12345, 12345);
	static bool isClosestHorizontal(Offset offset) => offset == closestHorizontal;
	static bool isClosestVertical(Offset offset) => offset == closestVertical;
	static bool isClosestAny(Offset offset) => offset == closestAny;
	static const Offset topLeft = const Offset(0,0);
	static const Offset topRight = const Offset(1,0);
	static const Offset bottomLeft = const Offset(0,1);
	static const Offset bottomRight = const Offset(1,1);
	static const Offset center = const Offset(0.5, 0.5);
}

class SnapTarget{
	final Offset viewPivot;
	final Offset boundPivot;
	
	const SnapTarget(this.viewPivot, this.boundPivot);
}