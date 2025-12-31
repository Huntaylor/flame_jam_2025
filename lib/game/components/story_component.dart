import 'dart:async';

import 'package:app_ui/app_ui.dart';
import 'package:flame/components.dart';
import 'package:flame_bloc/flame_bloc.dart';
import 'package:flame_jam_2025/game/blocs/wave/wave_bloc.dart';
import 'package:flame_jam_2025/game/forge_components/satellite/satellite_component.dart';
import 'package:flame_jam_2025/game/satellites_game.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

class StoryComponent extends PositionComponent
    with
        HasGameReference<SatellitesGame>,
        FlameBlocListenable<WaveBloc, WaveState> {
  StoryComponent({
    super.position,
    super.anchor,
    super.size,
    super.scale,
  });

  @override
  void onNewState(WaveState state) {
    if (!isStoryStarted && state.triggerStory) {
      startStory();
    } else if (state.triggerStory) {
      addStory();
    }
    super.onNewState(state);
  }

  static final Logger _log = Logger('Story Component');
  late TextBoxComponent storyComponent;

  bool isFinished = false;

  String storyText = '';

  late Timer readingTimer;

  String bestCountryName = '';

  bool isWarTriggered = false;
  bool isStoryStarted = false;

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
        if (bloc.state.isAtWar) isWarTriggered = true;
        bloc.add(WaveStoryEnd());
        game.waveManager.spawnTimer.start();
        removeStory();
      },
    );

    return super.onLoad();
  }

  void startStory() {
    isStoryStarted = true;
    add(
      TextBoxComponent(
        align: Anchor.center,
        boxConfig: TextBoxConfig(
          timePerChar: 0.05,
          growingBox: true,
        ),
        textRenderer: TextPaint(
          style: SatellitesTextStyle.headlineSmall.copyWith(
            fontSize: 12,
            color: Colors.blueGrey[100],
          ),
        ),
        text: storyLine[0],
        onComplete: () => readingTimer.start(),
        position: Vector2.zero(),
      ),
    );
  }

  void removeStory() {
    removeWhere((e) => e is TextBoxComponent);
  }

  Future<void> addStory() async {
    _log.info('Adding Story');
    currentWinningCountry();
    _log.info(await updateText());

    add(
      TextBoxComponent(
        priority: 5,
        align: Anchor.center,
        boxConfig: TextBoxConfig(
          timePerChar: 0.05,
          growingBox: true,
        ),
        textRenderer: TextPaint(
            style: SatellitesTextStyle.headlineSmall
                .copyWith(fontSize: 12, color: Colors.blueGrey[100])),
        text: await updateText(),
        onComplete: () => readingTimer.start(),
        position: Vector2.zero(),
      ),
    );
  }

  @override
  void update(double dt) {
    if (game.gameBloc.state.isNotGameOver) {
      if (readingTimer.isRunning()) {
        readingTimer.update(dt);
      }
    }
    super.update(dt);
  }

  Future<String> updateText() async {
    final isEarthAtWar = bloc.state.isAtWar;
    final isEarthPeaceful = !bloc.state.isAtWar;
    _log.info('Update Text');

//?game.waveManager.waveNumber will be the wave that was just completed

    int index = bloc.state.waveNumber;
    if (isEarthAtWar) {
      _log.info('Triggering war');
      if (!isWarTriggered) {
        return atWar;
      } else {
        return 'THIS IS WAR';
      }
    } else if (game.orbitingSatellites.isNotEmpty &&
        game.destroyedSatellites.isEmpty &&
        isEarthPeaceful) {
      return _notBreakingSatellitesScenario(index);
    } else if (isEarthPeaceful) {
      return _satellitesInOrbitScenario(index);
    } else {
      return (isEarthPeaceful) ? '' : 'THIS IS WAR';
    }
  }

  String _notBreakingSatellitesScenario(int index) {
    _log.info('Not Breaking Satellies current index: $index');
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
  }

  String _satellitesInOrbitScenario(int index) {
    _log.info('Satellies in Orbit current index: $index');
    switch (index) {
      case 2:
        return storyLine[1];
      case 4:
        return storyLine[2];
      case 6:
        return (game.orbitingSatellites.isEmpty)
            ? 'Breaking News! Scientists are baffled that no satellies have made it to Jupiter, but are even more encouraged to get there.'
            : (game.orbitingSatellites.length < 5)
                ? storyLine[8]
                : storyLine[7];
      case 10:
        return storyLine[3];
      case 11:
        return storyLine[4];
      case 14:
        return currentWinningCountry();
      case 15:
        return storyLine[5];
      case 20:
        return storyLine[6];
      case 21:
        return storyLine[9];
      case 24:
        return currentWinningCountry();
      case 31:
        return storyLine[10];
      case 34:
        return currentWinningCountry();
      case 36:
        return storyLine[12];
      case 44:
        return currentWinningCountry();
      case 46:
        return storyLine[13];
      case 50:
        return storyLine[11];
      case 54:
        return currentWinningCountry();
      case 56:
        return storyLine[14];
      case 64:
        return currentWinningCountry();
      case 74:
        return currentWinningCountry();
      case 84:
        return currentWinningCountry();
      case 90:
        return storyLine[11];
      case 94:
        return currentWinningCountry();
      case 99:
        return 'Breaking News! Jupiter has now reached Wave 100! Can this next wave be beaten?';
      case 100:
        return 'Breaking News! Note from developer, Congrats on getting this far! I hope you are enjoying the game. You should destroy earth by the way.';
      default:
        return '';
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

  String atWar =
      'BREAKING NEWS!! The asteroid named Catastrophe has just struck Earth! Contingency Sentient Jupiter is now active, all countries around the globe have come together to gather data needed to destroy Jupiter. A significant increase in satellites is to come. ';

  List<String> storyLine = [
    //0
    'Breaking News! The Green Country has successfully launched the first satellite to Jupiter! Other countries are pushing to have the most satellites orbiting the planet.',
    //1
    'Breaking News! Scientist Intern makes wild claims that Jupiter is sentient after the launched satellite exploded!',
    //2
    'Breaking News! Scientists are struggling to explain the recent asteroid impacts on the satellites. Investors are taking a risk to allow more durable satellites to be built.',
    //3
    'Breaking News! Local mining facility has discovered a new metal, labeled the strongest metal on Earth! Critics mock the name, NotAlotium, chosen due to the lack of quantity. This has allowed an incredibly durable satellite to be made!',
    //4
    'Breaking News! More satellites have been destroyed by the unprecedented changes in velocity of Jupiter\'s natural satellites\'. With financial reserves low, scientists have developed a cheaper, but faster satellite.',
    //5
    'Breaking News! Major investor went all in for the science foundation! This has allowed for a much more durable satellite to be produced.',
    //6
    'Breaking News! Family owned plumbing business under investigation after alleged turtle animal abuse discoveries!',
    //7
    'Breaking News! Many satellites are in Jupiter\'s orbit, science foundations around the globe continue to receive an insurmountable amount of donations to keep the foundations alive!',
    //8
    'Breaking News! Even with a few satellites in Jupiter\'s orbit, science foundations around the globe continue to receive an insurmountable amount of donations from businesses to keep the foundations alive! Critics claim the science foundation is money laundering due to the lack of results.',
    //9
    'Breaking News! Scientist Intern continues with wild claims that Jupiter is sentient and will destroy Earth. Plumbing expert of 50 years says that isn\'t a possibility',
    //10
    'Breaking News! Star gazing is rising in popularity among the rising generation.',
    //11
    'Breaking News! Congrats on getting this far! How\'s the performance?'
        //12
        'Breaking News! Toilet paper is now running out due to mass panic over the amount of satellites being destroyed!'
        //13
        'Breaking News! Critics say they want their donations to go to something more useful. Governments have yet to respond.'
        //14
        'Breaking News! The budget for the new popular movie series is said to be over the cost of all the satellites that have been destroyed as of now. Critics say it looks quote \'mid\'.'
  ];
  List<String> notBreaking = [
    'Breaking News! Scientists find more information about Jupiter, exciting the rest of the world to continue sending satellites!',
    'Breaking News! Scientists are baffled at the simplicity of getting a satellite to Jupiter. Investors are throwing their money at science to make a profit, allowing for more satellites to be built!',
    'Breaking News! The science foundations in all countries has an overflow of donations allowing for durable satellites! Critics claim the amount of satellites currently orbiting Jupiter could be too much for the planet to handle.',
  ];
}
