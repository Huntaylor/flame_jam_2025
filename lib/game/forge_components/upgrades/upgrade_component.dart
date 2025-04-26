import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flame_jam_2025/game/forge_components/asteroids/asteroid_component.dart';
import 'package:flame_jam_2025/game/sateflies_game.dart';

enum UpgradeType { speed, size, damage, quantity }

class UpgradeComponent extends BodyComponent<SatefliesGame>
    with ContactCallbacks {
  UpgradeComponent({required this.type, super.paint});

  final UpgradeType type;

  final starShape = [
    [
      Vector2(0, 1),
      Vector2(-0.5, 0),
      Vector2(0.5, 0),
    ],
    [
      Vector2(-0.5, 0),
      Vector2(0, -1),
      Vector2(0.5, 0),
    ],
    [
      Vector2(-1, 0),
      Vector2(0, 0.5),
      Vector2(0, -0.5),
    ],
    [
      Vector2(1, 0),
      Vector2(0, 0.5),
      Vector2(0, -0.5),
    ],
  ];

  @override
  void beginContact(Object other, Contact contact) {
    if (other is AsteroidComponent && other.isFiring) {
      game.asteroidSpawnManager.gainedUpgrade(type);
    }
    super.beginContact(other, contact);
  }

  @override
  Body createBody() {
    final def = BodyDef(
      userData: this,
      // bullet: true,
      isAwake: true,
      type: BodyType.dynamic,
      position: position,
    );

    final body = world.createBody(def)..userData = this;
    return body;
  }
}
