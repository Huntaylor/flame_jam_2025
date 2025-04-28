import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:app_ui/app_ui.dart';
import 'package:flame/camera.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/parallax.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flame_jam_2025/game/components/mouse_render_component.dart';
import 'package:flame_jam_2025/game/components/satellite_hud_button.dart';
import 'package:flame_jam_2025/game/components/story_component.dart';
import 'package:flame_jam_2025/game/forge_components/asteroids/asteroid_component.dart';
import 'package:flame_jam_2025/game/forge_components/earth/earth_component.dart';
import 'package:flame_jam_2025/game/forge_components/earth/earth_gravity_component.dart';
import 'package:flame_jam_2025/game/forge_components/jupiter/jupiter_component.dart';
import 'package:flame_jam_2025/game/forge_components/jupiter/jupiter_gravity_component.dart';
import 'package:flame_jam_2025/game/forge_components/jupiter/jupiter_gravity_repellent_component.dart';
import 'package:flame_jam_2025/game/forge_components/jupiter/jupiter_health_bar_component.dart';
import 'package:flame_jam_2025/game/forge_components/satellite/satellite_component.dart';
import 'package:flame_jam_2025/game/managers/asteroid_spawn_manager.dart';
import 'package:flame_jam_2025/game/managers/wave_manager.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

enum GameState { mainMenu, start, end, victory }

