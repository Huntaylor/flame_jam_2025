import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flame/camera.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flame_jam_2025/game/components/asteroid_angle_component.dart';
import 'package:flame_jam_2025/game/forge_components/asteroids/asteroid_component.dart';
import 'package:flame_jam_2025/game/forge_components/earth/earth_component.dart';
import 'package:flame_jam_2025/game/forge_components/earth/earth_gravity_component.dart';
import 'package:flame_jam_2025/game/forge_components/jupiter/jupiter_component.dart';
import 'package:flame_jam_2025/game/forge_components/jupiter/jupiter_gravity_component.dart';
import 'package:flame_jam_2025/game/forge_components/jupiter/jupiter_gravity_repellent_component.dart';
import 'package:flame_jam_2025/game/forge_components/satellite/satellite_component.dart';
import 'package:flame_jam_2025/game/managers/asteroid_spawn_manager.dart';
import 'package:flame_jam_2025/game/managers/wave_manager.dart';
import 'package:flutter/material.dart';

enum GameState { waveStart, waveEnd }

class SatefliesGame extends Forge2DGame
    with HasCollisionDetection, TapCallbacks, MouseMovementDetector {
  SatefliesGame() : super(gravity: Vector2(0, 0)) {
    jupiterSize = 9;
    earthSize = (jupiterSize / 11);
    earthPosition = Vector2.all(15);
    jupiterPosition = Vector2(150.0, 75.0);
    asteroidPosition = Vector2(jupiterPosition.x - 50, jupiterPosition.y + 50);
    firingPosition = Vector2(114, 59);
    asteroidAngle = Vector2(5, -20);
  }

  final double smallDamage = 25;
  final double mediumDamage = 50;
  final double heavyDamage = 75;
  final double xHeavyDamage = 100;
  final double cometDamage = 200;

  // late Timer asteroidTimer;
  // late Timer sateTimer;
  // late Timer stopTimer;

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

  late AsteroidAngleComponent asteroidAngleComponent;

  late SatelliteComponent satelliteComponent;

  List<AsteroidComponent> asteroids = [];
  List<SatelliteComponent> orbitingSatellites = [];
  List<SatelliteComponent> waveSatellites = [];

  late WaveManager waveManager;
  late AsteroidSpawnManager asteroidSpawnManager;

  late TextComponent waveTextComponent;

  final rnd = Random();

  final paint = Paint();

  bool isGameStarted = false;
  // bool isWaveOver = false;

  String waveText = '';

  Vector2? lineSegment;

  Vector2 randomVector2() => (-Vector2.random(rnd) - Vector2.random(rnd)) * 100;

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
    Vector2(128.0, 58.0),
    Vector2(128.0, 58.0),
  ];

  @override
  FutureOr<void> onLoad() {
    setUpWaves();

    waveText = 'Wave ${waveManager.waveNumber}';

    isGameStarted = true;
    final viewfinder = Viewfinder();

    jupiterComponent = JupiterComponent();

    jupiterGravityRepellentComponent = JupiterGravityRepellentComponent();

    jupiterGravityComponent = JupiterGravityComponent();

    earthComponent = EarthComponent();

    earthGravityComponent = EarthGravityComponent();

    waveTextComponent = TextComponent(
      text: waveText,
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
        FpsTextComponent(),
        waveTextComponent..position = Vector2(1920 / 2, 0),
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

  // @override
  // void update(double dt) {

  //   super.update(dt);
  // }

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
  void render(Canvas canvas) {
    if (asteroids.isNotEmpty &&
        lineSegment != null &&
        asteroids.any((e) => e.isOrbiting)) {
      final firstAsteroids = asteroids.firstWhere((e) => e.isOrbiting);

      drawDashedLine(
        canvas: canvas,
        p1: camera.localToGlobal(firstAsteroids.body.worldCenter).toOffset(),
        p2: lineSegment!.toOffset(),
        paint: paint..color = Colors.amber,
        pattern: [20, 30],
      );
    }
    super.render(canvas);
  }

  Canvas drawDashedLine({
    required Canvas canvas,
    required Offset p1,
    required Offset p2,
    required Iterable<double> pattern,
    required Paint paint,
  }) {
    assert(pattern.length.isEven);
    final distance = (p2 - p1).distance;
    final normalizedPattern = pattern.map((width) => width / distance).toList();
    final points = <Offset>[];
    double t = 0;
    int i = 0;
    while (t < 1) {
      points.add(Offset.lerp(p1, p2, t)!);
      t += normalizedPattern[i++]; // dashWidth
      points.add(Offset.lerp(p1, p2, t.clamp(0, 1))!);
      t += normalizedPattern[i++]; // dashSpace
      i %= normalizedPattern.length;
    }

    canvas.drawPoints(PointMode.lines, points, paint);
    return canvas;
  }

  @override
  Future<void> onTapDown(TapDownEvent event) async {
    super.onTapDown(event);
    if (asteroids.isNotEmpty && asteroids.any((e) => e.isOrbiting)) {
      targetPosition.setFrom(
        camera.globalToLocal(event.devicePosition),
      );
      final asteroid = asteroids.firstWhere((e) => e.isOrbiting);
      final newAsteroid = AsteroidComponent(
        startPosition: Vector2.zero(),
        startingDamage: asteroid.startingDamage,
        newPosition: asteroid.position,
        currentColor: asteroid.currentColor,
      );
      newAsteroid.state = AsteroidState.firing;
      asteroids.removeWhere((e) => e == asteroid);
      world.remove(asteroid);
      world.add(newAsteroid);
    }
  }
}
