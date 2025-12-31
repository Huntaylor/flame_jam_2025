import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/particles.dart' as parts;
import 'package:flame_behaviors/flame_behaviors.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flame_jam_2025/game/forge_components/asteroids/asteroid_component.dart';
import 'package:flame_jam_2025/game/forge_components/upgrades/upgrade_component.dart';
import 'package:flame_jam_2025/game/managers/asteroid_spawn_manager.dart';
import 'package:flame_jam_2025/game/satellites_game.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

class AsteroidControllerBehavior extends Behavior<AsteroidComponent>
    with HasGameReference<SatellitesGame>, ContactCallbacks {
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
    if (speedScale > spawnManager.maxSpeed) {
      spawnManager.speedScaling = spawnManager.maxSpeed;
      game.waveManager.upgradeTypeList
          .removeWhere((e) => e == LocalUpgradeType.speed);
    } else {
      spawnManager.speedScaling = spawnManager.speedScaling + 2;
    }
    _log.info('Speed Scaling: ${spawnManager.speedScaling}');
  }

  void gainedSizeUpgrade() {
    final newScaling = spawnManager.sizeScaling;
    if (newScaling > spawnManager.maxSize) {
      game.waveManager.upgradeTypeList
          .removeWhere((e) => e == LocalUpgradeType.size);
      spawnManager.sizeScaling = spawnManager.maxSize;
    } else {
      spawnManager.sizeScaling = spawnManager.sizeScaling + .02;
    }
    _log.info('Size Scaling: ${spawnManager.sizeScaling}');
  }

  void gainedDamageUpgrade() {
    final damageScale = spawnManager.damageScaling;

    spawnManager.damageScaling = damageScale + 15;
    _log.info('Damage Scaling: $damageScale');
  }

  void gainedCountUpgrade() {
    if (spawnManager.asterCountUpgrade == spawnManager.maxAsteroids) {
      game.waveManager.upgradeTypeList
          .removeWhere((e) => e == LocalUpgradeType.quantity);
    } else {
      spawnManager.asterCountUpgrade = spawnManager.asterCountUpgrade + 1;
    }
    _log.info('Count Increase: ${spawnManager.asterCountUpgrade}');
  }

  // void gainedUpgrade(LocalUpgradeType type) {
  //   switch (type) {
  //     case LocalUpgradeType.speed:
  //       gainedSpeedUpgrade();

  //     case LocalUpgradeType.size:
  //       gainedSizeUpgrade();

  //     case LocalUpgradeType.damage:
  //       gainedDamageUpgrade();

  //     case LocalUpgradeType.quantity:
  //       gainedCountUpgrade();
  //   }
  // }

  void explodeAsteroid(Vector2 position, AsteroidComponent _component) {
    game.audioComponent.onAsteroidDestoryed();
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
                      Colors.brown,
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
    try {
      if (_component.parent != null && _component.parent!.isMounted) {
        game.world.remove(_component);
      }
    } catch (e) {
      _log.severe('Error removing component', e);
    }
  }
}
