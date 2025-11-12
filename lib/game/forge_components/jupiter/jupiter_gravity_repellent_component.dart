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

  List<AsteroidComponent> orbitingAsteroids = [];
  List<SatelliteComponent> orbitingSatellites = [];

  final double jupiterGravity = 24.79;
  final double jupiterMass = 254.0;

  @override
  void beginContact(Object other, Contact contact) {
    if (other is AsteroidComponent) {
      orbitingAsteroids.add(other);
      other.shouldRepel = true;
    } else if (other is SatelliteComponent) {
      other.state = SatelliteState.repelling;
      orbitingSatellites.add(other);
    }
    super.beginContact(other, contact);
  }

  @override
  void endContact(Object other, Contact contact) {
    if (other is AsteroidComponent) {
      if (orbitingAsteroids.isNotEmpty) {
        other.shouldRepel = false;
        final asteroidBody = orbitingAsteroids.firstWhere(
          (i) => i.body == contact.getOtherBody(body),
        );

        orbitingAsteroids.remove(asteroidBody);
      }
    } else if (other is SatelliteComponent) {
      other.state = SatelliteState.orbiting;
      orbitingSatellites.remove(other);
    }
    super.endContact(other, contact);
  }

  @override
  void update(double dt) {
    // ASTEROIDS
    if (orbitingAsteroids.isNotEmpty) {
      for (var asteroid in orbitingAsteroids) {
        if (asteroid.isOrbiting && asteroid.shouldRepel) {
          applyRepellent(asteroid.body, dt);
        }
      }
    }
    // SATELLITES
    if (orbitingSatellites.isNotEmpty) {
      for (var satellite in orbitingSatellites) {
        applyRepellent(satellite.body, dt);
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

  void applyRepellent(Body objectBody, double dt) {
    final jupiterPosition = game.jupiterPosition.clone();

    Vector2 gravityDirection = jupiterPosition..sub(objectBody.worldCenter);

    final distance = objectBody.worldCenter.distanceTo(
      jupiterPosition,
    );

    final gravity = (jupiterGravity *
        (objectBody.getMassData().mass * jupiterMass % pow(distance, 2)));

    gravityDirection.scaleTo(gravity * dt);

    objectBody.applyForce(
      (gravityDirection / 6).inverted(),
      point: objectBody.worldCenter,
    );
  }
}
