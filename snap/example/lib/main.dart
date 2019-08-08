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
			      theme: ThemeData(primarySwatch: Colors.blue,),
			      home: MyHomePage(title: 'Snap Demo'));
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
	double bottom=-200.0;
	
	@override
	void initState() {
    super.initState();
    for(int i=0; i<6; i++){
    	bounds.add(GlobalKey());
    	views.add(GlobalKey());
    }
  }
  
  void snap(_){
		Scaffold.of(context).showSnackBar(SnackBar(content: Text("Snapped!")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
		        appBar: AppBar(title: Text(widget.title)),
		        body: PageView(
		        onPageChanged: (int index){
		        	if(index == 1)
		        		setState(() {
		        			bottom=0.0;
				        });
		        	else 
		        		setState(() {
		        			bottom=-200.0;
				        });
		        },
		        children: [
		        	Scaffold(
			            body: Column(
												  crossAxisAlignment: CrossAxisAlignment.start,
							            children: [
							            	description("The box will snap to the corners or the center."),
							              gap(),
							              Expanded(child:Container(
									                          key: bounds[0],
									                          constraints: BoxConstraints.expand(),
									                          color: Colors.transparent,
																            child: Column(
																	                  crossAxisAlignment: CrossAxisAlignment.start,
																									  children:[
																									    SnapController(
																											  firstNormalBoxBuilder,
																											  false,
																											  views[0],
																											  bounds[0],
																											  Offset(0.0, 0.0),
																										    Offset(1.0, 1.0),
																								        Offset(0.75, 0.75),
																								        Offset(0.75, 0.75),
																								        snapTargets: [
																									        SnapTarget(Pivot.topLeft, Pivot.topLeft),
																									        SnapTarget(Pivot.topRight, Pivot.topRight),
																									        SnapTarget(Pivot.bottomLeft, Pivot.bottomLeft),
																									        SnapTarget(Pivot.bottomRight, Pivot.bottomRight),
																									        SnapTarget(Pivot.center, Pivot.center)
																								        ],
																											  animateSnap: true)
																									  ])))	
							            ])),
			        Scaffold(
			            body: Column(
												  crossAxisAlignment: CrossAxisAlignment.start,
							            children: [
							            	description("The box will snap to the closest side regardless of animation."),
							              gap(),
							              Expanded(child:Container(
									                          key: bounds[1],
									                          constraints: BoxConstraints.expand(),
									                          color: Colors.transparent,
																            child: Stack(
																									  children:[
																									    AnimatedPositioned(
																										      left: 0,
																											    bottom: bottom,
																											    duration: Duration(milliseconds: 300),
																											    child:SnapController(
																																  animatedBoxBuilder,
																																  false,
																																  views[1],
																																  bounds[1],
																																  Offset(0.0, 0.0),
																															    Offset(1.0, 1.0),
																													        Offset(0.75, 0.75),
																													        Offset(0.75, 0.75),
																													        snapTargets: [
																														        SnapTarget(Pivot.closestAny, Pivot.closestAny)
																													        ],
																																  animateSnap: true))
																									  ])))
							            ])),
	            Scaffold(
			            body: Column(
												  crossAxisAlignment: CrossAxisAlignment.start,
							            children: [
							            	description("The box will snap to the closest matching color."),
							              gap(),
							              Expanded(child:Container(
									                          key: bounds[2],
									                          constraints: BoxConstraints.expand(),
									                          color: Colors.transparent,
																            child: Stack(
																	            children: [
																	            	Column(
																	                  crossAxisAlignment: CrossAxisAlignment.start,
																									  children:[
																									    SnapController(
																											  dottedBoxBuilder,
																											  false,
																											  views[2],
																											  bounds[2],
																											  Offset(0.0, 0.0),
																										    Offset(1.0, 1.0),
																								        Offset(0.75, 0.75),
																								        Offset(0.75, 0.75),
																								        snapTargets: [
																									        SnapTarget(Offset(0.1,0.1), Offset(0.1,0.1)),
																									        SnapTarget(Offset(0.9,0.1), Offset(0.85,0.465)),
																									        SnapTarget(Offset(0.1,0.9), Offset(0.1,0.9)),
																								        ],
																											  animateSnap: true)]),
																		            Align(alignment: Alignment(-0.85,-0.85),child: Container(width: 10,height: 10, color: Colors.orangeAccent)),
																								Align(alignment: Alignment(0.75,-0.1),child: Container(width: 10,height: 10, color: Colors.black)),
																								Align(alignment: Alignment(-0.85,0.85),child: Container(width: 10,height: 10, color: Colors.deepPurpleAccent))
																	            ])))	
							            ])),
	            Scaffold(
			            body: Column(
												  crossAxisAlignment: CrossAxisAlignment.start,
							            children: [
							            	description("The box will snap to the corners or the center while maintaining the initial offset"),
							              gap(),
							              Expanded(child:Container(
									                          key: bounds[3],
									                          constraints: BoxConstraints.expand(),
														                color: Colors.transparent,
																            child: Column(
																	                  crossAxisAlignment: CrossAxisAlignment.center,
																									  children:[
																									    SnapController(
																											  translatedBoxBuilder,
																											  false,
																											  views[3], 
																											  bounds[3],
																											  Offset(50.0/MediaQuery.of(context).size.width, 50.0/MediaQuery.of(context).size.height),
																									      Offset(1.0,1.0)-Offset(50.0/MediaQuery.of(context).size.width, 50.0/MediaQuery.of(context).size.height),
																								        Offset(0.75, 0.75),
																								        Offset(0.75, 0.75),
																								        snapTargets: [
																									        SnapTarget(Pivot.topLeft, Offset(50.0/MediaQuery.of(context).size.width, 50.0/MediaQuery.of(context).size.height)),
																									        SnapTarget(Pivot.topRight, Offset(1.0 - 50.0/MediaQuery.of(context).size.width, 50.0/MediaQuery.of(context).size.height)),
																									        SnapTarget(Pivot.bottomLeft, Offset(50.0/MediaQuery.of(context).size.width, 1.0 - 50.0/MediaQuery.of(context).size.height)),
																									        SnapTarget(Pivot.bottomRight, Offset(1.0,1.0)-Offset(50.0/MediaQuery.of(context).size.width, 50.0/MediaQuery.of(context).size.height)),
																									        SnapTarget(Pivot.center, Pivot.center)
																								        ],
																											  animateSnap: true)
																									  ])))	
							            ])),
						  Scaffold(
			            body: Column(
												  crossAxisAlignment: CrossAxisAlignment.start,
							            children: [
							            	description("The box will snap to the closest side or the center within its container."),
							              gap(),
							              Center(child:Container(
								                          key: bounds[4],
												                  width: 300,
													                height: 300,
													                color: Colors.orangeAccent,
															            child: Column(
																                  crossAxisAlignment: CrossAxisAlignment.start,
																								  children:[
																								    SnapController(
																										  smallBoxBuilder,
																										  false,
																										  views[4], 
																										  bounds[4],
																										  Offset(0.0, 0.0),
																								      Offset(1.0, 1.0),
																							        Offset(0.75, 0.75),
																							        Offset(0.75, 0.75),
																							        snapTargets: [
																							        	SnapTarget(Pivot.closestAny, Pivot.closestAny),
																								        SnapTarget(Pivot.center, Pivot.center)
																							        ],
																										  animateSnap: true,
																										  onSnap: snap)
																								  ])))	
							            ])),
			        Scaffold(
			            body: Column(
												  crossAxisAlignment: CrossAxisAlignment.start,
							            children: [
							            	description("The box will snap to the corners or the center without animation."),
							              gap(),
							              Expanded(child:Container(
									                          key: bounds[5],
									                          constraints: BoxConstraints.expand(),
									                          color: Colors.transparent,
																            child: Column(
																	                  crossAxisAlignment: CrossAxisAlignment.start,
																									  children:[
																									    SnapController(
																											  secondNormalBoxBuilder,
																											  false,
																											  views[5],
																											  bounds[5],
																											  Offset(0.0, 0.0),
																										    Offset(1.0, 1.0),
																								        Offset(0.75, 0.75),
																								        Offset(0.75, 0.75),
																								        snapTargets: [
																									        SnapTarget(Pivot.topLeft, Pivot.topLeft),
																									        SnapTarget(Pivot.topRight, Pivot.topRight),
																									        SnapTarget(Pivot.bottomLeft, Pivot.bottomLeft),
																									        SnapTarget(Pivot.bottomRight, Pivot.bottomRight),
																									        SnapTarget(Pivot.center, Pivot.center)
																								        ],
																											  animateSnap: false)
																									  ])))	
							            ])),
					  ]));
  }
}

