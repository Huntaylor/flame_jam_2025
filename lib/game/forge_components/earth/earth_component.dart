import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flame_jam_2025/game/forge_components/asteroids/asteroid_component.dart';
import 'package:flame_jam_2025/game/satellites_game.dart';
import 'package:flutter/material.dart';

enum EarthState { peaceful, war, destroyed }

class EarthComponent extends BodyComponent<SatellitesGame>
    with ContactCallbacks {
  EarthComponent({super.priority})
      : super(paint: Paint()..color = Colors.lightBlue);

  EarthState? _earthState;

  bool get isPeaceful => state == EarthState.peaceful;
  bool get isAtWar => state == EarthState.war;
  bool get isDestroyed => state == EarthState.destroyed;

  EarthState get state => _earthState ?? EarthState.peaceful;

  set state(EarthState state) {
    _earthState = state;
  }

  final healthBarPaint = Paint();

  final double totalHealth = 2500;

  double currentHealth = 0;

  final double healthBarWidth = 5;
  final double healthBarHeight = 1;
  Vector2 healthBarPosition = Vector2(0, 0);

  List<AsteroidComponent> damageDealtByList = [];

  late ui.Image spriteImage;

  @override
  Future<void> onLoad() async {
    spriteImage = await game.images.load('planet03.png');
    final spriteComponent = SpriteComponent.fromImage(spriteImage,
        size: Vector2.all(2.5),
        position: game.earthPosition,
        anchor: Anchor.center);
    add(spriteComponent);
    healthBarPosition.setFrom(game.earthPosition.clone());
    healthBarPosition.x = healthBarPosition.x - (healthBarWidth / 2);
    healthBarPosition.y = healthBarPosition.y - (healthBarWidth / 2);

    currentHealth = totalHealth;
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
      position: game.earthPosition,
      radius: game.earthSize,
    );

    final fixtureDef = FixtureDef(circle, isSensor: true);

    body.createFixture(fixtureDef);
    body.synchronizeFixtures();

    return body;
  }

  @override
  void beginContact(Object other, Contact contact) {
    if (other is AsteroidComponent && other.isFiring) {
      state = EarthState.war;
      if (!damageDealtByList.contains(other)) {
        currentHealth = currentHealth - other.currentDamage;
        if (currentHealth >= 0) {
          currentHealth = 0;
          state = EarthState.destroyed;
        }
        damageDealtByList.add(other);
      }
    }
    super.beginContact(other, contact);
  }

  @override
  void endContact(Object other, Contact contact) {
    if (other is AsteroidComponent && other.isFiring) {
      if (damageDealtByList.contains(other)) {
        damageDealtByList.remove(other);
      }
    }
    super.endContact(other, contact);
  }

  @override
  void render(Canvas canvas) {
    if (isAtWar) {
      canvas.save();
      healthBarPaint.color = Colors.white;
      canvas.drawRect(
          Rect.fromLTWH(healthBarPosition.x, healthBarPosition.y,
              healthBarWidth, healthBarHeight),
          healthBarPaint);

      healthBarPaint.color = Colors.red[900]!;
      double currentHealthWidth =
          healthBarWidth * (currentHealth / totalHealth);
      canvas.drawRect(
          Rect.fromLTWH(healthBarPosition.x, healthBarPosition.y,
              currentHealthWidth, healthBarHeight),
          healthBarPaint);
      canvas.restore();
    }

    super.render(canvas);
  }
}
