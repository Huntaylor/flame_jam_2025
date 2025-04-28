import 'dart:async';

import 'package:app_ui/app_ui.dart';
import 'package:flame/components.dart';
import 'package:flame_jam_2025/game/forge_components/satellite/satellite_component.dart';
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

  String bestCountryName = '';
  int bestCountryCount = 0;

  int greenCountry = 0;
  int greyCountry = 0;
  int cyanCountry = 0;
  int whiteCountry = 0;
  int pinkCountry = 0;
  int brownCountry = 0;

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

    return super.onLoad();
  }

  void startStory() {
    add(
      TextBoxComponent(
        align: Anchor.center,
        boxConfig: TextBoxConfig(
          timePerChar: 0.05,
          growingBox: true,
        ),
        textRenderer: TextPaint(
            style: SatellitesTextStyle.headlineSmall
                .copyWith(fontSize: 12, color: Colors.white)),
        text: storyLine[0],
        onComplete: () => readingTimer.start(),
        position: Vector2.zero(),
      ),
    );
  }

  void removeStory() {
    removeWhere((e) => e is TextBoxComponent);
  }

  void addStory() {
    currentWinningCountry();
    _log.info(updateText());

    add(TextBoxComponent(
      priority: 5,
      align: Anchor.center,
      boxConfig: TextBoxConfig(
        timePerChar: 0.05,
        growingBox: true,
      ),
      textRenderer: TextPaint(
          style: SatellitesTextStyle.headlineSmall
              .copyWith(fontSize: 12, color: Colors.white)),
      text: updateText(),
      onComplete: () => readingTimer.start(),
      position: Vector2.zero(),
    ));
  }

  @override
  void update(double dt) {
    if (readingTimer.isRunning()) {
      readingTimer.update(dt);
    }
    if (game.waveManager.state == WaveState.end &&
        isFinished &&
        game.gameState != GameState.end) {
      isFinished = false;
      addStory();
    }
    super.update(dt);
  }

  String updateText() {
    _log.info('Update Text');

//?game.waveManager.waveNumber will be the wave that was just completed

    int index = game.waveManager.waveNumber + 1;
    if (game.orbitingSatellites.isNotEmpty &&
        game.destroyedSatellites.isEmpty) {
      _log.info('Current index: $index');
      switch (index) {
        case 2:
          return notBreaking[0];
        case 3:
          return notBreaking[1];
        case 4:
          return notBreaking[2];
        case 14:
          return currentWinningCountry();
        default:
          return '';
      }
    } else {
      _log.info('Current index: $index');
      switch (index) {
        case 2:
          return storyLine[1];
        case 4:
          return storyLine[2];
        case 14:
          return currentWinningCountry();
        default:
          return '';
      }
    }
  }

  String currentWinningCountry() {
    greenCountry = 0;
    greyCountry = 0;
    cyanCountry = 0;
    whiteCountry = 0;
    pinkCountry = 0;
    brownCountry = 0;

    if (game.orbitingSatellites.isEmpty) {
      return 'Breaking News! Jupiter is now labeled as the most costly planet to attempt to observe. Countries arround the world are still pushing to win this prize!';
    }

    for (var satellite in game.orbitingSatellites) {
      switch (satellite.originCountry) {
        case SatelliteCountry.green:
          greenCountry = greenCountry + 1;

        case SatelliteCountry.grey:
          greyCountry = greyCountry + 1;

        case SatelliteCountry.white:
          whiteCountry = whiteCountry + 1;

        case SatelliteCountry.brown:
          brownCountry = brownCountry + 1;

        case SatelliteCountry.cyan:
          cyanCountry = cyanCountry + 1;

        case SatelliteCountry.pink:
          pinkCountry = pinkCountry + 1;
      }
    }
    final Map<SatelliteCountry, int> countriesCount = {
      SatelliteCountry.green: greenCountry,
      SatelliteCountry.grey: greyCountry,
      SatelliteCountry.cyan: cyanCountry,
      SatelliteCountry.white: whiteCountry,
      SatelliteCountry.pink: pinkCountry,
      SatelliteCountry.brown: brownCountry,
    };

    final largest = countriesCount.values.reduce((a, b) => a > b ? a : b);
    final bestCountry =
        countriesCount.entries.firstWhere((e) => e.value == largest);

    _log.info('The best Country is: $bestCountry');
    String countryName;
    switch (bestCountry.key) {
      case SatelliteCountry.green:
        countryName = 'Green Country';
      case SatelliteCountry.grey:
        countryName = 'Grey Country';
      case SatelliteCountry.white:
        countryName = 'White Country';
      case SatelliteCountry.brown:
        countryName = 'Brown Country';
      case SatelliteCountry.cyan:
        countryName = 'Cyan Country';
      case SatelliteCountry.pink:
        countryName = 'Pink Country';
    }
    bestCountryName = countryName;
    bestCountryCount = bestCountry.value;

    return 'The country with the most satellites in orbit is $countryName with ${bestCountry.value}';
  }

  List<String> storyLine = [
    'Breaking News! The Green Country has successfully launched the first satellite to Jupiter! Other countries are pushing to have the most satellites orbiting the planet.',
    'Breaking News! Scientist Intern makes wild claims that Jupiter is sentient after the launched satellite exploded!',
    'Breaking News! Scientists are struggling to explain the recent asteroid impacts on the satellites. Investors are taking a risk to allow more durable satellites to be built.',
  ];
  List<String> notBreaking = [
    'Breaking News! Scientists find more information about Jupiter, exciting the rest of the world to continue sending satellites!',
    'Breaking News! Scientists are baffled at the simplicity of getting a satellite to Jupiter. Investors  are throwing their money at science to make a profit, allowing for more satellites to be built!',
    'Breaking News! The science foundation in all countries has an overflow of donations allowing for durable satellites! Critics claim the amount of satellites currently orbiting Jupiter could be too much for the planet to handle.',
  ];
}
