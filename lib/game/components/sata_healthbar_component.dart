// ignore_for_file: file_names

import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_jam_2025/game/forge_components/satallite_component.dart';
import 'package:flutter/material.dart';

class SataHealthbarComponent extends PositionComponent {
  SataHealthbarComponent({required this.satalliteComponent, super.position});

  final SatalliteComponent satalliteComponent;

  final double healthBarWidth = 1.0;
  final double healthBarHeight = 0.5;

  final customPaint = Paint();

  final Vector2 healthBarPosition = Vector2(-.5, -1);

  late double currentHealth;
  late double totalHealth;

  @override
  FutureOr<void> onLoad() {
    currentHealth = satalliteComponent.totalHealth;
    totalHealth = satalliteComponent.totalHealth;
    add(satalliteComponent);
    return super.onLoad();
  }

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
