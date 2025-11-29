import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flame_jam_2025/game/forge_components/asteroids/asteroid_component.dart';
import 'package:flame_jam_2025/game/forge_components/satellite/satellite_component.dart';
import 'package:flame_jam_2025/game/satellites_game.dart';
import 'package:flutter/material.dart';

class JupiterGravityComponent extends BodyComponent<SatellitesGame>
    with ContactCallbacks {
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
  void beginContact(Object other, Contact contact) async {
    if (other is SatelliteComponent && !other.isTooLate) {
      game.audioComponent.onEnterOrbit();
      if (other.currentHealth > 0) {
        final newSatellite = SatelliteComponent(
          key: other.key,
          originCountry: other.originCountry,
          newPosition: other.position,
          isTooLate: true,
          isBelow: other.isBelow,
          difficulty: other.difficulty,
        );

        game.world.remove(other);

        //This is creating two on a rare edgecase? I've noticed it with the fastest ones
        final check = game.orbitingSatellites.firstWhere(
          (component) => component.key == newSatellite.key,
          orElse: () => SatelliteComponent(
            originCountry: other.originCountry,
            newPosition: other.position,
            isTooLate: true,
            isBelow: other.isBelow,
            difficulty: other.difficulty,
          ),
        );
        if (check.key == null) {
          game.orbitingSatellites.add(newSatellite);
          game.world.add(newSatellite);
          await Future.wait([newSatellite.loaded]);
          createGravityJoint(newSatellite.body);
        }
      } else {
        other.controllerBehavior.destroySatellite(true);
      }
    } else if (other is AsteroidComponent) {
      if (!other.isFiring) {
        other.state = AsteroidState.orbitingJupiter;
        if (!game.asteroids.contains(other)) {
          game.asteroids.add(other);
        }
      } else {
        other.isWithinOrbit = true;
      }
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
    // ASTEROIDS
    if (game.asteroids.isNotEmpty) {
      for (var asteroid in game.asteroids) {
        if (asteroid.isOrbiting && !asteroid.shouldRepel) {
          applyGravity(asteroid.body, dt);
        }
      }
    }

    super.update(dt);
  }

  void createGravityJoint(Body satelliteBody) {
    final distanceJointDef = DistanceJointDef()
      ..initialize(
        satelliteBody,
        body,
        satelliteBody.worldCenter,
        game.jupiterPosition,
      )
      ..length = 25
      ..frequencyHz = 0.7
      ..dampingRatio = 0.9;

    game.world.createJoint(DistanceJoint(distanceJointDef));
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

  void applyGravity(Body objectBody, double dt) {
    final jupiterPosition = game.jupiterPosition.clone();

    Vector2 gravityDirection = jupiterPosition..sub(objectBody.worldCenter);

    final distance = objectBody.worldCenter.distanceTo(
      jupiterPosition,
    );

    final gravity = (jupiterGravity *
        (objectBody.getMassData().mass * jupiterMass % pow(distance, 2)));

    gravityDirection.scaleTo(gravity * dt);

    final normalizedData = objectBody.linearVelocity.clone().normalize();

    if (limiter < normalizedData) {
      //Max 50, starts to get too fast after that
      objectBody.applyForce(
        objectBody.linearVelocity.inverted(),
      );
    } else {
      objectBody.applyForce(
        gravityDirection,
        point: objectBody.worldCenter,
      );
    }
  }
}
