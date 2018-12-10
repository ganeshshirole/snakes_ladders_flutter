import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:snakes_ladders/model/grid_data.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Game',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Home Page'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;
  var player1Pos = 1;
  var player2Pos = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: FutureBuilder<GridData>(
        future: _readJson(),
        builder: (BuildContext context, AsyncSnapshot<GridData> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
              return Text('None');
            case ConnectionState.active:
            case ConnectionState.waiting:
              return Text('Awaiting result...');
            case ConnectionState.done:
              if (snapshot.hasError) return Text('Error: ${snapshot.error}');
              return Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Stack(
                    children: <Widget>[
                      Image.asset('images/snakes_ladders_game_background.webp'),
                      GridView.builder(
                        shrinkWrap: true,
                        itemBuilder: (context, position) {
                          return Container(
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Visibility(
                                    visible: player1Pos ==
                                        snapshot
                                            .data.gridItems[position].position,
                                    child: SvgPicture.asset(
                                      'vectors/pawn1.svg',
                                      fit: BoxFit.fitHeight,
                                      width:
                                          (MediaQuery.of(context).size.width /
                                              11),
                                    ),
                                  ),
                                  Visibility(
                                    visible: player2Pos ==
                                        snapshot
                                            .data.gridItems[position].position,
                                    child: SvgPicture.asset(
                                      'vectors/pawn2.svg',
                                      fit: BoxFit.fitHeight,
                                      height:
                                          (MediaQuery.of(context).size.width /
                                              11),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        itemCount: snapshot.data.gridItems.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 5),
                      )
                    ],
                  ),
                  Dice(),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Player 1',
                      style: TextStyle(fontSize: 18.0, color: Colors.blue),
                    ),
                  )
                ],
              );
          }
          return null; // unreachable
        },
      ),
    ));
  }

  Future<GridData> _readJson() async {
    var jsonString = await rootBundle.loadString('assets/grid_data.json');
    GridData gridData = GridData.fromJson(jsonDecode(jsonString));
    /*for (GridItem gridItem in gridData.gridItems) {
      print(gridItem.position.toString() + "\n");
    }*/
    return gridData;
  }
}

class Dice extends StatefulWidget {
  @override
  DiceState createState() => DiceState();
}

class DiceState extends State<Dice> {
  var randomNumber = 0;
  var diceAnimationCounter = 0;
  var rnd = new Random();
  var diceIcons = [
    'images/one.webp',
    'images/two.webp',
    'images/three.webp',
    'images/four.webp',
    'images/five.webp',
    'images/six.webp'
  ];

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: startTimeout,
      child: Image.asset(
        diceIcons[randomNumber],
        height: 80.0,
      ),
    );
  }

  startTimeout() async {
    var duration = const Duration(milliseconds: 100);
    Timer.periodic(duration, (Timer t) => handleTimeout(t));
  }

  void handleTimeout(timer) {
    setState(() {
      randomNumber = rnd.nextInt(5);
    });
    if (diceAnimationCounter > 10) {
      diceAnimationCounter = 0;
      timer.cancel();
    } else
      diceAnimationCounter++;
  }
}
