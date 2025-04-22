import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame_jam_2025/game/pesky_satellites.dart';

class AsteroidAngleComponent extends RectangleComponent
    with HasGameReference<PeskySatellites> {
  AsteroidAngleComponent({super.anchor, super.angle})
      : super(size: Vector2(2, 1));

  final _upVector = Vector2(0, -1);

  @override
  FutureOr<void> onLoad() {
    position = game.firingPosition;

    return super.onLoad();
  }

  @override
  void update(double dt) {
    _getAngle();
    // _getMovement(fixedDeltaTime);
    super.update(dt);
  }

  void _getAngle() {
    // DevKage used this calculation in one of his games, how does it work?
    final dir = game.targetPosition - position;
    angle = (-dir.angleToSigned(_upVector)) * scale.x.sign - (pi * 0.5);
  }
}
