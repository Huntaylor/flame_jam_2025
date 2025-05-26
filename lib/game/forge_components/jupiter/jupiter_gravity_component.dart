import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flame_jam_2025/game/forge_components/asteroids/asteroid_component.dart';
import 'package:flame_jam_2025/game/forge_components/satellite/satellite_component.dart';
import 'package:flame_jam_2025/game/satellites_game.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

class JupiterGravityComponent extends BodyComponent<SatellitesGame>
    with ContactCallbacks {
  static final Logger _log = Logger('Jupiter Gravity Component');
  JupiterGravityComponent({super.priority})
      : super(
          paint: Paint()
            ..color = Colors.blue
            ..strokeWidth = 0.15
            ..style = PaintingStyle.stroke,
        );

  final double jupiterGravity = 24.79;
  final double jupiterMass = 254.0;

  final double limiter = 40;

  @override
  void beginContact(Object other, Contact contact) {
    if (other is SatelliteComponent && !other.isTooLate) {
      game.audioComponent.onEnterOrbit();
      if (other.currentHealth > 0) {
        final newSatellite = SatelliteComponent(
          originCountry: other.originCountry,
          newPosition: other.position,
          isTooLate: true,
          isBelow: other.isBelow,
          difficulty: other.difficulty,
        );
        other.state = SatelliteState.orbiting;

        game.world.remove(other);
        if (!game.world.children.contains(newSatellite)) {
          game.world.add(newSatellite);
        }

        if (!game.orbitingSatellites.contains(newSatellite)) {
          game.orbitingSatellites.add(newSatellite);
        }
      } else {
        other.controllerBehavior.destroySatellite(true);
      }
    } else if (other is AsteroidComponent && !other.isFiring) {
      other.state = AsteroidState.orbitingJupiter;
      if (!game.asteroids.contains(other)) {
        game.asteroids.add(other);
      }
    } else if (other is AsteroidComponent && other.isFiring) {
      other.isWithinOrbit = true;
    }
    super.beginContact(other, contact);
  }

  @override
  void endContact(Object other, Contact contact) {
    if (other is AsteroidComponent && other.isFiring) {
      other.isWithinOrbit = false;
    }
    super.endContact(other, contact);
  }

  @override
  void update(double dt) {
    // SATELLITES
    if (game.orbitingSatellites.isNotEmpty) {
      for (var satellite in game.orbitingSatellites) {
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
              gravityDirection / 2,
              point: satellite.body.worldCenter,
            );
          }
        }
      }
    }
    // ASTEROIDS
    if (game.asteroids.isNotEmpty) {
      for (var asteroid in game.asteroids) {
        if (asteroid.isOrbiting && !asteroid.shouldRepel) {
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
              gravityDirection,
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
