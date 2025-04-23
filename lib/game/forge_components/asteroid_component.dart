import 'dart:math';

import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flame_jam_2025/game/forge_components/satallite_component.dart';
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
    required this.damage,
  }) {
    isOrbiting = false;
    isFiring = isFiring ?? false;
  }
  final Vector2? newPosition;
  late bool? isOrbiting;
  late bool? isFiring;
  late Color? currentColor;
  SatalliteComponent? sata;

  late Vector2 fireVel;

  final double damage;

  bool isSensor = true;
  bool dealtDamage = false;

  late FixtureDef fixtureDefCircle;
  late FixtureDef fixtureDefRect;

  late double turningDirection;
  Random random = Random();

  @override
  Future<void> onLoad() {
    Color chosenColor;
    turningDirection = random.nextDouble() * 0.1;
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
  void update(double dt) {
    if (isFiring!) {
      body.setTransform(
        position,
        angle + turningDirection,
      );
    }
    super.update(dt);
  }

  @override
  void beginContact(Object other, Contact contact) {
    if (other is SatalliteComponent) {
      if (sata != null && other != sata) {
        sata = other;
        dealtDamage = true;
        if (other.totalHealth > damage) {
          other.takeDamage(damage);
          game.explodeAsteroid(position, this);
        } else {
          other.takeDamage(damage);
        }
      } else if (!dealtDamage) {
        sata = other;
        dealtDamage = true;
        if (other.totalHealth > damage) {
          other.takeDamage(damage);
          game.explodeAsteroid(position, this);
        } else {
          other.takeDamage(damage);
        }
      }
    }
    super.beginContact(other, contact);
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
    fixtureDefCircle = FixtureDef(circle, isSensor: true);
    fixtureDefRect = FixtureDef(
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
    body.createFixture(fixtureDefCircle);
    body.createFixture(fixtureDefRect);
    body.synchronizeFixtures();
    body.setMassData(MassData()..mass = 1.2);

    if (isFiring ?? false) {
      var speed = 50;
      var velocityX = game.targetPosition.x - body.position.x;

      var velocityY = game.targetPosition.y - body.position.y;
      var length = sqrt(velocityX * velocityX + velocityY * velocityY);

      velocityX *= speed / length;

      velocityY *= speed / length;

      fireVel = Vector2(velocityX, velocityY);

      body.applyLinearImpulse(fireVel);
    } else {
      body.applyLinearImpulse(game.asteroidAngle);
    }

    return body;
  }
}
