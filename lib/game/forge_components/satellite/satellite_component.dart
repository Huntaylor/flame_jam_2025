import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flame_behaviors/flame_behaviors.dart';

import 'package:flame_jam_2025/game/forge_components/asteroids/asteroid_component.dart';
import 'package:flame_jam_2025/game/forge_components/jupiter/jupiter_gravity_component.dart';
import 'package:flame_jam_2025/game/forge_components/satellite/behaviors/satellite_controller_behavior.dart';
import 'package:flame_jam_2025/game/forge_components/satellite/behaviors/satellite_shapes.dart';
import 'package:flame_jam_2025/game/satellites_game.dart';
import 'package:flutter/material.dart';

enum SatelliteState {
  destroyed,
  alive,
  orbiting,
}

enum SatelliteDifficulty { easy, medium, hard, boss, fast }

enum SatelliteCountry {
  green,
  grey,
  white,
  brown,
  cyan,
  pink,
}

class SatelliteComponent extends BodyComponent<SatellitesGame>
    with ContactCallbacks, EntityMixin {
  SatelliteComponent({
    super.key,
    super.priority,
    required this.isBelow,
    required this.difficulty,
    required this.newPosition,
    required this.isTooLate,
    required this.originCountry,
    this.stepUpSpeed,
    this.stepUpHealth,
    this.countryName,
  }) {
    void getSpeed(double difficultySpeed) {
      speedIncrease = speedIncrease + difficultySpeed + (stepUpSpeed ?? 0);
    }

    void getHealth(double armorType) {
      totalHealth = armorType * (stepUpHealth ?? 1);
    }

    switch (difficulty) {
      case SatelliteDifficulty.easy:
        getSpeed(1);

        getHealth(lightArmor);

      case SatelliteDifficulty.fast:
        getSpeed(5);

        getHealth(cheapArmor);

      case SatelliteDifficulty.medium:
        getSpeed(2);

        getHealth(mediumArmor);

      case SatelliteDifficulty.hard:
        getSpeed(1.5);

        getHealth(heavyArmor);

      case SatelliteDifficulty.boss:
        getSpeed(2);

        getHealth(bossArmor);
    }

    switch (originCountry) {
      case SatelliteCountry.green:
        paint.color = Colors.green;
        countryName = 'Green Country';

      case SatelliteCountry.grey:
        countryName = 'Grey Country';
        paint.color = Colors.grey;

      case SatelliteCountry.white:
        countryName = 'White Country';
        paint.color = Colors.white;

      case SatelliteCountry.brown:
        countryName = 'Brown Country';
        paint.color = Colors.brown;

      case SatelliteCountry.cyan:
        countryName = 'Cyan Country';
        paint.color = Colors.cyan;

      case SatelliteCountry.pink:
        countryName = 'Pink Country';
        paint.color = Colors.pink;
    }
  }

  String? countryName;

  final SatelliteCountry originCountry;

  final Vector2 newPosition;

  final double? stepUpSpeed;
  final double? stepUpHealth;

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

  final double cheapArmor = 75;

  final double lightArmor = 150;

  final double mediumArmor = 350;

  final double heavyArmor = 650;

  final double bossArmor = 1250;

  late double currentHealth;

  double speedIncrease = 0;

  final SatelliteDifficulty difficulty;

  Vector2? _impulseTarget;

  Vector2? startingImpulse;

  Vector2? orbitImpulse;
  double orbitSpeedMax = .5;
  double orbitSpeed = .1;

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
    debugMode = true;
    if (isBoss) {
      if (game.waveManager.waveNumber > 10) {
        totalHealth = bossArmor + (game.waveManager.waveNumber * 5);
      }
    }
    past10 = game.waveManager.waveNumber > 10;

    final maxTime = 30 / speedIncrease;

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
      isBelowFunc(body);
      state = SatelliteState.orbiting;
      launchOrbit = true;
      if (game.waveSatellites.contains(this)) {
        game.waveSatellites.remove(this);
      }
      body.setFixedRotation(false);
      _setOrbitVelocity();
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

      customPaint.color =
          (isBoss) ? const Color.fromARGB(255, 105, 3, 3) : Colors.red;
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
    } else {
      const textStyle = TextStyle(
        color: Colors.amber,
        fontSize: 4,
      );
      final textSpan = TextSpan(
        text: body.linearVelocity.toString(),
        style: textStyle,
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout(
        minWidth: 0,
        maxWidth: 16,
      );

      final offset = Offset(0, -15);
      textPainter.paint(canvas, offset);
    }
    super.render(canvas);

    if (isBoss && !isTooLate) {
      canvas.drawCircle(Offset.zero, .25, bossPaint..color = Colors.grey[800]!);
    }
    super.render(canvas);
  }

  @override
  void update(double dt) {
    if (!isTooLate) {
      _checkImpulse();
    } else {
      _setOrbitVelocity();
    }
    if (isBoss) {
      body.setTransform(
        position,
        angle + -turningDirection,
      );
    }
    if (redirectTimer.isRunning()) {
      redirectTimer.update(dt);
    }

    super.update(dt);
  }

  void _checkImpulse() {
    if (body.linearVelocity != startingImpulse) {
      body.linearVelocity = startingImpulse!;
    }
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
      type: BodyType.dynamic,
      position: newPosition,
    );

    final _body = world.createBody(def)..userData = this;

    switch (difficulty) {
      case SatelliteDifficulty.easy:
        for (var shape in smallerSatellite) {
          final fixtureDef =
              FixtureDef(PolygonShape()..set(shape), isSensor: !isTooLate);
          _body.createFixture(fixtureDef);
        }

      case SatelliteDifficulty.medium:
        for (var shape in mediumSatellite) {
          final fixtureDef =
              FixtureDef(PolygonShape()..set(shape), isSensor: !isTooLate);
          _body.createFixture(fixtureDef);
        }

      case SatelliteDifficulty.hard:
        for (var shape in hardSatellite) {
          final fixtureDef =
              FixtureDef(PolygonShape()..set(shape), isSensor: !isTooLate);
          _body.createFixture(fixtureDef);
        }

      case SatelliteDifficulty.boss:
        for (var shape in bossSatellite) {
          final fixtureDef =
              FixtureDef(PolygonShape()..set(shape), isSensor: !isTooLate);
          _body.createFixture(fixtureDef);
        }

      case SatelliteDifficulty.fast:
        for (var shape in fastSatellite) {
          final fixtureDef =
              FixtureDef(PolygonShape()..set(shape), isSensor: true);
          _body.createFixture(fixtureDef);
        }
    }

    _body.synchronizeFixtures();
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
        applyImpulse(targetVec, _body);
      } else {
        applyImpulse(_impulseTarget!, _body);
      }
    } else {
      isBelowFunc(_body);
      state = SatelliteState.orbiting;
      launchOrbit = true;
      if (game.waveSatellites.contains(this)) {
        game.waveSatellites.remove(this);
      }
      _body.setFixedRotation(false);
    }

    return _body;
  }

  void applyImpulse(Vector2 targetVec, Body _body) {
    double speed;
    if (isOutOfOrbit) {
      _body.linearVelocity = startingImpulse!.inverted();
      _body.clearForces();
    }
    speed = 1 + speedIncrease;

    var velocityX = targetVec.x - _body.position.x;

    var velocityY = targetVec.y - _body.position.y;
    var length = sqrt(velocityX * velocityX + velocityY * velocityY);

    velocityX *= speed / length;

    velocityY *= speed / length;

    startingImpulse = Vector2(velocityX, velocityY);
    _body.linearVelocity = startingImpulse!;
  }

  void addBehaviors() => add(
        SatelliteControllerBehavior(),
      );

  void isBelowFunc(Body _body) {
    if (isBelow) {
      _body.linearVelocity = Vector2(6, 4) * _body.mass;
    } else {
      _body.linearVelocity = Vector2(6, -4) * _body.mass;
    }
  }

  void _setOrbitVelocity() {
    final toComponent = body.position - game.jupiterPosition;
    final radius = toComponent.length;

    final radialDir = toComponent.normalized();

    Vector2 tangentDir;
    if (isBelow) {
      tangentDir = Vector2(-radialDir.y, radialDir.x);
    } else {
      tangentDir = Vector2(radialDir.y, -radialDir.x);
    }

    final tangentialSpeed = orbitSpeed * radius;

    body.linearVelocity = tangentDir * tangentialSpeed;

    if (orbitSpeed < orbitSpeedMax) {
      orbitSpeed = orbitSpeed + .01;
    } else {
      orbitSpeed = orbitSpeedMax;
    }
  }
}
