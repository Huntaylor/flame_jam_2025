import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame_jam_2025/game/satellites_game.dart';
import 'package:flutter/material.dart';

class MouseRenderComponent extends Component
    with HasGameReference<SatellitesGame>, TapCallbacks {
  MouseRenderComponent();

  final newPaint = Paint();

  @override
  void render(Canvas canvas) {
    if (game.gameState != GameState.mainMenu) {
      canvas.save();
      if (game.asteroids.isNotEmpty &&
          game.lineSegment != null &&
          game.asteroids.any((e) => e.isOrbiting)) {
        final firstAsteroids = game.asteroids.firstWhere((e) => e.isOrbiting);

        drawDashedLine(
          canvas: canvas,
          p1: game.camera
              .localToGlobal(firstAsteroids.body.worldCenter)
              .toOffset(),
          p2: game.lineSegment!.toOffset(),
          paint: newPaint..color = Colors.amber,
          pattern: [20, 30],
        );
      }
      canvas.restore();
      super.render(canvas);
    }
  }

  Canvas drawDashedLine({
    required Canvas canvas,
    required Offset p1,
    required Offset p2,
    required Iterable<double> pattern,
    required Paint paint,
  }) {
    assert(pattern.length.isEven);
    final distance = (p2 - p1).distance;
    final normalizedPattern = pattern.map((width) => width / distance).toList();
    final points = <Offset>[];
    double t = 0;
    int i = 0;
    while (t < 1) {
      points.add(Offset.lerp(p1, p2, t)!);
      t += normalizedPattern[i++]; // dashWidth
      points.add(Offset.lerp(p1, p2, t.clamp(0, 1))!);
      t += normalizedPattern[i++]; // dashSpace
      i %= normalizedPattern.length;
    }

    canvas.drawPoints(PointMode.lines, points, paint);
    return canvas;
  }
}
