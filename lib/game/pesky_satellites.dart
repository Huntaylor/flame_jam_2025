import 'dart:async';

import 'package:flame/camera.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flame_jam_2025/game/components/asteroid_angle_component.dart';
import 'package:flame_jam_2025/game/forge_components/asteroid_component.dart';
import 'package:flame_jam_2025/game/forge_components/jupiter_component.dart';
import 'package:flame_jam_2025/game/forge_components/jupiter_gravity_component.dart';
import 'package:flame_jam_2025/game/forge_components/jupiter_gravity_repellent_component.dart';

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

  late Timer timer;
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

  List<AsteroidComponent> asteroids = [];

  @override
  FutureOr<void> onLoad() {
    final viewfinder = Viewfinder();

    timer = Timer(.5, onTick: () => spawnAsteroid(), repeat: true);
    stopTimer = Timer(30, onTick: () => stopTimerFunc(), repeat: false);

    timer.start();

    jupiterComponent = JupiterComponent();

    jupiterGravityRepellentComponent = JupiterGravityRepellentComponent();

    asteroidComponent = AsteroidComponent();

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

  @override
  void update(double dt) {
    timer.update(dt);
    stopTimer.update(dt);
    super.update(dt);
  }

  void spawnAsteroid() {
    world.add(AsteroidComponent());
  }

  void stopTimerFunc() {
    timer.stop();
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
        isFiring: true,
        newPosition: asteroid.position,
        currentColor: asteroid.currentColor,
      );
      asteroids.removeWhere((e) => e == asteroid);
      world.remove(asteroid);
      world.add(newAsteroid);
    }
  }
}
