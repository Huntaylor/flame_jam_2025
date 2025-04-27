import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/particles.dart' as parts;
import 'package:flame_behaviors/flame_behaviors.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flame_jam_2025/game/forge_components/asteroids/asteroid_component.dart';
import 'package:flame_jam_2025/game/forge_components/upgrades/upgrade_component.dart';
import 'package:flame_jam_2025/game/managers/asteroid_spawn_manager.dart';
import 'package:flame_jam_2025/game/sateflies_game.dart';
import 'package:logging/logging.dart';

class AsteroidControllerBehavior extends Behavior<AsteroidComponent>
    with HasGameReference<SatefliesGame>, ContactCallbacks {
  AsteroidControllerBehavior();
  static final Logger _log = Logger('Asteroid Controller Behavior');
  final rnd = Random();

  late Timer deathTimer;

  late AsteroidSpawnManager spawnManager;

  @override
  FutureOr<void> onLoad() {
    spawnManager = game.asteroidSpawnManager;
    deathTimer = Timer(
      3,
      onTick: () => game.world.remove(parent),
      autoStart: false,
      repeat: false,
    );
    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (!game.camera.visibleWorldRect.containsPoint(parent.position) &&
        parent.isFiring &&
        !deathTimer.isRunning()) {
      deathTimer.start();
    }

    if (deathTimer.isRunning()) {
      if (parent.isWithinOrbit) {
        deathTimer.stop();
        deathTimer.reset();
      }
      deathTimer.update(dt);
    }
    super.update(dt);
  }

  void gainedSpeedUpgrade() {
    final speedScale = spawnManager.speedScaling;
    (speedScale > spawnManager.maxSpeed)
        ? spawnManager.speedScaling = spawnManager.maxSpeed
        : spawnManager.speedScaling = spawnManager.speedScaling + 2;
    _log.info('Speed Scaling: ${spawnManager.speedScaling}');
  }

  void gainedSizeUpgrade() {
    final newScaling = spawnManager.sizeScaling;
    (newScaling > spawnManager.maxSize)
        ? spawnManager.sizeScaling = spawnManager.maxSize
        : spawnManager.sizeScaling = spawnManager.sizeScaling + .02;
    _log.info('Size Scaling: ${spawnManager.sizeScaling}');
  }

  void gainedDamageUpgrade() {
    final damageScale = spawnManager.damageScaling;
    (damageScale > spawnManager.maxDamage)
        ? spawnManager.damageScaling = game.xHeavyDamage
        : spawnManager.damageScaling = spawnManager.damageScaling + 5;
    _log.info('Damage Scaling: ${spawnManager.damageScaling}');
  }

  void gainedCountUpgrade() {
    spawnManager.asterCountUpgrade = spawnManager.asterCountUpgrade + 2;
  }

  void gainedUpgrade(UpgradeType type) {
    switch (type) {
      case UpgradeType.speed:
        gainedSpeedUpgrade();

      case UpgradeType.size:
        gainedSizeUpgrade();

      case UpgradeType.damage:
        gainedDamageUpgrade();

      case UpgradeType.quantity:
        gainedCountUpgrade();
    }
  }

  void explodeAsteroid(Vector2 position, AsteroidComponent _component) async {
    final explosionParticle = ParticleSystemComponent(
      position: game.camera.localToGlobal(position),
      anchor: Anchor.center,
      particle: parts.Particle.generate(
        count: rnd.nextInt(10) + 5,
        generator: (i) => parts.AcceleratedParticle(
          lifespan: 1.5,
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
                      _component.currentColor,
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
    game.add(explosionParticle);
    game.world.remove(_component);
  }
}
