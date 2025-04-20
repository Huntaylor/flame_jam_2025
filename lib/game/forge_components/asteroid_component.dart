import 'dart:developer' as message;
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
  }) {
    isOrbiting = false;
    isFiring = isFiring ?? false;
  }

  late bool? isOrbiting;
  late bool? isFiring;
  late Color? currentColor;

  @override
  Future<void> onLoad() {
    final rnd = Random();
    if (rnd.nextBool()) {
      paint = Paint()..color = Colors.brown;
    } else {
      paint = Paint()..color = Colors.blueGrey;
    }
    return super.onLoad();
  }

  @override
  Body createBody() {
    final currentPosition =
        isFiring! ? game.firingPosition : game.asteroidPosition;
    final def = BodyDef(
      userData: this,
      isAwake: true,
      type: BodyType.dynamic,
      position: currentPosition,
    );

    final body = world.createBody(def)..userData = this;
    final circle = CircleShape(radius: .5, position: Vector2.zero());
    body.createFixtureFromShape(
      PolygonShape()
        ..set([Vector2(0, 0), Vector2(.5, 0), Vector2(.5, .7), Vector2(0, .7)]),
    );
    body.createFixtureFromShape(circle);
    body.synchronizeFixtures();
    body.setMassData(MassData()..mass = 1.2);
    if (isFiring ?? false) {
      var speed = 50;
      var velocityX = game.firingAngle.x - body.position.x;
      var velocityY = game.firingAngle.y - body.position.y;
      var length = sqrt(velocityX * velocityX + velocityY * velocityY);

      velocityX *= speed / length;

      velocityY *= speed / length;

      body.applyLinearImpulse(Vector2(velocityX, velocityY));
    } else {
      body.applyLinearImpulse(game.asteroidAngle);
    }

    return body;
  }

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

  @override
  void onRemove() {
    message.log('Deleted');
    super.onRemove();
  }
}
