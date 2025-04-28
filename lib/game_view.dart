import 'package:app_ui/app_ui.dart';
import 'package:flame/game.dart';
import 'package:flame_jam_2025/game/satellites_game.dart';
import 'package:flame_jam_2025/overlays/game_over.dart';
import 'package:flame_jam_2025/overlays/pause_menu.dart';
import 'package:flame_jam_2025/overlays/victory.dart';
import 'package:flutter/material.dart';

class MyGame extends StatelessWidget {
  const MyGame({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    bool isPlaying;
    if (args == null) {
      isPlaying = true;
    } else {
      isPlaying = args as bool;
    }

    return Material(
      child: GameView(
        isPlaying: isPlaying,
      ),
    );
  }
}

class GameView extends StatefulWidget {
  const GameView({super.key, required this.isPlaying});

  final bool? isPlaying;

  @override
  State<GameView> createState() => _GameViewState();
}

class _GameViewState extends State<GameView> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {'NewGame': (context) => MyGame()},
      theme: ThemeData(textTheme: SatellitesTheme.standard.textTheme),
      home: Scaffold(
        body: GameWidget<SatellitesGame>.controlled(
          overlayBuilderMap: {
            'Game Over': (_, game) => GameOver(game: game),
            'Victory': (_, game) => VictoryOverlay(game: game),
            'Pause Menu': (_, game) => PauseMenu(game: game),
          },
          gameFactory: () =>
              SatellitesGame(isPlaying: widget.isPlaying ?? true),
        ),
      ),
    );
  }
}
