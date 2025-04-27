import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flame_jam_2025/game/forge_components/asteroids/asteroid_component.dart';
import 'package:flame_jam_2025/game/forge_components/satellite/satellite_component.dart';
import 'package:flame_jam_2025/game/satellites_game.dart';
import 'package:flutter/material.dart';

class JupiterGravityRepellentComponent extends BodyComponent<SatellitesGame>
    with ContactCallbacks {
  JupiterGravityRepellentComponent({super.priority})
      : super(
          paint: Paint()
            // ..color = Colors.red
            ..color = Colors.transparent
            ..strokeWidth = 0.5
            ..style = PaintingStyle.stroke,
        );

  List<AsteroidComponent> asteroids = [];
  List<SatelliteComponent> satellites = [];

  final double jupiterGravity = 24.79;
  final double jupiterMass = 254.0;

  @override
  void beginContact(Object other, Contact contact) {
    if (other is AsteroidComponent) {
      asteroids.add(other);
      other.shouldRepel = true;
    } else if (other is SatelliteComponent) {
      other.state = SatelliteState.repelling;
      satellites.add(other);
    }
    super.beginContact(other, contact);
  }

  @override
  void endContact(Object other, Contact contact) {
    if (other is AsteroidComponent) {
      if (asteroids.isNotEmpty) {
        other.shouldRepel = false;
        final asteroidBody = asteroids.firstWhere(
          (i) => i.body == contact.getOtherBody(body),
        );

        asteroids.remove(asteroidBody);
      }
    } else if (other is SatelliteComponent) {
      other.state = SatelliteState.orbiting;
      satellites.remove(other);
    }
    super.endContact(other, contact);
  }

  @override
  void update(double dt) {
    // ASTEROIDS
    if (asteroids.isNotEmpty) {
      for (var asteroid in asteroids) {
        if (asteroid.isOrbiting && asteroid.shouldRepel) {
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

          asteroid.body.applyForce(
            (gravityDirection / 7).inverted(),
            point: asteroid.body.worldCenter,
          );
        }
      }
    }
    // SATELLITES
    if (satellites.isNotEmpty) {
      for (var satellite in satellites) {
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
        //need to add in a normalizer
        satellite.body.applyForce(
          (gravityDirection / 6).inverted(),
          point: satellite.body.worldCenter,
        );
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
      radius: game.jupiterSize * 1.5,
    );

    final fixtureDef = FixtureDef(circle, isSensor: true);
    body.createFixture(fixtureDef);
    body.synchronizeFixtures();

    return body;
  }
}
