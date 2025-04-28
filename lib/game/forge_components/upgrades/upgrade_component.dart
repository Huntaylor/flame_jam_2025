import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/particles.dart' as parts;
import 'package:flame_audio/flame_audio.dart';
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
    required this.newPositon,
  });

  final UpgradeType type;

  bool isCollected = false;

  final Vector2 newPositon;

  late Timer deathTimer;

  late TextComponent typeNameComponent;
  late String text;

  final newPaint = Paint();

  final particleShape = [
    Vector2(0, .1),
    Vector2(-.1, -.1),
    Vector2(-.1, .1),
  ];

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
  Future<void> onLoad() {
    deathTimer = Timer(
      3,
      onTick: () => game.world.remove(this),
      autoStart: false,
      repeat: false,
    );
    switch (type) {
      case UpgradeType.speed:
        paint.color = Colors.yellow;
        text = 'Speed';

      case UpgradeType.size:
        paint.color = Colors.cyan;
        text = 'Size';
      case UpgradeType.damage:
        paint.color = Colors.orange;
        text = 'Damage';
      case UpgradeType.quantity:
        paint.color = Colors.teal;
        text = 'Quantity';
    }
    typeNameComponent = TextComponent(
        text: text, anchor: Anchor.center, scale: Vector2.all(.05));
    game.world.add(typeNameComponent);

    newPaint.color = paint.color;

    return super.onLoad();
  }

  addParticles(Vector2 _position) {
    final shrinkingParticle = ParticleSystemComponent(
      position: _position.clone(),
      anchor: Anchor.center,
      particle: parts.ScalingParticle(
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
      if (game.isPlaying) {
        FlameAudio.play('powerUp.wav', volume: 0.1);
      }
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
    game.world.remove(typeNameComponent);
    super.onRemove();
  }

  @override
  void update(double dt) {
    typeNameComponent.position = position;
    if (!isCollected) {
      addParticles(position);
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
      position: newPositon,
    );

    final body = world.createBody(def)..userData = this;
    for (var shape in starShape) {
      final fixtureDef = FixtureDef(PolygonShape()..set(shape), isSensor: true);
      body.createFixture(fixtureDef);
    }

    final corner = Vector2(game.camera.visibleWorldRect.size.width, 10);

    var speed = 8;
    var velocityX = corner.x - body.position.x;

    var velocityY = corner.y - body.position.y;
    var length = sqrt(velocityX * velocityX + velocityY * velocityY);

    velocityX *= speed / length;

    velocityY *= speed / length;

    final fireVel = Vector2(velocityX, velocityY);

    body.applyLinearImpulse(fireVel);

    return body;
  }
}
