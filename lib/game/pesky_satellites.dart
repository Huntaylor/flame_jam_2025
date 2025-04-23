import 'dart:async';
import 'dart:math';

import 'package:flame/camera.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/particles.dart' as parts;
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flame_jam_2025/game/components/asteroid_angle_component.dart';
import 'package:flame_jam_2025/game/components/sata_healthbar_component.dart';
import 'package:flame_jam_2025/game/forge_components/asteroid_component.dart';
import 'package:flame_jam_2025/game/forge_components/jupiter_component.dart';
import 'package:flame_jam_2025/game/forge_components/jupiter_gravity_component.dart';
import 'package:flame_jam_2025/game/forge_components/jupiter_gravity_repellent_component.dart';
import 'package:flame_jam_2025/game/forge_components/satallite_component.dart';
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
    jupiterPosition = Vector2(earthPosition.x * 10, earthPosition.y * 5);
    asteroidPosition = Vector2(jupiterPosition.x - 50, jupiterPosition.y + 50);
    firingPosition = Vector2(114, 59);
    asteroidAngle = Vector2(5, -20);
  }

  late Timer asteroidTimer;
  late Timer sataTimer;
  late Timer stopTimer;
  late double jupiterSize;
  late double earthSize;

  late Vector2 jupiterPosition;
  late Vector2 earthPosition;
  late Vector2 asteroidPosition;
  late Vector2 firingPosition;
  late Vector2 asteroidAngle;
  Vector2 targetPosition = Vector2.zero();

  late AsteroidComponent asteroidComponent;
  late JupiterComponent jupiterComponent;
  late JupiterGravityComponent jupiterGravityComponent;
  late JupiterGravityRepellentComponent jupiterGravityRepellentComponent;

  late AsteroidAngleComponent asteroidAngleComponent;

  late SatalliteComponent satalliteComponent;

  List<AsteroidComponent> asteroids = [];
  List<SatalliteComponent> satallites = [];

  final rnd = Random();

  Vector2 randomVector2() => (-Vector2.random(rnd) - Vector2.random(rnd)) * 100;

  @override
  FutureOr<void> onLoad() {
    final viewfinder = Viewfinder();

    sataTimer = Timer(1, onTick: () => launchSatallite(), repeat: true);
    asteroidTimer = Timer(.5, onTick: () => spawnAsteroid(), repeat: true);
    stopTimer = Timer(30, onTick: () => stopTimerFunc(), repeat: false);

    sataTimer.start();
    asteroidTimer.start();

    jupiterComponent = JupiterComponent();
    jupiterGravityRepellentComponent = JupiterGravityRepellentComponent();

    asteroidComponent = AsteroidComponent(damage: 101);
    satalliteComponent = SatalliteComponent(totalHealth: 500);

    final jupiterGravityComponent = JupiterGravityComponent();

    final earth = CircleComponent(
      position: earthPosition,
      radius: earthSize,
      anchor: Anchor.center,
    );

    viewfinder
      ..anchor = Anchor.topLeft
      ..zoom = 10;

    camera = CameraComponent(world: world, viewfinder: viewfinder);

    world.addAll([
      jupiterComponent,
      jupiterGravityComponent,
      earth,
      asteroidComponent,
      jupiterGravityRepellentComponent,
      // satalliteComponent
    ]);
    // final initialVec = Vector2(184, 75);
    // for (var i = 0; i < 30; i++) {
    //   print('adding');
    //   final ast = AsteroidComponent(
    //       newPosition: Vector2(initialVec.x - i, initialVec.y - i));
    //   world.add(ast);
    // }

    return super.onLoad();
  }

  void launchSatallite() {
    final sata = SatalliteComponent(totalHealth: 100);
    world.add(sata);
  }

  @override
  void update(double dt) {
    asteroidTimer.update(dt);
    stopTimer.update(dt);
    sataTimer.update(dt);
    super.update(dt);
  }

  void spawnAsteroid() {
    world.add(AsteroidComponent(damage: 101));
  }

  void stopTimerFunc() {
    asteroidTimer.stop();
    sataTimer.stop();
  }

  // @override
  // Future<void> onTapDown(TapDownEvent event) async {
  //   super.onTapDown(event);
  //   targetPosition.setFrom(camera.globalToLocal(event.devicePosition));

  //   if (asteroids.isNotEmpty) {
  //     final asteroid = asteroids.first;
  //     asteroids.removeWhere((e) => e == asteroid);
  //     asteroid.body.clearForces();
  //     asteroid.fireAsteroid();
  //     // final newAsteroid = AsteroidComponent(
  //     //     isFiring: true,
  //     //     currentPosition: asteroid.position,
  //     //     currentColor: asteroid.currentColor);
  //     // world.remove(asteroid);
  //     // world.add(newAsteroid);

  //     // asteroid.body.applyForce(Vector2(-250, 250));
  //   }
  // }

  @override
  Future<void> onTapDown(TapDownEvent event) async {
    super.onTapDown(event);
    if (asteroids.isNotEmpty) {
      targetPosition.setFrom(camera.globalToLocal(event.devicePosition));
      final asteroid = asteroids.first;
      final newAsteroid = AsteroidComponent(
        damage: asteroid.damage,
        isFiring: true,
        newPosition: asteroid.position,
        currentColor: asteroid.currentColor,
      );
      asteroids.removeWhere((e) => e == asteroid);
      world.remove(asteroid);
      world.add(newAsteroid);
    }
  }

  void explodeSatallite(List<List<Vector2>> polyShapes, Vector2 position,
      SatalliteComponent _component) async {
    List<ParticleSystemComponent> particles = [];
    for (var shape in polyShapes) {
      List<Vector2> scaleList = [];
      for (var vector in shape) {
        scaleList.add(vector * 25);
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
