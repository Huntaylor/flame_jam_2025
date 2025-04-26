import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flame_behaviors/flame_behaviors.dart';

import 'package:flame_jam_2025/game/forge_components/asteroids/asteroid_component.dart';
import 'package:flame_jam_2025/game/forge_components/jupiter/jupiter_gravity_component.dart';
import 'package:flame_jam_2025/game/forge_components/satellite/behaviors/satellite_controller_behavior.dart';
import 'package:flame_jam_2025/game/forge_components/satellite/behaviors/satellite_shapes.dart';
import 'package:flame_jam_2025/game/sateflies_game.dart';
import 'package:flutter/material.dart';

enum SatelliteState { destroyed, alive, orbiting, repelling }

enum SatelliteDifficulty { easy, medium, hard, boss, fast }

class SatelliteComponent extends BodyComponent<SatefliesGame>
    with ContactCallbacks, EntityMixin {
  SatelliteComponent({
    required this.isBelow,
    super.priority,
    required this.difficulty,
    this.stepUpSpeed,
    required this.newPosition,
    required this.isTooLate,
  }) : super(paint: Paint()..color = Colors.grey) {
    void getSpeed(double difficultySpeed) {
      speedIncrease = speedIncrease + difficultySpeed + (stepUpSpeed ?? 0);
    }

    switch (difficulty) {
      case SatelliteDifficulty.easy:
        getSpeed(0);
        totalHealth = lightArmor;
      case SatelliteDifficulty.fast:
        getSpeed(4);
        totalHealth = cheapArmor;
      case SatelliteDifficulty.medium:
        getSpeed(2);
        totalHealth = mediumArmor;
      case SatelliteDifficulty.hard:
        getSpeed(1);
        totalHealth = heavyArmor;
      case SatelliteDifficulty.boss:
        getSpeed(3);
        totalHealth = bossArmor;
    }
  }

  final Vector2 newPosition;

  final double? stepUpSpeed;

  final bool isBelow;
  bool isOutOfOrbit = false;

  bool past10 = false;

  SatelliteState? _satelliteState;

  bool get isEasy => difficulty == SatelliteDifficulty.easy;
  bool get isMedium => difficulty == SatelliteDifficulty.medium;
  bool get isHard => difficulty == SatelliteDifficulty.hard;
  bool get isFast => difficulty == SatelliteDifficulty.fast;
  bool get isBoss => difficulty == SatelliteDifficulty.boss;

  bool get isAlive => state == SatelliteState.alive;
  bool get isDestroyed => state == SatelliteState.destroyed;
  bool get isOrbiting => state == SatelliteState.orbiting;
  bool get isRepelling => state == SatelliteState.repelling;

  SatelliteState get state => _satelliteState ?? SatelliteState.alive;

  set state(SatelliteState state) {
    _satelliteState = state;
  }

  //Max 100 components - Max 30 asteroids
  // 70 Satellites max

  Vector2 maxBottomRange = Vector2(60, 100);
  Vector2 maxTopRange = Vector2(160, 30);
  Vector2 earthGravityRight = Vector2(20.0, 15.0);
  Vector2 earthGravityBottom = Vector2(15.0, 20.0);

  int jupiterGravityLeftX = 110;
  int jupiterGravityTopY = 35;

  final double cheapArmor = 25;
  final double lightArmor = 50;
  final double mediumArmor = 75;
  final double heavyArmor = 100;
  final double bossArmor = 300;

  late double currentHealth;

  double speedIncrease = 0;

  final SatelliteDifficulty difficulty;

  Vector2? _impulseTarget;

  Vector2? startingImpulse;

  double? totalHealth;

  late AsteroidComponent contactAsteroid;

  bool isTooLate;
  bool launchOrbit = false;

  final double healthBarWidth = 1.7;
  final double healthBarHeight = 0.5;

  final customPaint = Paint();

  final bossPaint = Paint();

  final rnd = Random();
  final rnd2 = Random();

  final double turningDirection = -.01;

  final Vector2 healthBarPosition = Vector2(-.8, -2);
  final Vector2 bossHealthBarPosition = Vector2(-.8, -3);

  late Timer redirectTimer;

  set setImpulseTarget(Vector2 target) => _impulseTarget = target;

  late final SatelliteControllerBehavior controllerBehavior =
      findBehavior<SatelliteControllerBehavior>();

  @override
  Future<void> onLoad() {
    past10 = game.waveManager.waveNumber > 10;

    final maxTime = 40 / speedIncrease;

    redirectTimer = Timer(max(1, maxTime),
        autoStart: past10 && !isTooLate,
        repeat: false,
        onTick: () => applyImpulse(_impulseTarget!, body));
    addBehaviors();
    setUpSatellite();

    return super.onLoad();
  }

  void setUpSatellite() {
    currentHealth = totalHealth!;
  }

  @override
  void beginContact(Object other, Contact contact) {
    if (other is JupiterGravityComponent && !launchOrbit) {
      if (isBelow) {
        body.applyLinearImpulse(
          Vector2(6, 4) * body.mass,
        );
      } else {
        body.applyLinearImpulse(
          Vector2(6, -4) * body.mass,
        );
      }
      state = SatelliteState.orbiting;
      launchOrbit = true;
      if (game.waveSatellites.contains(this)) {
        game.waveSatellites.remove(this);
      }
      body.setFixedRotation(false);
      // try {
      //   if (body.fixtures.any((e) => e.isSensor)) {
      //     for (var fixture in body.fixtures) {
      //       fixture.setSensor(false);
      //     }
      //     body.synchronizeFixtures();
      //   }
      // } catch (e) {
      //   Logger('Satellite Component -- setting Sensors to false error: $e');
      // }
    }
    super.beginContact(other, contact);
  }

  @override
  void render(Canvas canvas) {
    if (!isTooLate) {
      canvas.save();
      canvas.rotate(-angle + turningDirection);
      customPaint.color = Colors.white;
      if (isBoss) {
        canvas.drawRect(
            Rect.fromLTWH(bossHealthBarPosition.x, bossHealthBarPosition.y,
                healthBarWidth, healthBarHeight),
            customPaint);
      } else {
        canvas.drawRect(
            Rect.fromLTWH(healthBarPosition.x, healthBarPosition.y,
                healthBarWidth, healthBarHeight),
            customPaint);
      }

      customPaint.color = (isBoss) ? Colors.green[900]! : Colors.red[900]!;
      double currentHealthWidth =
          healthBarWidth * (currentHealth / totalHealth!);
      if (isBoss) {
        canvas.drawRect(
            Rect.fromLTWH(bossHealthBarPosition.x, bossHealthBarPosition.y,
                currentHealthWidth, healthBarHeight),
            customPaint);
      } else {
        canvas.drawRect(
            Rect.fromLTWH(healthBarPosition.x, healthBarPosition.y,
                currentHealthWidth, healthBarHeight),
            customPaint);
      }
      canvas.restore();
    }
    super.render(canvas);
    if (isBoss && !isTooLate) {
      canvas.drawCircle(Offset.zero, .25, bossPaint..color = Colors.grey[800]!);
    }
  }

  @override
  void update(double dt) {
    if (redirectTimer.isRunning()) {
      redirectTimer.update(dt);
    }
    if (isBoss && !isTooLate) {
      body.setTransform(
        position,
        angle + -turningDirection,
      );
    }
    super.update(dt);
  }

  @override
  void onRemove() {
    if (game.waveSatellites.contains(this)) {
      game.waveSatellites.remove(this);
    }
    super.onRemove();
  }

  @override
  Body createBody() {
    final def = BodyDef(
      fixedRotation: true,
      angle: -45,
      userData: this,
      isAwake: true,
      type: BodyType.dynamic,
      position: newPosition,
    );

    final body = world.createBody(def)..userData = this;

    if (isEasy) {
      for (var shape in smallerSatellite) {
        final fixtureDef =
            FixtureDef(PolygonShape()..set(shape), isSensor: !isTooLate);
        body.createFixture(fixtureDef);
      }
    } else if (isMedium) {
      for (var shape in mediumSatellite) {
        final fixtureDef =
            FixtureDef(PolygonShape()..set(shape), isSensor: !isTooLate);
        body.createFixture(fixtureDef);
      }
    } else if (isHard) {
      for (var shape in hardSatellite) {
        final fixtureDef =
            FixtureDef(PolygonShape()..set(shape), isSensor: !isTooLate);
        body.createFixture(fixtureDef);
      }
    } else if (isFast) {
      for (var shape in fastSatellite) {
        final fixtureDef =
            FixtureDef(PolygonShape()..set(shape), isSensor: !isTooLate);
        body.createFixture(fixtureDef);
      }
    } else if (isBoss) {
      for (var shape in bossSatellite) {
        final fixtureDef =
            FixtureDef(PolygonShape()..set(shape), isSensor: !isTooLate);
        body.createFixture(fixtureDef);
      }
    } else {
      for (var shape in smallerSatellite) {
        final fixtureDef =
            FixtureDef(PolygonShape()..set(shape), isSensor: !isTooLate);
        body.createFixture(fixtureDef);
      }
    }

    body.synchronizeFixtures();
    if (!isTooLate) {
      if (past10) {
        final isEvasive = rnd.nextBool();
        Vector2 targetVec = _impulseTarget!;
        if (isEvasive) {
          final isUp = rnd2.nextBool();
          if (isUp) {
            final topX =
                rnd.nextInt(maxTopRange.x.toInt()) + jupiterGravityLeftX;

            final topY = rnd.nextInt(maxTopRange.y.toInt()) + 5;

            targetVec = Vector2(topX.toDouble(), topY.toDouble());
          } else {
            final bottomX = rnd.nextInt(maxBottomRange.x.toInt()) + 10;

            final bottomY = rnd.nextInt(
                    game.camera.visibleWorldRect.size.height.toInt() - 20) +
                jupiterGravityTopY;
            targetVec = Vector2(bottomX.toDouble(), bottomY.toDouble());
          }
        }
        applyImpulse(targetVec, body);
      } else {
        applyImpulse(_impulseTarget!, body);
      }
    } else {
      if (isBelow) {
        body.applyLinearImpulse(
          Vector2(6, 4) * body.mass,
        );
      } else {
        body.applyLinearImpulse(
          Vector2(6, -4) * body.mass,
        );
      }
      state = SatelliteState.orbiting;
      launchOrbit = true;
      if (game.waveSatellites.contains(this)) {
        game.waveSatellites.remove(this);
      }
      body.setFixedRotation(false);
    }

    return body;
  }

  void applyImpulse(Vector2 targetVec, Body _body) {
    double speed;
    if (isOutOfOrbit) {
      _body.applyLinearImpulse(startingImpulse!.inverted());
      body.clearForces();
    }
    speed = 1 + speedIncrease;

    var velocityX = targetVec.x - _body.position.x;

    var velocityY = targetVec.y - _body.position.y;
    var length = sqrt(velocityX * velocityX + velocityY * velocityY);

    velocityX *= speed / length;

    velocityY *= speed / length;

    startingImpulse = Vector2(velocityX, velocityY);
    _body.applyLinearImpulse(startingImpulse!);
  }

  void addBehaviors() {
    addAll(
      [
        SatelliteControllerBehavior(),
      ],
    );
  }
}
