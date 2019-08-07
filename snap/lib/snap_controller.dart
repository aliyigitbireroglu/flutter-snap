// © Cosmos Software | Ali Yigit Bireroglu All material used in the making of this code, project, program, application,
// software et cetera (the "Intellectual Property") belongs completely and solely to Ali Yigit Bireroglu. This includes but
// is not limited to the source code, the multimedia and other asset files. If you were granted this Intellectual Property
// for personal use, you are obligated to include this copyright text at all times.
// Copyright © 2019 Ali Yigit Bireroglu (https://www.cosmossoftare.coffee) All rights reserved.

//@formatter:off
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'Export.dart';

class SnapController extends StatefulWidget {
	final Widget child;
	final bool useCache;
	final GlobalKey viewKey;
	final GlobalKey boundKey;
	
  ///Use this value to set the lower left boundary of the movement.
  final Offset constraintsMin;
  ///Use this value to set the upper right boundary of the movement. 
  final Offset constraintsMax;
  ///Use this value to set the lower left elasticity of the movement. 
  final Offset flexibilityMin;
  ///Use this value to set the upper right elasticity of the movement.
  final Offset flexibilityMax;
  
  final double customBoundWidth;
  final double customBoundHeight;
  
  final List<SnapTarget> snapTargets;
  
  final bool animateSnap;

  ///The callback for when the view moves.
  final MoveCallback onMove;
  ///The callback for when the view snaps.
  final SnapCallback onSnap;
	
	const SnapController(
					this.child,
					this.useCache,
					this.viewKey,
					this.boundKey,
					this.constraintsMin, 
			    this.constraintsMax, 
			    this.flexibilityMin,
			    this.flexibilityMax,
			    {Key key, 
					this.customBoundWidth:0,
				  this.customBoundHeight:0,  
			    this.snapTargets,
				  this.animateSnap,  
			    this.onMove,
					this.onSnap}) : super(key:key);
	
  @override
  SnapControllerState createState() {
    return SnapControllerState(
				    child,
				    useCache,
				    viewKey,
				    boundKey,
				    constraintsMin,
				    constraintsMax,
				    flexibilityMin,
				    flexibilityMax,
				    snapTargets,
				    animateSnap,
				    onMove,
				    onSnap);
  }
}

class SnapControllerState extends State<SnapController> with SingleTickerProviderStateMixin {
	final Widget child;
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
  
  final bool animateSnap;

  final MoveCallback onMove;
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
  
  AnimationController animationController;
  Animation<Offset> animation;
  ValueNotifier<Offset> deltaNotifier = ValueNotifier<Offset>(Offset.zero);
  
	///Use this value to determine the depth of debug logging that is actually only here for myself and the Swiss scientists. 
  int _debugLevel = 0;
	
	SnapControllerState(
		this.child,
		this.useCache,
		this.viewKey,
		this.boundKey,
		this.constraintsMin, 
    this.constraintsMax, 
    this.flexibilityMin,
    this.flexibilityMax,
    this.snapTargets,
    this.animateSnap,
    this.onMove,
		this.onSnap);
	
  @override
  void initState() {
    super.initState();
		
    animationController = 
			AnimationController(
				vsync: this, 
				duration: const Duration(milliseconds: 333), 
				lowerBound: 0, upperBound: 1)
			..addListener((){
			  deltaNotifier.value = animation.value;
      })
			..addStatusListener((_) {});
		animation = 
			Tween(
				begin: Offset(0,0), 
				end: Offset(0,0))
			.animate(CurvedAnimation(
								parent: animationController, 
								curve: Curves.fastOutSlowIn));
		
		checkViewAndBound();
  }

  @override
  void dispose() {
  	animationController.removeListener(() { deltaNotifier.value = animation.value; });
		animationController.removeStatusListener((_) {});
		animationController.dispose();
		
		reset();
		
    super.dispose();
  }
  
  void checkViewAndBound(){
  	if(!viewIsSet) 
  		setView();
  	else checkViewOrigin();
  	if(!boundIsSet) 
  		setBound();
  	else checkBoundOrigin();
  }
  
  void setView(){
  	try{
	    if(viewKey.currentContext == null) return;
	    if (viewRenderBox == null) viewRenderBox = viewKey.currentContext.findRenderObject();
	    
	    if(viewRenderBox != null){
		      if(viewRenderBox.hasSize && !viewRenderBox.debugNeedsLayout){
		        if(viewWidth == -1)
			        viewWidth = viewRenderBox.size.width;
			      if(viewHeight == -1)
			        viewHeight = viewRenderBox.size.height;
				  }
	      
	      if(viewOrigin==null)
	        viewOrigin = viewRenderBox.localToGlobal(Offset.zero);
	    }
  	} catch(_){}
  }
  
