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

enum LocalUpgradeType { speed, size, damage, quantity }

class UpgradeComponent extends BodyComponent<SatellitesGame>
    with ContactCallbacks {
  static final Logger _log = Logger('Upgrade Component');
  UpgradeComponent({
    required this.type,
    super.paint,
    super.priority,
    required this.newPosition,
  });

  final rnd = Random();

  double fixedDeltaTime = 1 / 60;
  double accumulatedTime = 0;

  final LocalUpgradeType type;

  bool isCollected = false;

  final Vector2 newPosition;

  late Vector2 fireVel;

  late Timer deathTimer;

  late ui.Image damageImage;
  late ui.Image quantityImage;
  late ui.Image sizeImage;
  late ui.Image speedImage;

  final newPaint = Paint();

  late SpriteComponent spriteComponent;

  Color lerpColor1 = Colors.yellow;
  Color lerpColor2 = Colors.amber[900]!;

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
      case LocalUpgradeType.speed:
        // paint.color = Colors.yellow;
        lerpColor1 = Colors.amber[900]!;
        lerpColor2 = Colors.yellow;

        spriteImage = speedImage;

      case LocalUpgradeType.size:
        // paint.color = Colors.cyan;

        lerpColor1 = Colors.deepOrange[900]!;
        lerpColor2 = Colors.orange;
        spriteImage = sizeImage;

      case LocalUpgradeType.damage:
        // paint.color = Colors.orange;
        lerpColor1 = Colors.blue[900]!;
        lerpColor2 = Colors.cyan;

        spriteImage = damageImage;

      case LocalUpgradeType.quantity:
        // paint.color = Colors.teal;
        lerpColor1 = Colors.green[900]!;
        lerpColor2 = Colors.teal;

        spriteImage = quantityImage;
    }

    paint.color = lerpColor1;
    priority = 4;
    spriteComponent = SpriteComponent.fromImage(spriteImage,
        size: Vector2.all(2),
        position: game.earthPosition,
        priority: 5,
        anchor: Anchor.center);

    game.world.add(spriteComponent);

    return super.onLoad();
  }

  void addParticles(Vector2 _position) {
    final tailParticles = ParticleSystemComponent(
      priority: 1,
      position: _position.clone(),
      anchor: Anchor.center,
      particle: parts.AcceleratedParticle(
        lifespan: 1,
        speed: getConsistentSpeed(),
        child: parts.ScalingParticle(
          to: 0,
          child: parts.ComputedParticle(
            renderer: (canvas, particle) {
              canvas.drawCircle(
                Offset.zero,
                1.5,
                newPaint
                  ..color = Color.lerp(
                    lerpColor1,
                    lerpColor2,
                    particle.progress,
                  )!,
              );
            },
          ),
        ),
      ),
    );
    game.world.add(tailParticles);
  }

  void newParticles(Vector2 otherVelocity) {
    final celebrateParticles = ParticleSystemComponent(
      position: position,
      anchor: Anchor.center,
      particle: parts.Particle.generate(
        count: 5,
        lifespan: .25,
        generator: (i) => parts.AcceleratedParticle(
          speed: game.randomVector2() / 4,
          child: parts.ScalingParticle(
            to: 0,
            child: parts.CircleParticle(
              paint: paint,
              radius: 1.5,
            ),
          ),
        ),
      ),
    );
    game.world.add(celebrateParticles);
  }

  // Vector2 getSpeed(Vector2 otherVelocity, int i) {
  //   double xSpeed = otherVelocity.x + (i * (rnd.nextDouble() - 5));
  //   double ySpeed = otherVelocity.y + (i - (rnd.nextDouble() + 5));
  //   return Vector2(xSpeed, ySpeed);
  // }

  @override
  void beginContact(Object other, Contact contact) {
    if (other is AsteroidComponent && other.isFiring && !isCollected) {
      game.audioComponent.onPowerUp();
      isCollected = true;
      newParticles(other.body.linearVelocity);
      // other.controllerBehavior.gainedUpgrade(type);

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
    accumulatedTime += dt;

    while (accumulatedTime >= fixedDeltaTime) {
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
      accumulatedTime -= fixedDeltaTime;
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
    final fixtureDef = FixtureDef(
      CircleShape(radius: 1.5),
      isSensor: true,
    );
    body.createFixture(fixtureDef);

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

  Vector2 getConsistentSpeed() {
    double ySpeed = rnd.nextDouble() * (6 + body.linearVelocity.y);
    double xSpeed = rnd.nextDouble() * (10 - body.linearVelocity.x);
    return Vector2(
      xSpeed,
      ySpeed,
    );
  }
}
