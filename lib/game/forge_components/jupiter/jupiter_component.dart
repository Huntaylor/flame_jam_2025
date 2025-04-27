import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flame_jam_2025/game/satellites_game.dart';

class JupiterComponent extends BodyComponent<SatellitesGame>
    with ContactCallbacks {
  JupiterComponent({super.priority});

  late Image spriteImage;

  @override
  Future<void> onLoad() async {
    priority = 0;
    spriteImage = await game.images.load('planet08.png');
    final spriteComponent = SpriteComponent.fromImage(spriteImage,
        size: Vector2.all(22.7),
        position: game.jupiterPosition,
        anchor: Anchor.center);
    add(spriteComponent);
    return super.onLoad();
  }

  @override
  Body createBody() {
    final def = BodyDef(
      isAwake: true,
      type: BodyType.static,
      position: Vector2.zero(),
    );
    final body = world.createBody(def)..userData = this;

    final circle = CircleShape(
      position: game.jupiterPosition,
      radius: game.jupiterSize,
    );

    body.createFixtureFromShape(circle);
    body.synchronizeFixtures();

    return body;
  }

  // @override
  // void update(double dt) {
  //   if (body.position != Vector2.zero()) {
  //     body.position == Vector2.zero();
  //   }
  //   super.update(dt);
  // }

  // @override
  // void beginContact(Object other, Contact contact) {
  //   if (other is! JupiterComponent) {
  //     final newBody = contact.getOtherBody(body);
  //     newBody.applyLinearImpulse(Vector2.all(-10));
  //   }
  //   super.beginContact(other, contact);
  // }
}
