import 'dart:math';

import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flame_jam_2025/game/pesky_satellites.dart';
import 'package:flutter/material.dart';

class AsteroidComponent extends BodyComponent<PeskySatellites>
    with ContactCallbacks {
  AsteroidComponent({
    super.priority,
    this.isOrbiting,
    this.isFiring,
    this.currentColor,
    this.newPosition,
  }) {
    isOrbiting = false;
    isFiring = isFiring ?? false;
  }
  final Vector2? newPosition;
  late bool? isOrbiting;
  late bool? isFiring;
  late Color? currentColor;

  // late double turningDirection;
  // Random random = Random();

  @override
  Future<void> onLoad() {
    Color chosenColor;
    // turningDirection = random.nextDouble() * 0.1;
    final brown = Colors.brown;
    final blueGrey = Colors.blueGrey;
    final rnd = Random();
    {
      if (rnd.nextBool()) {
        chosenColor = brown;
      } else {
        chosenColor = blueGrey;
      }
    }
    paint = Paint()..color = currentColor ?? chosenColor;
    currentColor ??= chosenColor;
    return super.onLoad();
  }

  @override
  Body createBody() {
    final _currentPosition = isFiring! ? newPosition : game.asteroidPosition;
    final def = BodyDef(
      userData: this,
      isAwake: true,
      type: BodyType.dynamic,
      position: _currentPosition,
    );

    final body = world.createBody(def)..userData = this;
    final circle = CircleShape(radius: .5, position: Vector2.zero());
    final fixtureDef = FixtureDef(circle, isSensor: true);
    final fixtureDefSquare = FixtureDef(
      PolygonShape()
        ..set(
          [
            Vector2(0, 0),
            Vector2(.5, 0),
            Vector2(.5, .7),
            Vector2(0, .7),
          ],
        ),
      isSensor: true,
    );
    body.createFixture(fixtureDef);
    body.createFixture(fixtureDefSquare);
    body.synchronizeFixtures();
    body.setMassData(MassData()..mass = 1.2);
    if (isFiring ?? false) {
      var speed = 50;
      var velocityX = game.targetPosition.x - body.position.x;

      var velocityY = game.targetPosition.y - body.position.y;
      var length = sqrt(velocityX * velocityX + velocityY * velocityY);

      velocityX *= speed / length;

      velocityY *= speed / length;

      final vel = Vector2(velocityX, velocityY);

      body.applyLinearImpulse(vel);
    } else {
      body.applyLinearImpulse(game.asteroidAngle);
    }

    return body;
  }

  // @override
  // Body createBody() {
  //   // final newPosition = isFiring! ? currentPosition : game.asteroidPosition;
  //   final currentPosition =
  //       isFiring! ? game.firingPosition : game.asteroidPosition;
  //   final def = BodyDef(
  //     userData: this,
  //     isAwake: true,
  //     type: BodyType.dynamic,
  //     position: currentPosition,
  //     // position: newPosition,
  //   );

  //   final body = world.createBody(def)..userData = this;
  //   final circle = CircleShape(radius: .5, position: Vector2.zero());
  //   final fixtureDef = FixtureDef(circle, isSensor: true);
  //   final fixtureDefSquare = FixtureDef(
  //     PolygonShape()
  //       ..set(
  //         [
  //           Vector2(0, 0),
  //           Vector2(.5, 0),
  //           Vector2(.5, .7),
  //           Vector2(0, .7),
  //         ],
  //       ),
  //     isSensor: true,
  //   );
  //   body.createFixture(fixtureDefSquare);
  //   body.createFixture(
  //     fixtureDef,
  //   );
  //   body.synchronizeFixtures();
  //   body.setMassData(MassData()..mass = 1.2);
  //   if (isFiring ?? false) {
  //     var speed = 50;
  //     var velocityX = game.targetPosition.x - body.position.x;
  //     var velocityY = game.targetPosition.y - body.position.y;
  //     var length = sqrt(velocityX * velocityX + velocityY * velocityY);

  //     velocityX *= speed / length;

  //     velocityY *= speed / length;

  //     body.applyLinearImpulse(Vector2(velocityX, velocityY));
  //   } else {
  //     body.applyLinearImpulse(game.asteroidAngle);
  //   }

  //   body.linearVelocity.clampScalar(-30.0, 30);

  //   return body;
  // }

  // void fireAsteroid() {
  //   isFiring = true;
  //   isOrbiting = false;
  //   var speed = 2;
  //   var velocityX = game.targetPosition.x - body.position.x;
  //   var velocityY = game.targetPosition.y - body.position.y;
  //   // var length = sqrt(velocityX * velocityX + velocityY * velocityY);

  //   velocityX *= speed;

  //   velocityY *= speed;

  //   final velocity = Vector2(velocityX, velocityY);

  //   body.applyLinearImpulse(velocity);
  // }

  // @override
  // void update(double dt) {
  //   updateMovement();
  //   super.update(dt);
  // }

  // void updateMovement() {
  //   final desiredSpeed = 50;
  //   final currentForwardNormal = body.worldVector(Vector2(0.0, 1.0));
  //   final currentSpeed = _forwardVelocity.dot(currentForwardNormal);
  //   var force = 0.0;
  //   if (desiredSpeed < currentSpeed) {
  //     force = -_maxDriveForce;
  //   } else if (desiredSpeed > currentSpeed) {
  //     force = _maxDriveForce;
  //   }
  //   print(currentSpeed);

  //   body.applyForce(currentForwardNormal..scale(30));
  // }
}
