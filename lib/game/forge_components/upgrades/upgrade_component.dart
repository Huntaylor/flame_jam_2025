import 'dart:math';
import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/particles.dart' as parts;
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flame_jam_2025/game/forge_components/asteroids/asteroid_component.dart';
import 'package:flame_jam_2025/game/satellites_game.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

enum UpgradeType { speed, size, damage, quantity }

class UpgradeComponent extends BodyComponent<SatellitesGame>
    with ContactCallbacks {
  static final Logger _log = Logger('Upgrade Component');
  UpgradeComponent({
    required this.type,
    super.paint,
    required this.newPosition,
  });

  final UpgradeType type;

  bool isCollected = false;

  final Vector2 newPosition;

  late Vector2 fireVel;

  late Timer deathTimer;

  // late TextComponent typeNameComponent;
  // late String text;

  final newPaint = Paint();

  final particleShape = [
    Vector2(0, .1),
    Vector2(-.1, -.1),
    Vector2(-.1, .1),
  ];

  final starShape = [
    [
      Vector2(0, 1) * 2,
      Vector2(-0.5, 0) * 2,
      Vector2(0.5, 0) * 2,
    ],
    [
      Vector2(-0.5, 0) * 2,
      Vector2(0, -1) * 2,
      Vector2(0.5, 0) * 2,
    ],
    [
      Vector2(-1, 0) * 2,
      Vector2(0, 0.5) * 2,
      Vector2(0, -0.5) * 2,
    ],
    [
      Vector2(1, 0) * 2,
      Vector2(0, 0.5) * 2,
      Vector2(0, -0.5) * 2,
    ],
  ];

  late ui.Image damageImage;
  late ui.Image quantityImage;
  late ui.Image sizeImage;
  late ui.Image speedImage;

  late SpriteComponent spriteComponent;

  @override
  Future<void> onLoad() async {
    ui.Image spriteImage;
    damageImage = await game.images.load('damage.png');
    quantityImage = await game.images.load('quantity.png');
    sizeImage = await game.images.load('size_increase.png');
    speedImage = await game.images.load('speed_up_sprite.png');

    deathTimer = Timer(
      3,
      onTick: () => game.world.remove(this),
      autoStart: false,
      repeat: false,
    );
    switch (type) {
      case UpgradeType.speed:
        paint.color = Colors.yellow;
        // text = 'Speed';
        spriteImage = speedImage;
      case UpgradeType.size:
        paint.color = Colors.cyan;
        // text = 'Size';
        spriteImage = sizeImage;
      case UpgradeType.damage:
        paint.color = Colors.orange;
        // text = 'Damage';
        spriteImage = damageImage;
      case UpgradeType.quantity:
        paint.color = Colors.teal;
        // text = 'Quantity';
        spriteImage = quantityImage;
    }

    spriteComponent = SpriteComponent.fromImage(spriteImage,
        size: Vector2.all(2),
        position: game.earthPosition,
        priority: 5,
        anchor: Anchor.center);

    game.world.add(spriteComponent);

    newPaint.color = paint.color;

    return super.onLoad();
  }

  addParticles(Vector2 _position) {
    final shrinkingParticle = ParticleSystemComponent(
      position: _position.clone(),
      anchor: Anchor.center,
      particle: parts.ScalingParticle(
        to: 0,
        lifespan: 1,
        child: parts.ComponentParticle(
          component: PolygonComponent(particleShape)..setColor(newPaint.color),
        ),
      ),
    );
    game.world.add(shrinkingParticle);
  }

  void newParticles() {
    List<ParticleSystemComponent> particles = [];
    for (var star in starShape) {
      final celebrateParticles = ParticleSystemComponent(
        position: position,
        anchor: Anchor.center,
        particle: parts.AcceleratedParticle(
          lifespan: .5,
          speed: game.randomVector2() / 5,
          child: parts.RotatingParticle(
            to: pi,
            child: parts.ScalingParticle(
              to: 0,
              child: parts.ComponentParticle(
                component: PolygonComponent(star)
                  ..setColor(newPaint.color)
                  ..debugMode = true,
              ),
            ),
          ),
        ),
      );
      particles.add(celebrateParticles);
    }
    game.world.addAll(particles);
  }

  @override
  void beginContact(Object other, Contact contact) {
    if (other is AsteroidComponent && other.isFiring && !isCollected) {
      game.audioComponent.onPowerUp();
      isCollected = true;
      newParticles();
      other.controllerBehavior.gainedUpgrade(type);

      try {
        if (parent != null && parent!.isMounted) {
          game.world.remove(this);
        }
      } catch (e) {
        _log.severe('Error removing component', e);
      }
    }
    super.beginContact(other, contact);
  }

  @override
  void onRemove() {
    if (game.waveManager.currentUpgrades.contains(this)) {
      game.waveManager.currentUpgrades.remove(this);
    }
    game.world.remove(spriteComponent);
    super.onRemove();
  }

  @override
  void update(double dt) {
    spriteComponent.position = position;
    if (!isCollected) {
      addParticles(position);
      if (body.linearVelocity != fireVel) {
        body.linearVelocity = fireVel;
      }
    }

    if (!game.camera.visibleWorldRect.containsPoint(position) &&
        !deathTimer.isRunning()) {
      deathTimer.start();
    } else if (deathTimer.isRunning()) {
      deathTimer.update(dt);
    }
    if (!isCollected) {
      body.setTransform(position, angle + .015);
    }
    super.update(dt);
  }

  @override
  Body createBody() {
    final def = BodyDef(
      userData: this,
      isAwake: true,
      type: BodyType.dynamic,
      position: newPosition,
    );

    final body = world.createBody(def)..userData = this;
    for (var shape in starShape) {
      final fixtureDef = FixtureDef(
        PolygonShape()..set(shape),
        isSensor: true,
      );
      body.createFixture(fixtureDef);
    }

    final corner = Vector2(game.camera.visibleWorldRect.size.width, 10);

    var speed = 15;
    var velocityX = corner.x - body.position.x;

    var velocityY = corner.y - body.position.y;
    var length = sqrt(velocityX * velocityX + velocityY * velocityY);

    velocityX *= speed / length;

    velocityY *= speed / length;

    fireVel = Vector2(velocityX, velocityY);
    body.linearVelocity = fireVel;

    return body;
  }
}
