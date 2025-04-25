import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/particles.dart' as parts;
import 'package:flame_behaviors/flame_behaviors.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flame_jam_2025/game/forge_components/asteroids/asteroid_component.dart';
import 'package:flame_jam_2025/game/sateflies_game.dart';

class AsteroidControllerBehavior extends Behavior<AsteroidComponent>
    with HasGameReference<SatefliesGame>, ContactCallbacks {
  AsteroidControllerBehavior();

  final rnd = Random();

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
