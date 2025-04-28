import 'dart:math';
import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flame_behaviors/flame_behaviors.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flame_jam_2025/game/forge_components/asteroids/behaviors/asteroid_controller_behavior.dart';
import 'package:flame_jam_2025/game/forge_components/earth/earth_component.dart';
import 'package:flame_jam_2025/game/forge_components/earth/earth_gravity_component.dart';
import 'package:flame_jam_2025/game/forge_components/satellite/satellite_component.dart';
import 'package:flame_jam_2025/game/satellites_game.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

enum AsteroidState { firing, orbitingJupiter, spawned, destroyed }

class AsteroidComponent extends BodyComponent<SatellitesGame>
    with ContactCallbacks, EntityMixin {
  AsteroidComponent({
    super.priority,
    // this.currentColor,
    this.newPosition,
    this.impulseDirection,
    required this.startPosition,
    required this.startingDamage,
    this.sizeScaling,
    this.speedScaling,
    this.spriteImage,
  });
  static final Logger _log = Logger('Asteroid Component');
  final double? sizeScaling;
  final double? speedScaling;

  final ui.Image? spriteImage;

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
  // late Color? currentColor;

  late Vector2 fireVel;

  final double startingDamage;

  late double currentDamage;

  SatelliteComponent? sate;
  bool dealtDamage = false;

  bool isSensor = true;

  bool isWithinOrbit = false;

  bool shouldRepel = false;

  late FixtureDef fixtureDefCircle;
  // late FixtureDef fixtureDefCircle2;

  late double turningDirection;
  Random random = Random();

  @override
  Future<void> onLoad() {
    addSprite();
    // currentDamage = 250;
    currentDamage = startingDamage;
    _log.info('Current damage: $currentDamage');

    addBehaviors();

    turningDirection = random.nextDouble() * 0.1;

    paint = ui.Paint()..color = Colors.brown;

    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (isFiring) {
      body.setTransform(
        position,
        angle + -turningDirection,
      );
    }
    super.update(dt);
  }

  @override
  void beginContact(Object other, Contact contact) {
    if (other is EarthGravityComponent) {
      _log.info('Game manager state: $currentDamage & ${other.damageMinimum}');
      _log.info(game.waveManager.hasEnded);
      if (!game.waveManager.hasEnded) {
        controllerBehavior.explodeAsteroid(position, this);
      } else if (other.damageMinimum >= currentDamage) {
        controllerBehavior.explodeAsteroid(position, this);
      }
    } else if (other is EarthComponent) {
      controllerBehavior.explodeAsteroid(position, this);
    } else if (other is SatelliteComponent && isFiring) {
      if (other.isTooLate) {
        return;
      } else if (sate != null && other != sate) {
        sate = other;
        dealtDamage = true;
        if (other.currentHealth >= currentDamage) {
          // _log.info('Current Damage: $currentDamage');
          other.controllerBehavior.takeDamage(currentDamage);
          controllerBehavior.explodeAsteroid(position, this);
        } else {
          other.controllerBehavior.takeDamage(currentDamage);
        }
      } else if (!dealtDamage) {
        sate = other;
        dealtDamage = true;
        if (other.currentHealth >= currentDamage) {
          _log.info('Current Damage: $currentDamage');
          other.controllerBehavior.takeDamage(currentDamage);
          controllerBehavior.explodeAsteroid(position, this);
        } else {
          other.controllerBehavior.takeDamage(currentDamage);
          currentDamage = currentDamage - other.currentHealth;
        }
      }
    }
    super.beginContact(other, contact);
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
    final circle =
        CircleShape(radius: .5 + (sizeScaling ?? 0), position: Vector2.zero());
    // final circle2 = CircleShape(
    //   radius: .5 /* + (sizeScaling ?? 0) */,
    //   position: Vector2(
    //     .2,
    //     0,
    //   ),
    // );

    fixtureDefCircle = FixtureDef(circle, isSensor: true);
    // fixtureDefCircle2 = FixtureDef(circle2, isSensor: true);

    body.createFixture(fixtureDefCircle);
    // body.createFixture(fixtureDefCircle2);
    body.synchronizeFixtures();
    body.setMassData(MassData()..mass = 1.2);

    if (isFiring) {
      var speed = 25 + (speedScaling ?? 0);
      _log.info('Current Speed: $speed');
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

  void addSprite() async {
    final diameter = (.5 + (sizeScaling ?? 0)) * 2;

    final spriteComponent =
        SpriteComponent.fromImage(spriteImage ?? game.spriteImage!,
            // srcSize: ,
            size: Vector2.all(3 * diameter),
            anchor: Anchor.center);

    add(spriteComponent);
  }

  void addBehaviors() {
    addAll(
      [
        AsteroidControllerBehavior(),
      ],
    );
  }
}
