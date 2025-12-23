import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flame_jam_2025/game/satellites_game.dart';

class JupiterComponent extends BodyComponent<SatellitesGame>
    with ContactCallbacks {
  JupiterComponent({
    super.priority,
  });

  late ui.Image spriteImage;

  @override
  Future<void> onLoad() {
    priority = 1;
    spriteImage = game.jupiterImage;
    final spriteComponent = SpriteComponent.fromImage(
      spriteImage,
      size: Vector2.all(22.7),
      position: game.jupiterPosition,
      anchor: Anchor.center,
      priority: 1,
    );
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

    // final circle = CircleShape(
    //   position: game.jupiterPosition,
    //   radius: game.jupiterSize,
    // );

    // body.createFixtureFromShape(circle);
    body.synchronizeFixtures();

    return body;
  }
}
