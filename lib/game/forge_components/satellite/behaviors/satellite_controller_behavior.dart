import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/particles.dart' as parts;
import 'package:flame_behaviors/flame_behaviors.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flame_jam_2025/game/forge_components/satellite/satellite_component.dart';
import 'package:flame_jam_2025/game/sateflies_game.dart';
import 'package:flutter/material.dart';

class SatelliteControllerBehavior extends Behavior<SatelliteComponent>
    with HasGameReference<SatefliesGame>, ContactCallbacks {
  SatelliteControllerBehavior();

  void takeDamage(double damage) {
    if (!parent.isTooLate) {
      parent.currentHealth = parent.currentHealth - damage;
      if (parent.currentHealth <= 0 && parent.isAlive) {
        destroySatellite();
      }
    }
  }

  void destroySatellite() {
    parent.state = SatelliteState.destroyed;
    game.waveSatellites.remove(parent);
    _explodeSatellite(parent.polyShapes, parent.position, parent);
  }

  void _explodeSatellite(List<List<Vector2>> polyShapes, Vector2 position,
      SatelliteComponent _component) async {
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
    game.world.remove(_component);
  }
}
