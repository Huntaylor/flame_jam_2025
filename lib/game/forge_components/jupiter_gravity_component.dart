import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flame_jam_2025/game/forge_components/asteroid_component.dart';
import 'package:flame_jam_2025/game/forge_components/satallite_component.dart';
import 'package:flame_jam_2025/game/pesky_satellites.dart';
import 'package:flutter/material.dart';

class JupiterGravityComponent extends BodyComponent<PeskySatellites>
    with ContactCallbacks {
  JupiterGravityComponent({super.priority})
      : super(
          paint: Paint()
            ..color = Colors.blue
            ..strokeWidth = 0.5
            ..style = PaintingStyle.stroke,
        );

  @override
  void beginContact(Object other, Contact contact) {
    if (other is SatalliteComponent) {
      other.isTooLate = true;
      game.satallites.add(other);
    } else if (other is AsteroidComponent && !(other.isFiring ?? false)) {
      other.isOrbiting = true;
      game.asteroids.add(other);
    }
    super.beginContact(other, contact);
  }

  @override
  void update(double dt) {
    if (game.satallites.isNotEmpty) {
      for (var satallite in game.satallites) {
        if (satallite.isTooLate) {
          final jupiterPosition = game.jupiterPosition.clone();

          Vector2 gravityDirection = jupiterPosition
            ..sub(satallite.body.worldCenter);

          final distance = satallite.body.worldCenter.distanceTo(
            jupiterPosition,
          );
          final double jupiterGravity = 24.79;
          final double jupiterMass = 254.0;
          final gravity = (jupiterGravity *
              (satallite.body.getMassData().mass *
                  jupiterMass %
                  pow(distance, 2)));
          gravityDirection.scaleTo(gravity * dt);
          final normalizedData =
              satallite.body.linearVelocity.clone().normalize();
          if (50 < normalizedData) {
            //Max 50, starts to get too fast after that
            satallite.body.applyForce(
              satallite.body.linearVelocity.inverted(),
            );
          } else {
            satallite.body.applyForce(
              gravityDirection / 8,
              point: satallite.body.worldCenter,
            );
          }
        }
      }
    }

    if (game.asteroids.isNotEmpty) {
      for (var asteroid in game.asteroids) {
        if (asteroid.isOrbiting!) {
          final jupiterPosition = game.jupiterPosition.clone();

          Vector2 gravityDirection = jupiterPosition
            ..sub(asteroid.body.worldCenter);

          final distance = asteroid.body.worldCenter.distanceTo(
            jupiterPosition,
          );
          final double jupiterGravity = 24.79;
          final double jupiterMass = 254.0;
          final gravity = (jupiterGravity *
              (asteroid.body.getMassData().mass *
                  jupiterMass %
                  pow(distance, 2)));
          gravityDirection.scaleTo(gravity * dt);
          final normalizedData =
              asteroid.body.linearVelocity.clone().normalize();
          if (50 < normalizedData) {
            //Max 50, starts to get too fast after that
            // largestNumber = normalizedData;
            asteroid.body.applyForce(
              asteroid.body.linearVelocity.inverted(),
            );
          } else {
            asteroid.body.applyForce(
              gravityDirection / 8,
              point: asteroid.body.worldCenter,
            );
          }
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
