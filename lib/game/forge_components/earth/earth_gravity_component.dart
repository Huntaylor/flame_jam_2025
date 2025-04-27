import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flame_jam_2025/game/forge_components/satellite/satellite_component.dart';
import 'package:flame_jam_2025/game/satellites_game.dart';
import 'package:flutter/material.dart';

class EarthGravityComponent extends BodyComponent<SatellitesGame>
    with ContactCallbacks {
  EarthGravityComponent({super.priority})
      : super(
          paint: Paint()
            ..color = Colors.blue
            ..strokeWidth = 0.15
            ..style = PaintingStyle.stroke,
        );

  final double limiter = 40;

  final double damageMinimum = 250;

  @override
  void endContact(Object other, Contact contact) {
    if (other is SatelliteComponent) {
      other.isOutOfOrbit = true;
    }
    super.endContact(other, contact);
  }

  @override
  Body createBody() {
    final bodyDef = BodyDef(position: Vector2.zero());
    final body = world.createBody(bodyDef)..userData = this;
    final circle = CircleShape(
      position: game.earthPosition,
      radius: game.earthSize * 5,
    );

    final fixtureDef = FixtureDef(circle, isSensor: true);
    body.createFixture(fixtureDef);
    body.synchronizeFixtures();

    return body;
  }
}
