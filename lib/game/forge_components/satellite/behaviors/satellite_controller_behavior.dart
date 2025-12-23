import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/particles.dart' as parts;
import 'package:flame_behaviors/flame_behaviors.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flame_jam_2025/game/forge_components/satellite/behaviors/satellite_shapes.dart';
import 'package:flame_jam_2025/game/forge_components/satellite/satellite_component.dart';
import 'package:flame_jam_2025/game/satellites_game.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

class SatelliteControllerBehavior extends Behavior<SatelliteComponent>
    with HasGameReference<SatellitesGame>, ContactCallbacks {
  static final Logger _log = Logger('Satellite Controller Behavior');
  SatelliteControllerBehavior();

  late Timer deathTimer;

  @override
  FutureOr<void> onLoad() {
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
        !parent.isTooLate) {
      destroySatellite(false);
    }
    if (deathTimer.isRunning()) {
      deathTimer.update(dt);
    }
    super.update(dt);
  }

  void takeDamage(double damage) {
    if (!parent.isTooLate) {
      parent.currentHealth = parent.currentHealth - damage;

      if (parent.currentHealth <= 0 && parent.isAlive) {
        if (parent.currentHealth < 0) {
          parent.currentHealth = 0;
        }
        destroySatellite(true);
      }
    }
  }

  void destroySatellite(bool byPlayer) {
    if (byPlayer && !game.destroyedSatellites.contains(parent)) {
      game.destroyedSatellites.add(parent);
    }
    parent.state = SatelliteState.destroyed;
    if (game.waveManager.contains(parent)) {
      game.waveSatellites.remove(parent);
    }
    if (game.orbitingSatellites.contains(parent)) {
      game.orbitingSatellites.remove(parent);
    }
    switch (parent.difficulty) {
      case SatelliteDifficulty.boss:
        _explodeSatellite(bossSatellite, parent.position, parent);
      case SatelliteDifficulty.easy:
        _explodeSatellite(smallerSatellite, parent.position, parent);
      case SatelliteDifficulty.medium:
        _explodeSatellite(mediumSatellite, parent.position, parent);
      case SatelliteDifficulty.hard:
        _explodeSatellite(hardSatellite, parent.position, parent);
      case SatelliteDifficulty.fast:
        _explodeSatellite(fastSatellite, parent.position, parent);
    }
    _explodeSatellite(smallerSatellite, parent.position, parent);
  }

  void _explodeSatellite(List<List<Vector2>> polyShapes, Vector2 position,
      SatelliteComponent _component) {
    game.audioComponent.onSatelliteDestoryed();
    List<ParticleSystemComponent> particles = [];
    for (var shape in polyShapes) {
      List<Vector2> scaleList = [];
      for (var vector in shape) {
        scaleList.add(vector * 15);
      }
      final explosionParticle = ParticleSystemComponent(
        position: game.camera.localToGlobal(position),
        anchor: Anchor.center,
        particle: parts.AcceleratedParticle(
          lifespan: 1.5,
          speed: game.randomVector2(),
          child: parts.RotatingParticle(
            to: pi,
            child: parts.ScalingParticle(
              to: 0,
              child: parts.ComponentParticle(
                component: PolygonComponent(scaleList)..setColor(Colors.red),
              ),
            ),
          ),
        ),
      );
      particles.add(explosionParticle);
    }
    game.addAll(particles);
    try {
      if (_component.parent != null && _component.parent!.isMounted) {
        game.world.remove(_component);
      }
    } catch (e) {
      _log.severe('Error removing component', e);
    }
  }
}
