import 'dart:math';

import 'package:flame/extensions.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flame_behaviors/flame_behaviors.dart';

import 'package:flame_jam_2025/game/forge_components/asteroids/asteroid_component.dart';
import 'package:flame_jam_2025/game/forge_components/jupiter_gravity_component.dart';
import 'package:flame_jam_2025/game/forge_components/satellite/behaviors/satellite_controller_behavior.dart';
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
  }) : super(paint: Paint()..color = Colors.grey) {
    switch (difficulty) {
      case SatelliteDifficulty.easy:
        powerLevel = 1;
        spawnChance = 0.6;
        totalHealth = lightArmor;
      case SatelliteDifficulty.fast:
        speedIncrease = speedIncrease + 3;
        powerLevel = 1;
        spawnChance = 0.6;
        totalHealth = lightArmor;
      case SatelliteDifficulty.medium:
        powerLevel = 3;
        spawnChance = 0.3;
        totalHealth = mediumArmor;
      case SatelliteDifficulty.hard:
        powerLevel = 5;
        spawnChance = 0.15;
        totalHealth = heavyArmor;
      case SatelliteDifficulty.boss:
        powerLevel = 10;
        spawnChance = 0.05;
        totalHealth = bossArmor;
    }
  }

  final bool isBelow;

  SatelliteState? _satelliteState;

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

  final double lightArmor = 50;
  final double mediumArmor = 75;
  final double heavyArmor = 100;
  final double bossArmor = 250;

  late double currentHealth;

  int speedIncrease = 0;

  final SatelliteDifficulty difficulty;

  Vector2? _impulseTarget;

  double? totalHealth;
  double? powerLevel;
  double? spawnChance;

  late AsteroidComponent contactAsteroid;

  bool isTooLate = false;
  bool launchOrbit = false;

  final double healthBarWidth = 1.5;
  final double healthBarHeight = 0.5;

  final customPaint = Paint();

  final Vector2 healthBarPosition = Vector2(-.8, -1.5);

  final polyShapes = [
    [
      Vector2(-0.1, 0.2),
      Vector2(-0.1, -0.3),
      Vector2(0.1, -0.3),
      Vector2(0.1, 0.2),
    ],
    [
      Vector2(-0.1, 0.3),
      Vector2(0.0, 0.2),
      Vector2(0.1, 0.3),
    ],
    [
      Vector2(0.1, 0.0),
      Vector2(0.1, -0.1),
      Vector2(0.4, -0.1),
      Vector2(0.4, 0.0),
    ],
    [
      Vector2(-0.1, 0.0),
      Vector2(-0.4, 0.0),
      Vector2(-0.4, -0.1),
      Vector2(-0.1, -0.1),
    ],
  ];

  set setImpulseTarget(Vector2 target) => _impulseTarget = target;

  late final SatelliteControllerBehavior controllerBehavior =
      findBehavior<SatelliteControllerBehavior>();

  @override
  Future<void> onLoad() {
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
          Vector2(2, 1),
        );
      } else {
        body.applyLinearImpulse(
          Vector2(2, -1),
        );
      }
      state = SatelliteState.orbiting;
      launchOrbit = true;
      if (game.waveSatellites.contains(this)) {
        game.waveSatellites.remove(this);
      }
      body.setFixedRotation(false);
    }
    super.beginContact(other, contact);
  }

  @override
  void render(Canvas canvas) {
    if (!isTooLate) {
      canvas.save();
      canvas.rotate(45);
      customPaint.color = Colors.white;
      canvas.drawRect(
          Rect.fromLTWH(healthBarPosition.x, healthBarPosition.y,
              healthBarWidth, healthBarHeight),
          customPaint);

      customPaint.color = Colors.red[900]!;
      double currentHealthWidth =
          healthBarWidth * (currentHealth / totalHealth!);
      canvas.drawRect(
          Rect.fromLTWH(healthBarPosition.x, healthBarPosition.y,
              currentHealthWidth, healthBarHeight),
          customPaint);
      canvas.restore();
    }

    super.render(canvas);
  }

  @override
  void onRemove() {
    print('Satellite went too far');
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
      position: game.earthPosition,
    );

    final body = world.createBody(def)..userData = this;
    for (var shape in polyShapes) {
      body.createFixtureFromShape(PolygonShape()..set(shape));
    }

    body.synchronizeFixtures();

    // var speed = .5;
    var speed = 1 + speedIncrease;
    var velocityX = _impulseTarget!.x - body.position.x;

    var velocityY = _impulseTarget!.y - body.position.y;
    var length = sqrt(velocityX * velocityX + velocityY * velocityY);

    velocityX *= speed / length;

    velocityY *= speed / length;

    final fireVel = Vector2(velocityX, velocityY);

    body.applyLinearImpulse(fireVel);

    return body;
  }

  void addBehaviors() {
    addAll(
      [
        SatelliteControllerBehavior(),
      ],
    );
  }
}
