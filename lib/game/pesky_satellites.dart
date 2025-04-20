import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flame_jam_2025/game/forge_components/asteroid_component.dart';
import 'package:flame_jam_2025/game/forge_components/jupiter_component.dart';
import 'package:flame_jam_2025/game/forge_components/jupiter_gravity_component.dart';
import 'package:flame_jam_2025/game/forge_components/jupiter_gravity_repellent_component.dart';
// import 'package:flame/particles.dart' as parts;

class PeskySatellites extends Forge2DGame
    with HasCollisionDetection, MouseMovementDetector {
  PeskySatellites() : super(gravity: Vector2(0, 0)) {
    jupiterSize = 11;
    earthSize = (jupiterSize / 11);
    jupiterPosition = Vector2(0, 0);
    asteroidPosition = Vector2(-50, -5);
  }
  late Timer timer;
  late Timer stopTimer;
  late double jupiterSize;
  late double earthSize;

  late Vector2 jupiterPosition;
  late Vector2 asteroidPosition;

  late AsteroidComponent asteroidComponent;
  late JupiterComponent jupiterComponent;
  late JupiterGravityComponent jupiterGravityComponent;
  late JupiterGravityRepellentComponent jupiterGravityRepellentComponent;

  @override
  FutureOr<void> onLoad() {
    timer = Timer(.5, onTick: () => spawnAsteroid(), repeat: true);
    stopTimer = Timer(30, onTick: () => stopTimerFunc(), repeat: false);
    timer.start();
    jupiterComponent = JupiterComponent();
    jupiterGravityRepellentComponent = JupiterGravityRepellentComponent();
    asteroidComponent = AsteroidComponent();
    final jupiterGravityComponent = JupiterGravityComponent();
    final earth = CircleComponent(
      position: Vector2(-50, -25),
      radius: earthSize,
      anchor: Anchor.center,
    );

    world.addAll([
      jupiterComponent,
      jupiterGravityComponent,
      earth,
      asteroidComponent,
      jupiterGravityRepellentComponent,
    ]);

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
}
