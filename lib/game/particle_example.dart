library;

import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const GameApp());
}

class GameApp extends StatefulWidget {
  const GameApp({super.key});

  @override
  State<GameApp> createState() => _GameAppState();
}

class _GameAppState extends State<GameApp> {
  late final FlameFire game;

  @override
  void initState() {
    super.initState();
    game = FlameFire();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.red, Colors.amber],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: FittedBox(
                  child: SizedBox(
                    width: 576,
                    height: 832,
                    child: Stack(
                      children: [
                        GameWidget(game: game),
                        const Align(
                          alignment: Alignment.topCenter,
                          child: Text('Tap in the white box to move the flame'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

const double particleLayerRadius1 = 30;
const double particleLayerRadius3 = 22;

const int particleLayerPriority1 = 1;
const int particleLayerPriority2 = 2;
const int particleLayerPriority3 = 3;

const Color lerpColor1 = Colors.red;
const Color lerpColor2 = Colors.amber;

Color particleLayerColor1 = Colors.deepOrange[600]!;

class FlameFire extends FlameGame
    with HasCollisionDetection, KeyboardEvents, TapDetector {
  FlameFire()
      : super(
          camera: CameraComponent.withFixedResolution(width: 576, height: 832),
        );

  double get width => size.x;
  double get height => size.y;
  double nextDouble = 0;
  final random = Random();

  late Player player;

  @override
  FutureOr<void> onLoad() async {
    super.onLoad();
    camera.viewfinder.anchor = Anchor.topLeft;
    player = Player(
      position: Vector2(
        camera.visibleWorldRect.width / 2,
        camera.visibleWorldRect.height / 2,
      ),
    );
    world.add(player);
  }

  @override
  void onTapDown(TapDownInfo info) {
    player.movePlayer(info.eventPosition.widget);
    super.onTapDown(info);
  }

  @override
  void update(double dt) {
    nextDouble = random.nextDouble() * 55 - 30;
    super.update(dt);
  }

  @override
  Color backgroundColor() => Colors.white;
}

class Player extends CircleComponent with HasGameReference<FlameFire> {
  Player({super.position, super.priority = 3, super.anchor = Anchor.center})
      : super();

  double fixedDeltaTime = 1 / 60;
  double accumulatedTime = 0;
  MoveToEffect? moveToEffect;
  bool isMoving = false;
  bool canCheckMoving = false;

  late Vector2 nextPosition;

  @override
  Future<void> onLoad() {
    nextPosition = position;
    debugColor = Colors.greenAccent;
    createShape();
    return super.onLoad();
  }

  @override
  void update(double dt) {
    accumulatedTime += dt;

    while (accumulatedTime >= fixedDeltaTime) {
      if (canCheckMoving) {
        isMoving = checkPosition(position);
        if (!isMoving) {
          canCheckMoving = isMoving;
        }
      }
      loadParticles();
      accumulatedTime -= fixedDeltaTime;
    }
    super.update(dt);
  }

  bool checkPosition(Vector2 currentPosition) {
    double xRounded = currentPosition.x.roundToDouble();
    double yRounded = currentPosition.y.roundToDouble();
    double xNextRounded = nextPosition.x.roundToDouble();
    double yNextRounded = nextPosition.y.roundToDouble();

    if (xRounded == xNextRounded && yNextRounded == (yRounded + 1)) {
      yRounded = yRounded + 1;
    }

    return Vector2(xRounded, yRounded) != Vector2(xNextRounded, yNextRounded);
  }

  void movePlayer(Vector2 newPosition) {
    canCheckMoving = true;
    nextPosition = newPosition;

    if (position == newPosition) {
      return;
    }

    MoveToEffect effect;
    if (moveToEffect != null) {
      if (!moveToEffect!.controller.completed) {
        remove(moveToEffect!);
        effect = getMoveEffect(newPosition);
        moveToEffect = effect;
        add(moveToEffect!);
        return;
      }
    }
    effect = getMoveEffect(newPosition);

    moveToEffect = effect;
    add(moveToEffect!);
  }

  void createShape() {
    paint = Paint()..color = particleLayerColor1;
    radius = particleLayerRadius1;
    addAll([
      CircleComponent(
        priority: particleLayerPriority2,
        position: Vector2(size.x / 2, size.y / 2),
        anchor: Anchor.center,
        paint: Paint()..color = lerpColor1,
        radius: particleLayerRadius3,
      ),
    ]);
  }

  void loadParticles() {
    final firstParticle = getParticle(
      radius: particleLayerRadius1,
      particleColor: Paint()..color = particleLayerColor1,
    );
    final secondParticle = getParticle(
      radius: particleLayerRadius3,
      particleColor: Paint()..color = lerpColor1,
    );

    Vector2 speed = getConsistentSpeed();

    final firstParticleComponent = getOuterParticleSystem(
      speed: speed,
      fireParticle: firstParticle,
    );

    final secondParticleComponent = getParticleSystem(
      speed: speed,
      fireParticle: secondParticle,
    );

    game.world.addAll([
      firstParticleComponent..priority = particleLayerPriority1,
      secondParticleComponent..priority = particleLayerPriority3,
    ]);
  }

  ParticleSystemComponent getParticleSystem({
    required Vector2 speed,
    required CircleParticle fireParticle,
  }) {
    return ParticleSystemComponent(
      position: position.clone(),
      anchor: Anchor.center,
      particle: Particle.generate(
        count: 1,
        lifespan: .65,
        generator: (i) => AcceleratedParticle(
          speed: speed,
          child: ScalingParticle(
            child: ComputedParticle(
              renderer: (canvas, particle) {
                canvas.drawCircle(
                  Offset.zero,
                  fireParticle.radius,
                  Paint()
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
      ),
    );
  }

  ParticleSystemComponent getOuterParticleSystem({
    required Vector2 speed,
    required CircleParticle fireParticle,
  }) {
    return ParticleSystemComponent(
      position: position.clone(),
      anchor: Anchor.center,
      particle: Particle.generate(
        count: 1,
        lifespan: .65,
        generator: (i) => AcceleratedParticle(
          speed: speed,
          child: ScalingParticle(
            child: ComputedParticle(
              renderer: (canvas, particle) {
                canvas.drawCircle(
                  Offset.zero,
                  fireParticle.radius,
                  Paint()
                    ..color = Color.lerp(
                      particleLayerColor1,
                      lerpColor1,
                      particle.progress,
                    )!,
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  MoveToEffect getMoveEffect(Vector2 newPosition) {
    return MoveToEffect(newPosition, EffectController(speed: 700));
  }

  final rnd = Random();

  CircleParticle getParticle({
    required Paint particleColor,
    required double radius,
  }) {
    return CircleParticle(radius: radius, paint: particleColor);
  }

  Vector2 getConsistentSpeed() {
    double ySpeed = rnd.nextDouble() * 55 - 30;
    return Vector2(rnd.nextDouble() * 55 - 30, _getDirection(ySpeed));
  }

  double _getDirection(double speed) {
    return (isMoving) ? speed : -size.y - 50;
  }
}
