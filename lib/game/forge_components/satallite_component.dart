import 'dart:math';

import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flame_jam_2025/game/forge_components/asteroid_component.dart';
import 'package:flame_jam_2025/game/pesky_satellites.dart';
import 'package:flutter/material.dart';

class SatalliteComponent extends BodyComponent<PeskySatellites>
    with ContactCallbacks {
  SatalliteComponent({
    super.priority,
    required this.totalHealth,
  }) : super(paint: Paint()..color = Colors.grey);

  bool isAlive = true;

  final double totalHealth;

  late AsteroidComponent contactAsteroid;

  late double currentHealth;

  bool isTooLate = false;

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

  @override
  Future<void> onLoad() {
    currentHealth = totalHealth;

    return super.onLoad();
  }

  // @override
  // void update(double dt) {
  //   body.setTransform(position, angle + .01);
  //   super.update(dt);
  // }

  void takeDamage(double damage) {
    if (!isTooLate) {
      currentHealth = currentHealth - damage;

      // if (parent is SataHealthbarComponent) {
      //   (parent as SataHealthbarComponent).updateHealth(currentHealth);
      // }

      if (currentHealth <= 0 && isAlive) {
        isAlive = false;
        game.explodeSatallite(polyShapes, position, this);
      }
    }
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
          healthBarWidth * (currentHealth / totalHealth);
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
        position: game.earthPosition);

    final body = world.createBody(def)..userData = this;

    for (var shape in polyShapes) {
      body.createFixtureFromShape(PolygonShape()..set(shape));
    }
    body.synchronizeFixtures();

    var speed = .5;
    var velocityX = game.jupiterPosition.x - body.position.x;

    var velocityY = game.jupiterPosition.y - body.position.y;
    var length = sqrt(velocityX * velocityX + velocityY * velocityY);

    velocityX *= speed / length;

    velocityY *= speed / length;

    final fireVel = Vector2(velocityX, velocityY);

    body.applyLinearImpulse(fireVel);

    return body;
  }
}