  bool get viewIsSet => !(viewWidth == -1 ||viewHeight == -1 || viewOrigin == null);
  
  void setBound(){
  	try {
	    if(boundKey.currentContext == null) return;
	    if(boundRenderBox == null) boundRenderBox = boundKey.currentContext.findRenderObject();
	    
	    if(boundRenderBox != null){
		    if(boundRenderBox.hasSize){
			    if(boundWidth == -1)
			      boundWidth = boundRenderBox.size.width + widget.customBoundWidth;
			    if(boundHeight == -1)
			      boundHeight =  boundRenderBox.size.height + widget.customBoundHeight;
			    
			    if(boundWidth != -1 && boundHeight != -1)
			    	normaliseConstraints();
		    }
	    } 
	    if(boundOrigin==null)
	        boundOrigin = boundRenderBox.localToGlobal(Offset.zero);
  	}
  	catch(_){}
  }
  
  bool get boundIsSet => !(boundWidth == -1 || boundHeight == -1 ||boundOrigin == null) ;
  
  void checkViewOrigin(){
  	if(viewOrigin != viewRenderBox.localToGlobal(Offset.zero) - deltaNotifier.value)
  		viewOrigin = viewRenderBox.localToGlobal(Offset.zero) - deltaNotifier.value;
  }
  
  void checkBoundOrigin(){
  	if(boundOrigin != boundRenderBox.localToGlobal(Offset.zero))
  		boundOrigin = boundRenderBox.localToGlobal(Offset.zero);
  }
  
