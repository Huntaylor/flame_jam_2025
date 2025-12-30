import 'dart:math';
import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flame/particles.dart' as parts;
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flame_jam_2025/game/blocs/game/game_bloc.dart';
import 'package:flame_jam_2025/game/blocs/wave/wave_bloc.dart';
import 'package:flame_jam_2025/game/forge_components/asteroids/asteroid_component.dart';
import 'package:flame_jam_2025/game/satellites_game.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

class EarthComponent extends BodyComponent<SatellitesGame>
    with ContactCallbacks {
  static final Logger _log = Logger('Earth Component');
  EarthComponent({super.priority})
      : super(paint: Paint()..color = Colors.lightBlue);

  final rnd = Random();

  final healthBarPaint = Paint();

  final double totalHealth = 10000;

  double currentHealth = 0;

  final double healthBarWidth = 5;
  final double healthBarHeight = 1;
  Vector2 healthBarPosition = Vector2(0, 0);

  List<AsteroidComponent> damageDealtByList = [];

  late ui.Image spriteImage;

  late SpriteComponent spriteComponent;

  @override
  Future<void> onLoad() async {
    spriteImage = await game.images.load('planet03.png');
    spriteComponent = SpriteComponent.fromImage(spriteImage,
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
    if (other is AsteroidComponent && other.canDamageEarth) {
      game.waveBloc.add(EarthWarStarted());
      if (!damageDealtByList.contains(other)) {
        currentHealth = currentHealth - other.currentDamage;
        if (currentHealth <= 0) {
          game.gameBloc.add(GameWon());

          currentHealth = 0;
          explodeEarth();
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
    if (game.waveBloc.state.isAtWar) {
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

  void explodeEarth() {
    game.waveBloc.add(EarthWarEnded());
    game.audioComponent.onAsteroidDestoryed();
    final explosionParticle = ParticleSystemComponent(
      position: game.camera.localToGlobal(position),
      anchor: Anchor.center,
      particle: parts.Particle.generate(
        count: 15,
        generator: (i) => parts.AcceleratedParticle(
          lifespan: 2,
          speed: game.randomVector2(),
          child: parts.ScalingParticle(
            to: 0,
            child: parts.ComputedParticle(
              renderer: (canvas, particle) {
                canvas.drawCircle(
                  Offset.zero,
                  5,
                  Paint()
                    ..color = Color.lerp(
                      Colors.lightBlue,
                      const Color.fromARGB(255, 255, 0, 0),
                      particle.progress,
                    )!,
                );
              },
            ),
          ),
        ),
      ),
    );
    remove(spriteComponent);
    game.add(explosionParticle);
    try {
      if (parent != null && parent!.isMounted) {
        game.world.remove(this);
      }
    } catch (e) {
      _log.severe('Error removing component', e);
    }
  }
}
