import 'dart:math';

import 'package:flame/extensions.dart';
import 'package:flame_behaviors/flame_behaviors.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flame_jam_2025/game/forge_components/asteroids/behaviors/asteroid_controller_behavior.dart';
import 'package:flame_jam_2025/game/forge_components/earth/earth_component.dart';
import 'package:flame_jam_2025/game/forge_components/earth/earth_gravity_component.dart';
import 'package:flame_jam_2025/game/forge_components/satellite/satellite_component.dart';
import 'package:flame_jam_2025/game/sateflies_game.dart';
import 'package:flutter/material.dart';

enum AsteroidState { firing, orbitingJupiter, spawned, destroyed }

class AsteroidComponent extends BodyComponent<SatefliesGame>
    with ContactCallbacks, EntityMixin {
  AsteroidComponent({
    super.priority,
    this.currentColor,
    this.newPosition,
    this.impulseDirection,
    required this.startPosition,
    required this.startingDamage,
  });

  AsteroidState? _asteroidState;

  bool get isOrbiting => state == AsteroidState.orbitingJupiter;
  bool get isFiring => state == AsteroidState.firing;
  bool get isSpawned => state == AsteroidState.spawned;
  bool get isDestroyed => state == AsteroidState.destroyed;

  AsteroidState get state => _asteroidState ?? AsteroidState.spawned;

  set state(AsteroidState state) {
    _asteroidState = state;
  }

  late final AsteroidControllerBehavior controllerBehavior =
      findBehavior<AsteroidControllerBehavior>();

  late AsteroidState asteroidState;

  final Vector2? impulseDirection;
  final Vector2? newPosition;
  final Vector2 startPosition;
  late Color? currentColor;

  late Vector2 fireVel;

  final double startingDamage;

  late double currentDamage;

  SatelliteComponent? sate;
  bool dealtDamage = false;

  bool isSensor = true;

  bool shouldRepel = false;

  late FixtureDef fixtureDefCircle;
  late FixtureDef fixtureDefRect;

  late double turningDirection;
  Random random = Random();

  @override
  void beginContact(Object other, Contact contact) {
    if (other is EarthGravityComponent) {
      if (currentDamage < other.damageMinimum) {
        controllerBehavior.explodeAsteroid(position, this);
      }
    }
    if (other is EarthComponent) {
      controllerBehavior.explodeAsteroid(position, this);
    }
    if (other is SatelliteComponent && isFiring) {
      if (other.isTooLate) {
        return;
      } else if (sate != null && other != sate) {
        sate = other;
        dealtDamage = true;
        if (other.currentHealth >= currentDamage) {
          other.controllerBehavior.takeDamage(currentDamage);
          controllerBehavior.explodeAsteroid(position, this);
        } else {
          other.controllerBehavior.takeDamage(currentDamage);
        }
      } else if (!dealtDamage) {
        sate = other;
        dealtDamage = true;
        if (other.currentHealth >= currentDamage) {
          other.controllerBehavior.takeDamage(currentDamage);
          controllerBehavior.explodeAsteroid(position, this);
        } else {
          currentDamage = currentDamage - other.currentHealth;
          other.controllerBehavior.takeDamage(currentDamage);
        }
      }
    }
    super.beginContact(other, contact);
  }

  @override
  void onRemove() {
    print('Kill asteroid');
    super.onRemove();
  }

  @override
  Future<void> onLoad() {
    addBehaviors();

    currentDamage = startingDamage;
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
    if (isFiring) {
      body.setTransform(
        position,
        angle + turningDirection,
      );
    }
    super.update(dt);
  }

  @override
  Body createBody() {
    final _currentPosition = isFiring ? newPosition : startPosition;
    final def = BodyDef(
      userData: this,
      // bullet: true,
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

    if (isFiring) {
      var speed = 25 + controllerBehavior.speedUpgradeIncrease;
      var velocityX = game.targetPosition.x - body.position.x;

      var velocityY = game.targetPosition.y - body.position.y;
      var length = sqrt(velocityX * velocityX + velocityY * velocityY);

      velocityX *= speed / length;

      velocityY *= speed / length;

      fireVel = Vector2(velocityX, velocityY);

      body.applyLinearImpulse(fireVel);
    } else {
      body.applyLinearImpulse(impulseDirection ?? game.asteroidAngle);
    }

    return body;
  }

  // void fireAsteroid() {
  //   state = AsteroidState.firing;
  //   var speed = 25 + controllerBehavior.speedUpgradeIncrease;
  //   var velocityX = game.targetPosition.x - body.position.x;

  //   var velocityY = game.targetPosition.y - body.position.y;
  //   var length = sqrt(velocityX * velocityX + velocityY * velocityY);

  //   velocityX *= speed / length;

  //   velocityY *= speed / length;

  //   fireVel = Vector2(velocityX, velocityY);
  //   body.clearForces();
  //   body.applyLinearImpulse(fireVel);
  // }

  void addBehaviors() {
    addAll(
      [
        AsteroidControllerBehavior(),
      ],
    );
  }
}
