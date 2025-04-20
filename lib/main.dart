import 'package:flame/game.dart';
import 'package:flame_jam_2025/game/pesky_satellites.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: GameWidget<PeskySatellites>.controlled(
          gameFactory: () => PeskySatellites(),
        ),
      ),
    );
  }
}
