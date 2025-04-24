import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flame/camera.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/particles.dart' as parts;
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flame_jam_2025/game/components/asteroid_angle_component.dart';
import 'package:flame_jam_2025/game/forge_components/asteroid_component.dart';
import 'package:flame_jam_2025/game/forge_components/jupiter_component.dart';
import 'package:flame_jam_2025/game/forge_components/jupiter_gravity_component.dart';
import 'package:flame_jam_2025/game/forge_components/jupiter_gravity_repellent_component.dart';
import 'package:flame_jam_2025/game/forge_components/satellite_component.dart';
import 'package:flame_jam_2025/game/managers/wave_manager.dart';
import 'package:flutter/material.dart';

class PeskySatellites extends Forge2DGame
    with
        HasCollisionDetection,
        TapCallbacks,
        MouseMovementDetector,
        DragCallbacks {
  PeskySatellites() : super(gravity: Vector2(0, 0)) {
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

  late JupiterComponent jupiterComponent;
  late JupiterGravityComponent jupiterGravityComponent;
  late JupiterGravityRepellentComponent jupiterGravityRepellentComponent;

  late AsteroidAngleComponent asteroidAngleComponent;

  late SatelliteComponent satelliteComponent;

  List<AsteroidComponent> asteroids = [];
  List<SatelliteComponent> satellites = [];

  int waveNumber = 100;

  late WaveManager waveManager;

  final rnd = Random();

  final paint = Paint();

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
  ];

  @override
  FutureOr<void> onLoad() {
    final viewfinder = Viewfinder();

    // sateTimer = Timer(1, onTick: () => launchSatellite(), repeat: true);
    // asteroidTimer = Timer(.5, onTick: () => spawnAsteroid(), repeat: true);
    // stopTimer = Timer(30, onTick: () => stopTimerFunc(), repeat: false);

    // sateTimer.start();
    // asteroidTimer.start();

    jupiterComponent = JupiterComponent();
    jupiterGravityRepellentComponent = JupiterGravityRepellentComponent();

    // satelliteComponent = SatelliteComponent(totalHealth: 500);

    final jupiterGravityComponent = JupiterGravityComponent();

    final earth = CircleComponent(
      position: earthPosition,
      radius: earthSize,
      anchor: Anchor.center,
    );

    viewfinder
      ..anchor = Anchor.topLeft
      ..zoom = 10;

    camera = CameraComponent.withFixedResolution(
      width: 1920.0,
      height: 1027.0,
      world: world,
      viewfinder: viewfinder,
    );

    spawnAsteroids();

    setUpWaves();

    world.addAll([
      jupiterComponent,
      jupiterGravityComponent,
      earth,
      jupiterGravityRepellentComponent,
    ]);

    return super.onLoad();
  }

  void setUpWaves() {
    waveManager = WaveManager(
      waveNumber: waveNumber,
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
    world.add(waveManager);
  }

  // void launchSatellite() {
  //   final sate = SatelliteComponent(totalHealth: 100);
  //   world.add(sate);
  // }

  // @override
  // void update(double dt) {
  //   // asteroidTimer.update(dt);
  //   stopTimer.update(dt);
  //   sateTimer.update(dt);
  //   super.update(dt);
  // }

  void spawnAsteroids() {
    for (var vec in startingPoints) {
      final asteroid = AsteroidComponent(
          startPosition: vec, startingDamage: smallDamage, priority: 3);
      asteroids.add(asteroid);
      world.add(asteroid);
    }
  }

  // void stopTimerFunc() {
  //   // asteroidTimer.stop();
  //   sateTimer.stop();
  // }

  @override
  void onMouseMove(PointerHoverInfo info) {
    lineSegment = info.eventPosition.global;
    super.onMouseMove(info);
  }

  @override
  void render(Canvas canvas) {
    if (asteroids.isNotEmpty && lineSegment != null) {
      drawDashedLine(
          canvas: canvas,
          p1: camera.localToGlobal(asteroids.first.body.worldCenter).toOffset(),
          p2: lineSegment!.toOffset(),
          paint: paint..color = Colors.amber,
          pattern: [20, 30]);
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
    if (asteroids.isNotEmpty) {
      targetPosition.setFrom(
        camera.globalToLocal(event.devicePosition),
      );
      final asteroid = asteroids.first;
      final newAsteroid = AsteroidComponent(
        startPosition: Vector2.zero(),
        startingDamage: asteroid.startingDamage,
        isFiring: true,
        newPosition: asteroid.position,
        currentColor: asteroid.currentColor,
      );
      asteroids.removeWhere((e) => e == asteroid);
      world.remove(asteroid);
      world.add(newAsteroid);
    }
  }

  void explodeSatellite(List<List<Vector2>> polyShapes, Vector2 position,
      SatelliteComponent _component) async {
    List<ParticleSystemComponent> particles = [];
    for (var shape in polyShapes) {
      List<Vector2> scaleList = [];
      for (var vector in shape) {
        scaleList.add(vector * 15);
      }
      final explosionParticle = ParticleSystemComponent(
        position: camera.localToGlobal(position),
        anchor: Anchor.center,
        particle: parts.AcceleratedParticle(
          lifespan: 1.5,
          speed: randomVector2(),
          child: parts.RotatingParticle(
            to: pi,
            child: parts.ScalingParticle(
              to: 0,
              child: parts.ComponentParticle(
                component: PolygonComponent(scaleList)..setColor(Colors.red),
              ),
            ),
          ),
        ),
      );
      particles.add(explosionParticle);
    }
    addAll(particles);
    world.remove(_component);
  }

  void explodeAsteroid(Vector2 position, AsteroidComponent _component) async {
    final explosionParticle = ParticleSystemComponent(
      position: camera.localToGlobal(position),
      anchor: Anchor.center,
      particle: parts.Particle.generate(
        count: rnd.nextInt(10) + 5,
        generator: (i) => parts.AcceleratedParticle(
          lifespan: 1.5,
          speed: randomVector2(),
          child: parts.ScalingParticle(
            to: 0,
            child: parts.ComputedParticle(
              renderer: (canvas, particle) {
                canvas.drawCircle(
                  Offset.zero,
                  5,
                  Paint()
                    ..color = Color.lerp(
                      _component.currentColor,
                      const Color.fromARGB(255, 255, 0, 0),
                      particle.progress,
                    )!,
                );
              },
            ),
          ),
        ),
      ),
    );
    add(explosionParticle);
    world.remove(_component);
  }
}