Widget description(String text){
	return Container(
		      constraints: BoxConstraints.expand(height:75),
			    color: Colors.green,
		      child: Center(child:Padding(
																padding: EdgeInsets.all(10), 
																child:Text(
																	      text,
																	      style: TextStyle(
																					      color: Colors.white, 
																					      fontWeight: FontWeight.bold, 
																					      fontSize: 15),
																	      textAlign: TextAlign.center))));
}

Widget gap(){
	return Container(
		      constraints: BoxConstraints.expand(height:25),
			    color: Colors.transparent,
		      child: Center(child:Text(
													      "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - ",
													      style: TextStyle(
																	      color: Colors.black, 
																	      fontWeight: FontWeight.bold, 
																	      fontSize: 10),
													      textAlign: TextAlign.center)));
}

Widget firstNormalBoxBuilder(BuildContext context){
	return normalBox(
				  views[0],
			    "Move & Snap", 
			    Colors.redAccent);
}

Widget animatedBoxBuilder(BuildContext context){
	return normalBox(
				  views[1],
			    "Move & Snap", 
			    Colors.redAccent);
}

Widget dottedBoxBuilder(BuildContext context){
	return dottedBox(
				  views[2],
			    "Move & Snap", 
			    Colors.redAccent);
}

Widget translatedBoxBuilder(BuildContext context){
	return translatedBox(
				  views[3],
			    "Move & Snap", 
			    Colors.redAccent);
}