  void normaliseConstraints(){
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
  
  void beginDrag(DragStartDetails dragStartDetails){
    if (_debugLevel > 0) 
      print("BeginDrag");
    
    checkViewAndBound();
    
    delta = deltaNotifier.value;
    beginDragPosition = dragStartDetails.localPosition;
  }
  
  void updateDrag(DragUpdateDetails dragUpdateDetails){
    if (_debugLevel > 0) 
      print("UpdateDrag");
    
    checkViewAndBound();
    
    updateDragPosition = dragUpdateDetails.localPosition;
    setDelta();
  }
  
  void endDrag(DragEndDetails dragEndDetails){
    if (_debugLevel > 0) 
      print("EndDrag");
    
    checkViewAndBound();
    
    snap();
  }
  
  void setDelta(){
    if(beginDragPosition == null || updateDragPosition == null) return;
    if(!viewIsSet || !boundIsSet) return;
    
    Offset _delta = delta + Offset(
													    updateDragPosition.dx-beginDragPosition.dx, 
													    updateDragPosition.dy-beginDragPosition.dy);
    normalisedConstraintsMin = constraintsMin - viewOrigin + boundOrigin;
    normalisedConstraintsMax = constraintsMax - viewOrigin + boundOrigin - Offset(viewWidth, viewHeight);
    if(_delta.dx < normalisedConstraintsMin.dx)
      _delta = Offset(
					      normalisedConstraintsMin.dx - pow((_delta.dx-normalisedConstraintsMin.dx).abs(), flexibilityMin.dx) + 1.0, 
					      _delta.dy);
    if(_delta.dx > normalisedConstraintsMax.dx)
      _delta = Offset(
					      normalisedConstraintsMax.dx + pow((_delta.dx-normalisedConstraintsMax.dx).abs(), flexibilityMax.dx) - 1.0, 
					      _delta.dy);
    if(_delta.dy < normalisedConstraintsMin.dy)
      _delta = Offset(
					      _delta.dx, 
					      normalisedConstraintsMin.dy - pow((_delta.dy-normalisedConstraintsMin.dy).abs(), flexibilityMin.dy) + 1.0);
    if(_delta.dy > normalisedConstraintsMax.dy)
      _delta = Offset(
					      _delta.dx, 
					      normalisedConstraintsMax.dy + pow((_delta.dy-normalisedConstraintsMax.dy).abs(), flexibilityMax.dy) - 1.0);
    
    deltaNotifier.value=_delta;
    
    if(onMove!=null) onMove(deltaNotifier.value);
  }
  
  double get maxLeft => boundOrigin.dx - viewOrigin.dx;
  
  double get maxRight => boundWidth + boundOrigin.dx - viewWidth - viewOrigin.dx;
  
  double get maxTop => boundOrigin.dy - viewOrigin.dy;
  
  double get maxBottom => boundHeight + boundOrigin.dy - viewHeight - viewOrigin.dy;
  
  Future snap() async{
  	Offset snapTarget = getSnapTarget();
  	if(animateSnap)
  		await move(snapTarget);
  	else
  		deltaNotifier.value = snapTarget;
  	
  	delta=Offset.zero;
	  beginDragPosition = null;
	  updateDragPosition = null;
	  overrideDelta = Offset.zero;
	  if(onSnap != null) onSnap(deltaNotifier.value);
  }
  
  Offset getSnapTarget() {
  	if (snapTargets == null) 
			return deltaNotifier.value;
		else{
			Map<Offset,double> map = Map<Offset,double>();
			snapTargets.forEach((SnapTarget snapTarget){
				if(Pivot.isClosestHorizontal(snapTarget.viewPivot) || Pivot.isClosestAny(snapTarget.viewPivot)){
					Offset left = Offset(
													0 -viewOrigin.dx + boundOrigin.dx, 
													deltaNotifier.value.dy.clamp(maxTop, maxBottom));
					map[left] = Point(deltaNotifier.value.dx,deltaNotifier.value.dy).distanceTo(Point(left.dx, left.dy));
					if(_debugLevel > 1){
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
					Offset right= Offset(
													boundWidth + -viewOrigin.dx + boundOrigin.dx - viewWidth, 
													deltaNotifier.value.dy.clamp(maxTop, maxBottom));
					map[right] = Point(deltaNotifier.value.dx,deltaNotifier.value.dy).distanceTo(Point(right.dx, right.dy));
					if(_debugLevel>1){
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
				if(Pivot.isClosestVertical(snapTarget.viewPivot) || Pivot.isClosestAny(snapTarget.viewPivot)){
					Offset top = Offset(
												deltaNotifier.value.dx.clamp(maxLeft, maxRight), 
												0 -viewOrigin.dy + boundOrigin.dy,);
					map[top] = Point(deltaNotifier.value.dx,deltaNotifier.value.dy).distanceTo(Point(top.dx, top.dy));
					if(_debugLevel>1){
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
					map[bottom] = Point(deltaNotifier.value.dx,deltaNotifier.value.dy).distanceTo(Point(bottom.dx, bottom.dy));
					if(_debugLevel>1){
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
				if(!Pivot.isClosestHorizontal(snapTarget.viewPivot) && !Pivot.isClosestVertical(snapTarget.viewPivot) && !Pivot.isClosestAny(snapTarget.viewPivot)){
					Offset offset = Offset(
													boundWidth*snapTarget.boundPivot.dx + boundOrigin.dx - viewWidth*snapTarget.viewPivot.dx - viewOrigin.dx, 
													boundHeight*snapTarget.boundPivot.dy + boundOrigin.dy - viewHeight*snapTarget.viewPivot.dy - viewOrigin.dy);
					if(_debugLevel>1){
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
					map[offset] = Point(deltaNotifier.value.dx,deltaNotifier.value.dy).distanceTo(Point(offset.dx, offset.dy));
				}
			});
			
			return map.keys.firstWhere((Offset offset){
							return map[offset] == map.values.reduce(min);
						 });
		}
	}
  
	Future move(Offset snapTarget) async{
		animation = 
			Tween(
				begin: deltaNotifier.value, 
				end: snapTarget)
			.animate(CurvedAnimation(
								parent: animationController, 
								curve: Curves.fastOutSlowIn));
		animationController.forward(from:0);
		await Future.delayed(Duration(milliseconds: 333));
		return;
	}
	
  bool get isMoved {
    return deltaNotifier.value.dx.abs() > 10 || deltaNotifier.value.dy.abs() > 10;
  }
  
  void reset(){
  	delta=Offset.zero;
    beginDragPosition = null;
    updateDragPosition = null;
    overrideDelta = Offset.zero;
    deltaNotifier.value = Offset.zero;
  }
  
  @override
  Widget build(BuildContext context) {
  	checkViewAndBound();
  	
    return ValueListenableBuilder(
	          child: useCache 
	                 ? GestureDetector(
		                  behavior: HitTestBehavior.opaque,
										  onVerticalDragStart: beginDrag,
										  onVerticalDragUpdate: updateDrag,
										  onVerticalDragEnd: endDrag,
										  onHorizontalDragStart: beginDrag,
										  onHorizontalDragUpdate: updateDrag,
										  onHorizontalDragEnd: endDrag,
										  child: child) 
	                 : null,
	          builder: 
	          (BuildContext context, Offset delta, Widget cachedChild) {
	            return Transform.translate(
		                          offset: delta,
		                          child: useCache 
		                                 ? cachedChild 
		                                 : GestureDetector(
			                                  behavior: HitTestBehavior.opaque,
																			  onVerticalDragStart: beginDrag,
																			  onVerticalDragUpdate: updateDrag,
																			  onVerticalDragEnd: endDrag,
																			  onHorizontalDragStart: beginDrag,
																			  onHorizontalDragUpdate: updateDrag,
																			  onHorizontalDragEnd: endDrag,
																			  child: child));
	          },
	          valueListenable: deltaNotifier);
  }
}