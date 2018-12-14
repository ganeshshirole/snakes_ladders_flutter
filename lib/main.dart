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
  StateSetter gridState;
  StateSetter diceState;
  StateSetter playerLabelState;
  BuildContext context;

  final String title;

  var player1Pos = 1;
  var player2Pos = 1;

  var player1GotoPos = 0;
  var player2GotoPos = 0;

  var isRunning = false;
  var randomNumber = 0;
  var player1 = true;

  var diceAnimationCounter = 0;
  var moveAnimationCounter = 0;

  var rnd = new Random();
  var diceIcons = [
    'images/one.webp',
    'images/two.webp',
    'images/three.webp',
    'images/four.webp',
    'images/five.webp',
    'images/six.webp'
  ];

  MyHomePage({Key key, this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    this.context = context;
    var screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        body: SafeArea(
            child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Stack(
          children: <Widget>[
            Image.asset('images/snakes_ladders_game_background.webp'),
            FutureBuilder<GridData>(
              future: _readJson(),
              builder:
                  (BuildContext context, AsyncSnapshot<GridData> snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                    return Text('None');
                  case ConnectionState.active:
                  case ConnectionState.waiting:
                    return Text('Awaiting result...');
                  case ConnectionState.done:
                    if (snapshot.hasError)
                      return Text('Error: ${snapshot.error}');
                    return StatefulBuilder(
                        builder: (BuildContext context, StateSetter setState) {
                      gridState = setState;
                      return GridView.builder(
                        shrinkWrap: true,
                        itemBuilder: (context, position) {
                          if (player1) {
                            if (player1Pos ==
                                snapshot.data.gridItems[position].position)
                              player1GotoPos = snapshot
                                  .data.gridItems[position].goToPosition;
                          } else if (player2Pos ==
                              snapshot.data.gridItems[position].position)
                            player2GotoPos =
                                snapshot.data.gridItems[position].goToPosition;

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
                                      width: screenWidth / 11,
                                    ),
                                  ),
                                  Visibility(
                                    visible: player2Pos ==
                                        snapshot
                                            .data.gridItems[position].position,
                                    child: SvgPicture.asset(
                                      'vectors/pawn2.svg',
                                      fit: BoxFit.fitHeight,
                                      height: screenWidth / 11,
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
                      );
                    });
                }
                return null; // unreachable
              },
            ),
          ],
        ),
        GestureDetector(
            onTap: startTimeout,
            child: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
              diceState = setState;
              return Image.asset(
                diceIcons[randomNumber],
                height: 80.0,
              );
            })),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            playerLabelState = setState;
            return Text(
              (player1 ? 'Player 1' : 'Player 2'),
              style: TextStyle(fontSize: 18.0, color: Colors.blue),
            );
          }),
        )
      ],
    )));
  }

  Future<GridData> _readJson() async {
    var jsonString = await rootBundle.loadString('assets/grid_data.json');
    GridData gridData = GridData.fromJson(jsonDecode(jsonString));
    return gridData;
  }

  startTimeout() async {
    if (!isRunning) {
      isRunning = true;
      var duration = const Duration(milliseconds: 100);
      Timer.periodic(
          duration, (Timer diceTimer) => handleDiceTimeout(diceTimer));
    }
  }

  handleDiceTimeout(diceTimer) {
    diceState(() {
      randomNumber = rnd.nextInt(6);
    });
    if (diceAnimationCounter > 10) {
      diceAnimationCounter = 0;
      diceTimer.cancel();

      var playerPos = player1 ? player1Pos : player2Pos;
      if (playerPos == 1)
        movesTimer(randomNumber == 0);
      else
        movesTimer((playerPos + randomNumber + 1) <= 25);
    } else
      diceAnimationCounter += 1;
  }

  movesTimer(bool start) {
    if (start) {
      var duration = const Duration(milliseconds: 500);
      Timer.periodic(
          duration, (Timer movesTimer) => handleMoveTimeout(movesTimer));
    } else {
      playerLabelState(() {
        player1 = !player1;
      });

      isRunning = false;
    }
  }

  handleMoveTimeout(Timer movesTimer) {
    if (moveAnimationCounter <= randomNumber) {
      moveAnimationCounter += 1;
      gridState(() {
        if (player1)
          player1Pos += 1;
        else
          player2Pos += 1;
      });
    } else if (moveAnimationCounter == (randomNumber + 1)) {
      moveAnimationCounter += 1;
      if (player1) {
        if (player1GotoPos != 0) {
          gridState(() {
            player1Pos = player1GotoPos;
          });
        } else
          stopMoveAnimation(movesTimer);
      } else {
        if (player2GotoPos != 0) {
          gridState(() {
            player2Pos = player2GotoPos;
          });
        } else
          stopMoveAnimation(movesTimer);
      }
    } else
      stopMoveAnimation(movesTimer);
  }

  stopMoveAnimation(moveTimer) {
    moveAnimationCounter = 0;
    moveTimer.cancel();

    isRunning = false;

    // Player win
    if (player1Pos == 25 || player2Pos == 25)
      _showDialog();
    else {
      playerLabelState(() {
        player1 = !player1;
      });
    }
  }

  // reset if position 25
  reset() {
    playerLabelState(() {
      player1 = true;
    });
    gridState(() {
      player1Pos = 1;
      player2Pos = 1;
    });
    Navigator.of(context).pop();
  }

  // user defined function
  void _showDialog() {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text('Player ' + (player1 ? '1' : '2') + ' Winner'),
          content: new Text(
              "Congrats on your win, congrats on your fearless effort; congrats on your achievements and wish you many congrats for your future. Always have faith in you and have courage to win any challenge that comes your way. Congratulation."),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Thanks"),
              onPressed: () {
                reset();
              },
            ),
          ],
        );
      },
    );
  }
}