class SatellitesGame extends Forge2DGame
    with TapCallbacks, MouseMovementDetector {
  SatellitesGame({required this.isPlaying}) : super(gravity: Vector2(0, 0)) {
    jupiterSize = 9;
    earthSize = (jupiterSize / 11);
    earthPosition = Vector2.all(15);
    jupiterPosition = Vector2(150.0, 75.0);
    asteroidPosition = Vector2(jupiterPosition.x - 50, jupiterPosition.y + 50);
    firingPosition = Vector2(114, 59);
    asteroidAngle = Vector2(5, -20);
  }
  static final Logger _log = Logger('Satellite Game');
  bool playSounds = true;
  final double smallDamage = 25;
  final double mediumDamage = 50;
  final double heavyDamage = 75;
  final double xHeavyDamage = 250;
  final double cometDamage = 200;

  late double jupiterSize;
  late double earthSize;

  late Vector2 jupiterPosition;
  late Vector2 earthPosition;
  late Vector2 asteroidPosition;
  late Vector2 firingPosition;
  late Vector2 asteroidAngle;

  Vector2 targetPosition = Vector2.zero();

  late EarthComponent earthComponent;
  late EarthGravityComponent earthGravityComponent;

  late JupiterComponent jupiterComponent;
  late JupiterGravityComponent jupiterGravityComponent;
  late JupiterGravityRepellentComponent jupiterGravityRepellentComponent;
  late JupiterHealthBarComponent jupiterSanityBarComponent;

  late SatelliteComponent satelliteComponent;

  List<AsteroidComponent> asteroids = [];
  List<SatelliteComponent> orbitingSatellites = [];
  List<SatelliteComponent> waveSatellites = [];
  List<SatelliteComponent> destroyedSatellites = [];

  double orbitingPower = 0;
  int currentLength = 0;
  double totalHealth = 40;

  late WaveManager waveManager;
  late AsteroidSpawnManager asteroidSpawnManager;

  late TextComponent muteTextComponent;

  late TextComponent waveTextComponent;
  late TextComponent satellitesLeftTextComponent;
  late TextComponent immersiveModeComponent;

  late StoryComponent storyComponent;

  late SatelliteHudButton inGameMuteButton;

  late SatelliteHudButton playButton;
  late SatelliteHudButton muteButton;

  final rnd = Random();

  bool isGameStarted = false;
  bool hidHud = false;
  bool isPlaying = true;

  String waveText = '';
  String satellitesLeftText = '';

  Vector2? lineSegment;

  late MouseRenderComponent mouseRenderComponent;

  GameState gameState = GameState.mainMenu;

  Vector2 randomVector2() => (-Vector2.random(rnd) - Vector2.random(rnd)) * 100;
  late ui.Image? spriteImage;

  final _imageNames = [
    ParallaxImageData('parallax/nebulawetstars.png'),
    ParallaxImageData('parallax/nebuladrystars.png'),
    ParallaxImageData('parallax/nebula2.png'),
  ];

  List<Vector2> startingPoints = [
    Vector2(136.0, 55.0),
    Vector2(170.0, 55.0),
    Vector2(175.0, 67.0),
    Vector2(174.0, 81.0),
    Vector2(170.0, 93.0),
    Vector2(158.0, 98.0),
    Vector2(140.0, 97.0),
    Vector2(129.0, 89.0),
    Vector2(124.0, 75.0),
    Vector2(128.0, 58.0),
  ];

  @override
  FutureOr<void> onLoad() async {
    storyComponent = StoryComponent(
      position: Vector2(50, 200),
    );
    await setUpAudio();

    final parallax = await loadParallaxComponent(
      _imageNames,
      baseVelocity: Vector2(20, 0),
      velocityMultiplierDelta: Vector2(1.8, 1.0),
      filterQuality: FilterQuality.none,
    );

    add(parallax);

    await images.loadAllImages();

    spriteImage = await images.load('asteroid.png');

    playButton = SatelliteHudButton(
      position: Vector2(50, 450),
      button: TextComponent(
        text: '-Launch satellite-',
        textRenderer: TextPaint(
            style: SatellitesTextStyle.titleLarge
                .copyWith(color: Colors.blueGrey)),
      ),
      onPressed: () {
        return gameState = GameState.start;
      },
    );

    muteButton = SatelliteHudButton(
      position: Vector2(50, 500),
      button: TextComponent(
        text: '-Mute-',
        textRenderer: TextPaint(
            style: SatellitesTextStyle.headlineSmall
                .copyWith(color: Colors.red[400])),
      ),
      onPressed: () {
        isPlaying = !isPlaying;
        _log.info('IsPlaying: $isPlaying');
        updateSound();
      },
    );

    muteTextComponent = TextComponent(
      text: '',
      textRenderer: TextPaint(
          style: SatellitesTextStyle.headlineSmall
              .copyWith(fontSize: 18, color: Colors.red[400])),
    );

    inGameMuteButton = SatelliteHudButton(
      size: Vector2(115, 25),
      position: Vector2(1920 - 115, 50),
      button: muteTextComponent,
      onPressed: () {
        if (isGameStarted) {
          isPlaying = !isPlaying;
          _log.info('IsPlaying: $isPlaying');
          updateSound();
        }
      },
    );

    mouseRenderComponent = MouseRenderComponent();

    addAll([
      playButton,
      muteButton,
    ]);
    add(mouseRenderComponent);

    final viewfinder = Viewfinder();

    jupiterComponent = JupiterComponent();

    jupiterGravityRepellentComponent = JupiterGravityRepellentComponent();

    jupiterGravityComponent = JupiterGravityComponent();
    jupiterSanityBarComponent = JupiterHealthBarComponent(
      anchor: Anchor.center,
    );

    earthComponent = EarthComponent();
    setUpWaves();

    earthGravityComponent = EarthGravityComponent();

    waveTextComponent = TextComponent(
      anchor: Anchor.center,
      text: waveText,
      textRenderer: TextPaint(
          style: SatellitesTextStyle.displayMedium
              .copyWith(color: Colors.blueGrey[100])),
    );
    satellitesLeftTextComponent = TextComponent(
      anchor: Anchor.center,
      text: satellitesLeftText,
      textRenderer: TextPaint(
          style: SatellitesTextStyle.displayMedium
              .copyWith(color: Colors.blueGrey[100])),
    );

    viewfinder
      ..anchor = Anchor.topLeft
      ..zoom = 10;
    camera = CameraComponent.withFixedResolution(
      width: 1920.0,
      height: 1027.0,
      world: world,
      viewfinder: viewfinder,
      hudComponents: [
        FpsTextComponent(
          position: Vector2.all(10),
          textRenderer: TextPaint(
              style: SatellitesTextStyle.titleMedium
                  .copyWith(color: Colors.blueGrey[100])),
        ),
        waveTextComponent
          ..position = Vector2(1920 / 2, waveTextComponent.height),
        satellitesLeftTextComponent
          ..position = Vector2(
            1920 / 2,
            waveTextComponent.height + waveTextComponent.height + 8,
          ),
        jupiterSanityBarComponent..position = Vector2(800, 25),
        storyComponent,
        inGameMuteButton,
      ],
    );
    spawnAsteroids();

    world.addAll([
      jupiterComponent,
      jupiterGravityComponent,
      earthComponent,
      jupiterGravityRepellentComponent,
      earthGravityComponent,
    ]);

    return super.onLoad();
  }

  updateSound() {
    if (!isPlaying) {
      FlameAudio.bgm.pause();
    } else {
      FlameAudio.bgm.resume();
    }
  }

  setUpAudio() async {
    await FlameAudio.bgm.initialize();
    await FlameAudio.bgm.play('ville_seppanen-1_g.mp3', volume: 0.5);
    isPlaying = FlameAudio.bgm.isPlaying;
  }

  @override
  void update(double dt) {
    if (gameState != GameState.end) {
      if (gameState != GameState.mainMenu && !isGameStarted) {
        if (muteTextComponent.text.isEmpty) {
          muteTextComponent.text = '-Mute-';
        }

        if (waveText.isEmpty) {
          waveText = 'Wave ${waveManager.waveNumber}';
        }
        removeAll([playButton, muteButton]);

        isGameStarted = true;
        storyComponent.startStory();
      }
      if (orbitingSatellites.length > currentLength) {
        // for (var satellite in orbitingSatellites) {
        switch (orbitingSatellites.last.difficulty) {
          case SatelliteDifficulty.easy:
            orbitingPower = orbitingPower + 2;
          case SatelliteDifficulty.medium:
            orbitingPower = orbitingPower + 3;
          case SatelliteDifficulty.hard:
            orbitingPower = orbitingPower + 4;
          case SatelliteDifficulty.boss:
            orbitingPower = orbitingPower + 10;
          case SatelliteDifficulty.fast:
            orbitingPower = orbitingPower + 1;
          // }
        }
        if (orbitingPower >= totalHealth && gameState != GameState.end) {
          gameState = GameState.end;
          overlays.add('Game Over');
          if (mouseRenderComponent.parent != null &&
              mouseRenderComponent.parent!.isMounted) {
            remove(mouseRenderComponent);
          }
        }
        if (earthComponent.isDestroyed) {
          gameState = GameState.end;
          overlays.add('Victory');
          if (mouseRenderComponent.parent != null &&
              mouseRenderComponent.parent!.isMounted) {
            remove(mouseRenderComponent);
          }
        }
        currentLength = orbitingSatellites.length;
      }
    }

    super.update(dt);
  }

  void setUpWaves() {
    asteroidSpawnManager = AsteroidSpawnManager();

    waveManager = WaveManager(
      impulseTargets: [
        Vector2(158.0, 40.0),
        Vector2(155.0, 45.0),
        Vector2(156.0, 50.0),
        Vector2(155.0, 55.0),
        Vector2(154.0, 60.0),
        Vector2(145.0, 90.0),
        Vector2(145.0, 95.0),
        Vector2(140.0, 99.0),
        Vector2(140.0, 100.0),
        Vector2(130.0, 100.0),
      ],
    );
    world.addAll([waveManager, asteroidSpawnManager]);
  }

  void spawnAsteroids() {
    for (var vec in startingPoints) {
      final asteroid = AsteroidComponent(
        spriteImage: spriteImage,
        startPosition: vec,
        startingDamage: smallDamage,
        priority: 3,
      );
      asteroids.add(asteroid);
      world.add(asteroid);
    }
  }

  @override
  void onMouseMove(PointerHoverInfo info) {
    lineSegment = info.eventPosition.global;
    super.onMouseMove(info);
  }

  @override
  Future<void> onTapDown(TapDownEvent event) async {
    if (gameState != GameState.mainMenu) {
      super.onTapDown(event);
      if (asteroids.isNotEmpty && asteroids.any((e) => e.isOrbiting)) {
        targetPosition.setFrom(
          camera.globalToLocal(event.devicePosition),
        );
        final asteroid = asteroids.firstWhere((e) => e.isOrbiting);
        try {
          final newAsteroid = AsteroidComponent(
            speedScaling: asteroid.speedScaling,
            startPosition: Vector2.zero(),
            startingDamage: asteroid.startingDamage,
            newPosition: asteroid.position,
            // currentColor: asteroid.currentColor,
            sizeScaling: asteroid.sizeScaling,
          );
          newAsteroid.state = AsteroidState.firing;
          asteroids.removeWhere((e) => e == asteroid);
          if (asteroid.parent != null && asteroid.parent!.isMounted) {
            world.remove(asteroid);
          }
          world.add(newAsteroid);
        } catch (e) {
          _log.severe(
              'Satellite game -- onTapDown Asteroid Creation Exception', e);
        }
      }
    }
  }
}
