import 'package:app_ui/app_ui.dart';
import 'package:flame/game.dart';
import 'package:flame_jam_2025/game/satellites_game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'dart:developer' as dev;

void main() {
  Logger.root.level = kDebugMode ? Level.FINE : Level.INFO;
  Logger.root.onRecord.listen((record) {
    dev.log(
      record.message,
      time: record.time,
      level: record.level.value,
      name: record.loggerName,
      zone: record.zone,
      error: record.error,
      stackTrace: record.stackTrace,
    );
  });
  FlutterError.onError = (details) {
    dev.log(details.exceptionAsString(), stackTrace: details.stack);
  };
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(textTheme: SatellitesTheme.standard.textTheme),
      home: Scaffold(
        body: GameWidget<SatellitesGame>.controlled(
          gameFactory: () => SatellitesGame(),
        ),
      ),
    );
  }
}
