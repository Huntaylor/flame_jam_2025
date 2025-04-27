// ignore_for_file: file_names

import 'package:flame/components.dart';
import 'package:flame_jam_2025/game/sateflies_game.dart';
import 'package:flutter/material.dart';

class JupiterSanityBarComponent extends PositionComponent
    with HasGameReference<SatefliesGame> {
  JupiterSanityBarComponent({super.position});

  final double healthBarWidth = 1.0;
  final double healthBarHeight = 0.5;

  final customPaint = Paint();

  final Vector2 healthBarPosition = Vector2(-.5, -1);

  double currentHealth = 30;
  double totalHealth = 30;

  void updateHealth(double _currentHealth) {
    currentHealth = _currentHealth;
  }

  @override
  void render(Canvas canvas) {
    customPaint.color = Colors.white;
    canvas.drawRect(
        Rect.fromLTWH(healthBarPosition.x, healthBarPosition.y, healthBarWidth,
            healthBarHeight),
        customPaint);

    canvas.save();
    customPaint.color = Colors.pinkAccent;
    double currentHealthWidth = healthBarWidth * (currentHealth / totalHealth);
    canvas.drawRect(
        Rect.fromLTWH(healthBarPosition.x, healthBarPosition.y,
            currentHealthWidth, healthBarHeight),
        customPaint);
    canvas.restore();

    super.render(canvas);
  }
}
