import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flame_jam_2025/game/forge_components/asteroid_component.dart';
import 'package:flame_jam_2025/game/forge_components/satellite_component.dart';
import 'package:flame_jam_2025/game/sateflies_game.dart';
import 'package:flutter/material.dart';

class JupiterGravityComponent extends BodyComponent<SatefliesGame>
    with ContactCallbacks {
  JupiterGravityComponent({super.priority})
      : super(
          paint: Paint()
            ..color = Colors.blue
            ..strokeWidth = 0.5
            ..style = PaintingStyle.stroke,
        );

  final double jupiterGravity = 24.79;
  final double jupiterMass = 254.0;

  final double limiter = 50;

  @override
  void beginContact(Object other, Contact contact) {
    if (other is SatelliteComponent) {
      if (other.currentHealth > 0) {
        other.isOrbiting = true;

        other.isTooLate = true;
        game.satellites.add(other);
      } else {
        other.destroySatellite();
      }
    } else if (other is AsteroidComponent && !(other.isFiring ?? false)) {
      other.isOrbiting = true;
      game.asteroids.add(other);
    }
    super.beginContact(other, contact);
  }

  @override
  void update(double dt) {
    if (game.satellites.isNotEmpty) {
      for (var satellite in game.satellites) {
        if (satellite.isTooLate && satellite.isOrbiting) {
          final jupiterPosition = game.jupiterPosition.clone();
          Vector2 gravityDirection = jupiterPosition
            ..sub(satellite.body.worldCenter);

          final distance = satellite.body.worldCenter.distanceTo(
            jupiterPosition,
          );

          final gravity = (jupiterGravity *
              (satellite.body.getMassData().mass *
                  jupiterMass %
                  pow(distance, 2)));

          gravityDirection.scaleTo(gravity * dt);

          final normalizedData =
              satellite.body.linearVelocity.clone().normalize();

          if (limiter < normalizedData) {
            //Max 50, starts to get too fast after that
            satellite.body.applyForce(
              satellite.body.linearVelocity.inverted(),
            );
          } else {
            satellite.body.applyForce(
              gravityDirection / 8,
              point: satellite.body.worldCenter,
            );
          }
        }
      }
    }

    if (game.asteroids.isNotEmpty) {
      for (var asteroid in game.asteroids) {
        if (asteroid.isOrbiting!) {
          // Trying to set this in the onLoad will break the gravity? Doesn't go the same way?
          // Looks like it is staying like this
          final jupiterPosition = game.jupiterPosition.clone();

          Vector2 gravityDirection = jupiterPosition
            ..sub(asteroid.body.worldCenter);

          final distance = asteroid.body.worldCenter.distanceTo(
            jupiterPosition,
          );

          final gravity = (jupiterGravity *
              (asteroid.body.getMassData().mass *
                  jupiterMass %
                  pow(distance, 2)));
          gravityDirection.scaleTo(gravity * dt);
          final normalizedData =
              asteroid.body.linearVelocity.clone().normalize();
          if (limiter < normalizedData) {
            //Max 50, starts to get too fast after that
            // largestNumber = normalizedData;
            asteroid.body.applyForce(
              asteroid.body.linearVelocity.inverted(),
            );
          } else {
            asteroid.body.applyForce(
              gravityDirection / 12,
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
