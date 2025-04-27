import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_jam_2025/game/managers/wave_manager.dart';
import 'package:flame_jam_2025/game/satellites_game.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

class StoryComponent extends PositionComponent
    with HasGameReference<SatellitesGame> {
  StoryComponent({
    super.position,
    super.anchor,
    super.size,
    super.scale,
  });
  static final Logger _log = Logger('Story Component');
  late TextBoxComponent storyComponent;

  bool isFinished = false;

  String storyText = '';

  late Timer readingTimer;

  final bgPaint = Paint()..color = Colors.white.withAlpha(150);
  final borderPaint = Paint()
    ..color = Color(0xFF000000)
    ..style = PaintingStyle.stroke;

  @override
  FutureOr<void> onLoad() {
    readingTimer = Timer(
      3,
      autoStart: false,
      repeat: false,
      onTick: () {
        isFinished = true;
        game.waveManager.spawnTimer.start();
        removeStory();
      },
    );
    add(
      TextBoxComponent(
        align: Anchor.center,
        boxConfig: TextBoxConfig(
          timePerChar: 0.05,
          growingBox: true,
        ),
        textRenderer: TextPaint(
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        text: storyLine[0],
        onComplete: () => readingTimer.start(),
        position: Vector2.zero(),
      ),
    );
    return super.onLoad();
  }

  void removeStory() {
    removeWhere((e) => e is TextBoxComponent);
  }

  void addStory() {
    _log.info(updateText());

    add(
      TextBoxComponent(
        priority: 5,
        align: Anchor.center,
        boxConfig: TextBoxConfig(
          timePerChar: 0.05,
          growingBox: true,
        ),
        textRenderer: TextPaint(
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        text: updateText(),
        onComplete: () => readingTimer.start(),
        position: Vector2(50, 50),
      )..debugMode = true,
    );
  }

  @override
  void update(double dt) {
    if (readingTimer.isRunning()) {
      readingTimer.update(dt);
    }
    if (game.waveManager.state == WaveState.end && isFinished) {
      isFinished = false;
      add(
        TextBoxComponent(
          align: Anchor.center,
          boxConfig: TextBoxConfig(
            timePerChar: 0.05,
            growingBox: true,
          ),
          textRenderer: TextPaint(
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          text: storyLine[0],
          onComplete: () => readingTimer.start(),
          position: Vector2.zero(),
        ),
      );
    }
    super.update(dt);
  }

  String updateText() {
    _log.info('Update Text');
    int index = game.waveManager.waveNumber - 1;
    if (game.orbitingSatellites.isEmpty && game.destroyedSatellites.isEmpty) {
      if (notBreaking.length >= index) {
        return notBreaking[index];
      } else {
        return '';
      }
    } else {
      if (storyLine.length >= index) {
        return storyLine[index];
      } else {
        return '';
      }
    }
  }

  List<String> storyLine = [
    'Breaking News! The Green Country has successfully launched the first satellite to Jupiter! Other countries are pushing to have the most satellites orbiting the planet.',
    'Breaking News! Scientist Intern makes wild claims that Jupiter is sentient after the launched satellite exploded!',
  ];
  List<String> notBreaking = [
    'Breaking News! The Green Country has successfully launched the first satellite to Jupiter! Other countries are pushing to have the most satellites orbiting the planet.'
        'Breaking News! Scientists find more information about Jupiter, further exciting the rest of the world to continue sending satellites!',
  ];
}
