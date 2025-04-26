import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flame_jam_2025/game/forge_components/satellite/satellite_component.dart';
import 'package:flame_jam_2025/game/sateflies_game.dart';
import 'package:flutter/material.dart';

class EarthGravityComponent extends BodyComponent<SatefliesGame>
    with ContactCallbacks {
  EarthGravityComponent({super.priority})
      : super(
          paint: Paint()
            ..color = Colors.blue
            ..strokeWidth = 0.15
            ..style = PaintingStyle.stroke,
        );

  //  double jupiterGravity = 24.79;
  //  double jupiterMass = 254.0;

  final double limiter = 40;

  final double damageMinimum = 250;

  // @override
  // void update(double dt) {
  //   // SATELLITES
  //   if (game.orbitingSatellites.isNotEmpty) {
  //     for (var satellite in game.orbitingSatellites) {
  //       if (satellite.isTooLate && satellite.isOrbiting) {
  //         final jupiterPosition = game.jupiterPosition.clone();
  //         Vector2 gravityDirection = jupiterPosition
  //           ..sub(satellite.body.worldCenter);

  //         final distance = satellite.body.worldCenter.distanceTo(
  //           jupiterPosition,
  //         );

  //         final gravity = (jupiterGravity *
  //             (satellite.body.getMassData().mass *
  //                 jupiterMass %
  //                 pow(distance, 2)));

  //         gravityDirection.scaleTo(gravity * dt);

  //         final normalizedData =
  //             satellite.body.linearVelocity.clone().normalize();

  //         if (limiter < normalizedData) {
  //           //Max 50, starts to get too fast after that
  //           satellite.body.applyForce(
  //             satellite.body.linearVelocity.inverted(),
  //           );
  //         } else {
  //           satellite.body.applyForce(
  //             gravityDirection / 2,
  //             point: satellite.body.worldCenter,
  //           );
  //         }
  //       }
  //     }
  //   }
  //   // ASTEROIDS
  //   if (game.asteroids.isNotEmpty) {
  //     for (var asteroid in game.asteroids) {
  //       if (asteroid.isOrbiting && !asteroid.shouldRepel) {
  //         // Trying to set this in the onLoad will break the gravity? Doesn't go the same way?
  //         // Looks like it is staying like this
  //         final jupiterPosition = game.jupiterPosition.clone();

  //         Vector2 gravityDirection = jupiterPosition
  //           ..sub(asteroid.body.worldCenter);

  //         final distance = asteroid.body.worldCenter.distanceTo(
  //           jupiterPosition,
  //         );

  //         final gravity = (jupiterGravity *
  //             (asteroid.body.getMassData().mass *
  //                 jupiterMass %
  //                 pow(distance, 2)));
  //         gravityDirection.scaleTo(gravity * dt);
  //         final normalizedData =
  //             asteroid.body.linearVelocity.clone().normalize();
  //         if (limiter < normalizedData) {
  //           //Max 50, starts to get too fast after that
  //           // largestNumber = normalizedData;
  //           asteroid.body.applyForce(
  //             asteroid.body.linearVelocity.inverted(),
  //           );
  //         } else {
  //           asteroid.body.applyForce(
  //             gravityDirection,
  //             point: asteroid.body.worldCenter,
  //           );
  //         }
  //       }
  //     }
  //   }

  //   super.update(dt);
  // }

  @override
  void endContact(Object other, Contact contact) {
    if (other is SatelliteComponent) {
      other.isOutOfOrbit = true;
    }
    super.endContact(other, contact);
  }

  @override
  Body createBody() {
    final bodyDef = BodyDef(position: Vector2.zero());
    final body = world.createBody(bodyDef)..userData = this;
    final circle = CircleShape(
      position: game.earthPosition,
      radius: game.earthSize * 5,
    );

    final fixtureDef = FixtureDef(circle, isSensor: true);
    body.createFixture(fixtureDef);
    body.synchronizeFixtures();

    return body;
  }
}
