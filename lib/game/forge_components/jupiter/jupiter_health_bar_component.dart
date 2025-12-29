// ignore_for_file: file_names

import 'dart:async';

import 'package:app_ui/app_ui.dart';
import 'package:flame/components.dart';
import 'package:flame_jam_2025/game/satellites_game.dart';
import 'package:flutter/material.dart';

class JupiterHealthBarComponent extends PositionComponent
    with HasGameReference<SatellitesGame> {
  JupiterHealthBarComponent({super.position, super.anchor, super.size});

  final double healthBarWidth = 200;
  final double healthBarHeight = 30;

  final customPaint = Paint();

  final Vector2 healthBarPosition = Vector2(-.5, -1);

  double currentHealth = 30;

  late TextComponent orbitTextComponent;

  void updateHealth(double _currentHealth) {
    currentHealth = _currentHealth;
  }

  @override
  FutureOr<void> onLoad() {
    orbitTextComponent = TextComponent(
      textRenderer: TextPaint(
          style: SatellitesTextStyle.titleMedium.copyWith(color: Colors.white)),
      anchor: Anchor.topRight,
      text: 'Orbit Capacity',
      position: Vector2(
        position.x + healthBarWidth,
        -height,
      ),
    );
    currentHealth = game.totalHealth;
    add(orbitTextComponent);
    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (game.gameBloc.state.isNotStart) {
      orbitTextComponent.text = '';
    } else {
      orbitTextComponent.text = 'Orbit Capacity';
    }
    super.update(dt);
  }

  @override
  void render(Canvas canvas) {
    if (game.gameBloc.state.isNotStart) {
      return;
    }
    double count = currentHealth - game.orbitingPower;
    if (count <= 0) {
      count = 0;
    }
    customPaint.color = Colors.white;
    canvas.drawRect(
        Rect.fromLTWH(x, y, healthBarWidth, healthBarHeight), customPaint);

    canvas.save();
    customPaint.color = (count > 15) ? Colors.green : Colors.red;
    double currentHealthWidth = healthBarWidth * (count / game.totalHealth);
    canvas.drawRect(
        Rect.fromLTWH(x, y, currentHealthWidth, healthBarHeight), customPaint);
    canvas.restore();

    super.render(canvas);
  }
}
