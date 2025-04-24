import 'dart:math';

import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flame_jam_2025/game/forge_components/asteroid_component.dart';
import 'package:flame_jam_2025/game/forge_components/jupiter_gravity_component.dart';
import 'package:flame_jam_2025/game/sateflies_game.dart';
import 'package:flutter/material.dart';

enum SatelliteDifficulty { easy, medium, hard, boss }

class SatelliteComponent extends BodyComponent<SatefliesGame>
    with ContactCallbacks {
  SatelliteComponent({
    super.priority,
    required this.difficulty,
  }) : super(paint: Paint()..color = Colors.grey) {
    switch (difficulty) {
      case SatelliteDifficulty.easy:
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

  //Max 100 components - Max 30 asteroids
  // 70 Satellites max

  final double lightArmor = 50;
  final double mediumArmor = 75;
  final double heavyArmor = 100;
  final double bossArmor = 250;

  late double currentHealth;

  final SatelliteDifficulty difficulty;

  Vector2? _impulseTarget;

  bool isAlive = true;

  double? totalHealth;
  double? powerLevel;
  double? spawnChance;

  late AsteroidComponent contactAsteroid;

  bool isTooLate = false;
  bool isOrbiting = false;
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

  @override
  Future<void> onLoad() {
    setUpSatellite();

    return super.onLoad();
  }

  void setUpSatellite() {
    currentHealth = totalHealth!;
  }

  void takeDamage(double damage) {
    if (!isTooLate) {
      currentHealth = currentHealth - damage;
      if (currentHealth <= 0 && isAlive) {
        destroySatellite();
      }
    }
  }

  @override
  void beginContact(Object other, Contact contact) {
    if (other is JupiterGravityComponent && !launchOrbit) {
      body.applyLinearImpulse(Vector2(2, -1));
      launchOrbit = true;
    }
    super.beginContact(other, contact);
  }

  void destroySatellite() {
    isAlive = false;
    game.explodeSatellite(polyShapes, position, this);
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

      customPaint.color = Colors.pinkAccent;
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
  Body createBody() {
    final def = BodyDef(
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

    var speed = .5;
    var velocityX = _impulseTarget!.x - body.position.x;

    var velocityY = _impulseTarget!.y - body.position.y;
    var length = sqrt(velocityX * velocityX + velocityY * velocityY);

    velocityX *= speed / length;

    velocityY *= speed / length;

    final fireVel = Vector2(velocityX, velocityY);

    body.applyLinearImpulse(fireVel);

    return body;
  }
}
