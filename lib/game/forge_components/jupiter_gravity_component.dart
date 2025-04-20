import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flame_jam_2025/game/forge_components/asteroid_component.dart';
import 'package:flame_jam_2025/game/pesky_satellites.dart';
import 'package:flutter/material.dart';

class JupiterGravityComponent extends BodyComponent<PeskySatellites>
    with ContactCallbacks {
  JupiterGravityComponent({super.priority})
    : super(
        paint:
            Paint()
              ..color = Colors.blue
              ..strokeWidth = 0.5
              ..style = PaintingStyle.stroke,
      );

  @override
  void beginContact(Object other, Contact contact) {
    if (other is AsteroidComponent) {
      other.isOrbiting = true;
      game.asteroids.add(other);
    }
    super.beginContact(other, contact);
  }

  @override
  void update(double dt) {
    if (game.asteroids.isNotEmpty) {
      for (var asteroid in game.asteroids) {
        if (asteroid.isOrbiting!) {
          final jupiterPosition = game.jupiterPosition.clone();

          Vector2 gravityDirection =
              jupiterPosition..sub(asteroid.body.worldCenter);

          final distance = asteroid.body.worldCenter.distanceTo(
            jupiterPosition,
          );
          final clamDis = distance.clamp(0, 49);
          gravityDirection.scaleTo(clamDis * .00089);

          asteroid.body.applyLinearImpulse(
            gravityDirection,
            point: asteroid.body.worldCenter,
          );
        }
      }
    }

    super.update(dt);
  }

  @override
  Body createBody() {
    final bodyDef = BodyDef(position: Vector2.zero());
    final body = world.createBody(bodyDef)..userData = this;
    final circle = CircleShape(
      position: game.jupiterPosition,
      radius: game.jupiterSize * 4,
    );

    final fixtureDef = FixtureDef(circle, isSensor: true);
    body.createFixture(fixtureDef);
    body.synchronizeFixtures();

    return body;
  }
}
