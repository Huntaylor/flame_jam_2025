import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flame_jam_2025/game/forge_components/asteroid_component.dart';
import 'package:flame_jam_2025/game/pesky_satellites.dart';
import 'package:flutter/material.dart';

class JupiterGravityComponent extends BodyComponent<PeskySatellites>
    with ContactCallbacks, TapCallbacks {
  JupiterGravityComponent({super.priority})
    : super(
        paint:
            Paint()
              ..color = Colors.blue
              // ..blendMode = BlendMode.exclusion
              ..strokeWidth = 0.5
              ..style = PaintingStyle.stroke,
      );

  List<AsteroidComponent> asteroids = [];

  @override
  void beginContact(Object other, Contact contact) {
    if (other is AsteroidComponent) {
      other.isOrbiting = true;
      // final newBody = contact.getOtherBody(body);
      asteroids.add(other);
    }
    super.beginContact(other, contact);
  }

  // @override
  // void endContact(Object other, Contact contact) {
  //   if (other is AsteroidComponent) {
  //     if (asteroids.isNotEmpty) {
  //       other.isOrbiting = false;
  //       final asteroidBody = asteroids.firstWhere(
  //         (i) => i.body == contact.getOtherBody(body),
  //       );

  //       asteroids.remove(asteroidBody);
  //     }
  //     super.endContact(other, contact);
  //   }
  // }

  @override
  void update(double dt) {
    if (asteroids.isNotEmpty) {
      for (var asteroid in asteroids) {
        // final jupiterPosition = game.jupiterComponent.body.worldCenter.clone();
        // // Calculate gravity direction from center to body
        // Vector2 gravityDirection =
        //     (jupiterPosition)
        //       ..sub(asteroidBody.position)
        //       ..normalize();

        // // Calculate gravity force based on mass and direction
        // Vector2 bodyGravity = gravityDirection..scale(asteroidBody.mass * 10);

        // // Apply the force at the body's position
        // asteroidBody.applyForce(bodyGravity);

        if (asteroid.isOrbiting!) {
          final jupiterPosition =
              game.jupiterComponent.body.worldCenter.clone();

          Vector2 gravityDirection =
              jupiterPosition..sub(asteroid.body.worldCenter);

          // if (distance < 0.5) continue;

          // gravityDirection.normalize();

          // double gravityStrength = 5.0 / (distance * distance);

          // Limit maximum gravity to prevent excessive force
          // gravityStrength = min(gravityStrength, 30);

          // Scale direction by strength
          // gravityDirection.clampScalar(15, 30);
          // gravityDirection.scaleTo(75);

          // final distance = asteroid.body.worldCenter.distanceTo(
          //   jupiterPosition,
          // );
          // // final clamDis = distance.clamp(0, 80);
          // gravityDirection.scaleTo(distance / 3.5);

          // asteroid.body.applyForce(
          //   gravityDirection,
          //   point: asteroid.body.worldCenter,
          // );
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
