import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flame_jam_2025/game/forge_components/asteroid_component.dart';
import 'package:flame_jam_2025/game/pesky_satellites.dart';
import 'package:flutter/material.dart';

class JupiterGravityRepellentComponent extends BodyComponent<PeskySatellites>
    with ContactCallbacks {
  JupiterGravityRepellentComponent({super.priority})
    : super(
        paint:
            Paint()
              ..color = Colors.red
              ..strokeWidth = 0.5
              ..style = PaintingStyle.stroke,
      );

  List<AsteroidComponent> asteroids = [];

  @override
  void beginContact(Object other, Contact contact) {
    if (other is AsteroidComponent) {
      other.isOrbiting = false;
      asteroids.add(other);
    }
    super.beginContact(other, contact);
  }

  @override
  void endContact(Object other, Contact contact) {
    if (other is AsteroidComponent) {
      if (asteroids.isNotEmpty) {
        other.isOrbiting = true;
        final asteroidBody = asteroids.firstWhere(
          (i) => i.body == contact.getOtherBody(body),
        );

        asteroids.remove(asteroidBody);
      }
      super.endContact(other, contact);
    }
  }

  @override
  void update(double dt) {
    if (asteroids.isNotEmpty) {
      for (var asteroid in asteroids) {
        if (!asteroid.isOrbiting!) {
          final jupiterPosition = game.jupiterPosition.clone();

          Vector2 gravityDirection =
              jupiterPosition..sub(asteroid.body.worldCenter);

          final distance = asteroid.body.worldCenter.distanceTo(
            jupiterPosition,
          );
          final clamDis = distance.clamp(55, 70);
          gravityDirection.scaleTo(clamDis * .00089);

          asteroid.body.applyLinearImpulse(
            gravityDirection.inverted(),
            point: asteroid.body.worldCenter,
          );
        }
      }
    }

    super.update(dt);
  }

  // final _paintLine = Paint();

  // @override
  // void render(Canvas canvas) {
  //   canvas.drawLine(
  //     game.earthPosition.toOffset(),
  //     game.jupiterPosition.toOffset(),
  //     _paintLine
  //       ..style = PaintingStyle.fill
  //       ..color = Colors.red,
  //   );
  //   super.render(canvas);
  // }

  @override
  Body createBody() {
    final bodyDef = BodyDef(position: Vector2.zero());
    final body = world.createBody(bodyDef)..userData = this;
    final circle = CircleShape(
      position: game.jupiterPosition,
      radius: game.jupiterSize * 1.5,
    );

    final fixtureDef = FixtureDef(circle, isSensor: true);
    body.createFixture(fixtureDef);
    body.synchronizeFixtures();

    return body;
  }
}
