import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame_jam_2025/game/satellites_game.dart';
import 'package:flutter/material.dart';

class MouseRenderComponent extends Component
    with HasGameReference<SatellitesGame>, TapCallbacks {
  MouseRenderComponent({super.priority});

  final newPaint = Paint();

  final rayLength = 1500.0;

  double animationOffset = 0.0;
  final double dashLength = 15.0;
  final double gapLength = 30;
  final double animationSpeed = 100.0;

  final double fadeDistance = 80.0;

  Vector2 previousPosition = Vector2.zero();

  // @override
  // void renderTree(Canvas canvas) {
  //   super.renderTree(canvas);
  //   if (game.gameState != GameState.mainMenu) {
  //     if (game.asteroids.isNotEmpty &&
  //         game.lineSegment != null &&
  //         game.asteroids.any((e) => e.isOrbiting)) {
  //       final firstAsteroids = game.asteroids.firstWhere((e) => e.isOrbiting);

  //       final position =
  //           game.camera.localToGlobal(firstAsteroids.body.worldCenter);

  //       final direction = (game.lineSegment! - position).normalized();

  //       final distanceToMouse = position.distanceTo(game.lineSegment!);

  //       final totalLength = distanceToMouse + 50.0;
  //       final endPoint = position + (direction * totalLength);

  //       _drawDottedLine(canvas, position, endPoint);
  //     }
  //   }
  // }

  @override
  void render(Canvas canvas) {
    // super.render(canvas);

    if (game.gameState != GameState.mainMenu) {
      if (game.asteroids.isNotEmpty &&
          game.lineSegment != null &&
          game.asteroids.any((e) => e.isOrbiting)) {
        final firstAsteroids = game.asteroids.firstWhere((e) => e.isOrbiting);

        final position =
            game.camera.localToGlobal(firstAsteroids.body.worldCenter);

        final direction = (game.lineSegment! - position).normalized();

        final distanceToMouse = position.distanceTo(game.lineSegment!);

        final totalLength = distanceToMouse + 50.0;
        final endPoint = position + (direction * totalLength);

        _drawDottedLine(canvas, position, endPoint);
      }
    }
  }

  void _drawDottedLine(Canvas canvas, Vector2 start, Vector2 end) {
    final totalDistance = start.distanceTo(end);
    final direction = (end - start).normalized();
    final patternLength = dashLength + gapLength;
    final fadeStartDistance = totalDistance - fadeDistance;
    double currentDistance = animationOffset % patternLength;

    while (currentDistance < totalDistance) {
      final dashStart = start + (direction * currentDistance);
      final dashEndDistance =
          math.min(currentDistance + dashLength, totalDistance);
      final dashEnd = start + (direction * dashEndDistance);

      // Calculate opacity based on distance
      double opacity = 1.0;
      if (currentDistance > fadeStartDistance) {
        // Fade out over the fadeDistance
        final fadeProgress =
            (currentDistance - fadeStartDistance) / fadeDistance;
        opacity = 1.0 - fadeProgress.clamp(0.0, 1.0);
      }

      if (currentDistance >= 0) {
        canvas.drawLine(
          dashStart.toOffset(),
          dashEnd.toOffset(),
          newPaint..color = Colors.amber.withAlpha((opacity * 255).toInt()),
        );
      } else if (dashEndDistance > 0) {
        final partialDashStart = start;
        final partialDashEnd = start + (direction * dashEndDistance);
        canvas.drawLine(
          partialDashStart.toOffset(),
          partialDashEnd.toOffset(),
          newPaint..color = Colors.amber.withAlpha((opacity * 255).toInt()),
        );
      }

      currentDistance += patternLength;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (game.asteroids.isNotEmpty &&
        game.lineSegment != null &&
        game.asteroids.any((e) => e.isOrbiting)) {
      final firstAsteroids = game.asteroids.firstWhere((e) => e.isOrbiting);

      final position =
          game.camera.localToGlobal(firstAsteroids.body.worldCenter);
      final positionDelta = position - previousPosition;

      if (game.lineSegment! != Vector2.zero()) {
        final rayDirection = (game.lineSegment! - position).normalized();
        final movementAlongRay = positionDelta.dot(rayDirection);
        animationOffset -= movementAlongRay;
      }

      animationOffset += animationSpeed * dt;

      previousPosition = position.clone();
    }
  }
}
