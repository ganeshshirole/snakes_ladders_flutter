import 'package:flutter/material.dart';
import 'package:snakes_ladders/pages/game_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Snakes Ladders',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: GamePage(title: 'Snakes Ladders'),
    );
  }
}