Widget smallBoxBuilder(BuildContext context){
	return smallBox(
				  views[4],
			    "*", 
			    Colors.redAccent);
}

Widget secondNormalBoxBuilder(BuildContext context){
	return normalBox( 
				  views[5],
			    "Move & Snap", 
			    Colors.redAccent);
}

Widget normalBox(Key key, String text, Color color){
	return Container(
							key: key,
							width: 200,
							height: 200,
							color: Colors.transparent, 
							child: Padding(
											padding: EdgeInsets.all(5), 
											child: Container(
												      constraints: BoxConstraints.expand(),
													    decoration: BoxDecoration(
																			      color: color,
																				    borderRadius: const BorderRadius.all(const Radius.circular(10.0))),
												      child: Center(child:Text(
																							      text,
																							      style: TextStyle(
																											      color: Colors.white, 
																											      fontWeight: FontWeight.bold, 
																											      fontSize: 25))))));
}

Widget translatedBox(Key key, String text, Color color){
	return Transform.translate(
					offset: Offset(50,50),
					child: Container(
									key: key,
									width: 200,
									height: 200,
									color: Colors.transparent, 
									child: Padding(
											padding: EdgeInsets.all(5), 
											child: Container(
												      constraints: BoxConstraints.expand(),
													    decoration: BoxDecoration(
																			      color: color,
																				    borderRadius: const BorderRadius.all(const Radius.circular(10.0))),
												      child: Center(child:Text(
																							      text,
																							      style: TextStyle(
																											      color: Colors.white, 
																											      fontWeight: FontWeight.bold, 
																											      fontSize: 25)))))));
}

Widget smallBox(Key key, String text, Color color){
	return Container(
							key: key,
							width: 50,
							height: 50,
							color: Colors.transparent, 
							child: Padding(
											padding: EdgeInsets.all(5), 
											child: Container(
												      constraints: BoxConstraints.expand(),
													    decoration: BoxDecoration(
																			      color: color,
																				    borderRadius: const BorderRadius.all(const Radius.circular(0.0))),
												      child: Center(child:Text(
																							      text,
																							      style: TextStyle(
																											      color: Colors.white, 
																											      fontWeight: FontWeight.bold, 
																											      fontSize: 25))))));
}

Widget dottedBox(Key key, String text, Color color){
	return Transform.translate(
					offset: Offset(75,100),
					child: Container(
									key: key,
									width: 200,
									height: 200,
									color: Colors.transparent, 
									child: Stack(
										children: [
											Padding(
													padding: EdgeInsets.all(5), 
													child: Container(
														      constraints: BoxConstraints.expand(),
															    decoration: BoxDecoration(
																					      color: color,
																						    borderRadius: const BorderRadius.all(const Radius.circular(10.0))),
														      child: Center(child:Text(
																									      text,
																									      style: TextStyle(
																													      color: Colors.white, 
																													      fontWeight: FontWeight.bold, 
																													      fontSize: 25))))),
											Align(alignment: Alignment(-0.9,-0.9),child: Container(width: 10,height: 10, color: Colors.orangeAccent)),
											Align(alignment: Alignment(0.9,-0.9),child: Container(width: 10,height: 10, color: Colors.black)),
											Align(alignment: Alignment(-0.9,0.9),child: Container(width: 10,height: 10, color: Colors.deepPurpleAccent))
										]
									)));
}
//@formatter:on