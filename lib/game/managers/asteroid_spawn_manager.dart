import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame_jam_2025/game/forge_components/asteroids/asteroid_component.dart';
import 'package:flame_jam_2025/game/forge_components/upgrades/upgrade_component.dart';
import 'package:flame_jam_2025/game/sateflies_game.dart';

enum OrbitTarget { top, bottom, right }

class AsteroidSpawnManager extends Component
    with HasGameReference<SatefliesGame> {
  AsteroidSpawnManager();

  int maxAsteroids = 50;

  int currentMax = 12;
  // int currentMax = 50;

  int currentAsteroids = 0;

  int currentWave = 1;

  int asterCountUpgrade = 0;

  List<AsteroidComponent> newAsteroids = [];

  late Timer spawnTimer;
  late Timer individualTimer;

  final rnd = Random();

  bool hasCalledNew = false;

  List<Vector2> bottomTargetLocations = [
    Vector2(177.0, 76.0),
    Vector2(173.0, 75.0),
    Vector2(170.0, 75.0),
    Vector2(168.0, 78.0),
    Vector2(169.0, 80.0),
    Vector2(171.0, 82.0),
    Vector2(174.0, 79.0),
    Vector2(178.0, 77.0),
    Vector2(178.0, 81.0),
    Vector2(172.0, 78.0),
  ];

  List<Vector2> topTargetLocations = [
    Vector2(162.0, 52.0),
    Vector2(158.0, 52.0),
    Vector2(162.0, 48.0),
    Vector2(167.0, 52.0),
    Vector2(171.0, 55.0),
    Vector2(166.0, 59.0),
    Vector2(166.0, 59.0),
    Vector2(158.0, 59.0),
    Vector2(158.0, 50.0),
    Vector2(165.0, 53.0),
  ];

  List<Vector2> spawnLocations = [
    Vector2(180.0, 0.0), //Right
    Vector2(120.0, 100.0), //Bottom
    Vector2(190.0, 44.0), //Right
  ];

  @override
  FutureOr<void> onLoad() {
    spawnTimer = Timer(4,
        repeat: false, onTick: () => createNewAsteroids(), autoStart: false);
    individualTimer = Timer(.5,
        repeat: true, onTick: () => launchNewAsteroids(), autoStart: false);
    currentAsteroids = game.asteroids.length;

    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (game.asteroids.length < currentMax && !hasCalledNew) {
      hasCalledNew = false;
      needAsteroids();
    }
    if (individualTimer.isRunning()) {
      individualTimer.update(dt);
    }
    if (spawnTimer.isRunning()) {
      spawnTimer.update(dt);
    }
    super.update(dt);
  }

  void gainedUpgrade(UpgradeType type) {
    switch (type) {
      case UpgradeType.speed:
      case UpgradeType.size:
      case UpgradeType.damage:
      case UpgradeType.quantity:
    }
    asterCountUpgrade = asterCountUpgrade + 2;
  }

  void needAsteroids() {
    if (!spawnTimer.isRunning()) {
      spawnTimer.start();
    }
  }

  Vector2 impulseDirection(
      {required Vector2 orbitTargetLocation, required Vector2 spawnLocation}) {
    var speed = 15;
    var velocityX = orbitTargetLocation.x - spawnLocation.x;

    var velocityY = orbitTargetLocation.y - spawnLocation.y;
    var length = sqrt(velocityX * velocityX + velocityY * velocityY);

    velocityX *= speed / length;

    velocityY *= speed / length;

    return Vector2(velocityX, velocityY);
  }

  void launchNewAsteroids() {
    if (newAsteroids.isEmpty) {
      hasCalledNew = false;
      individualTimer.stop();
      return;
    }
    final first = newAsteroids.first;
    if (!game.asteroids.contains(first)) {
      game.asteroids.add(first);
    }
    game.world.add(first);
    newAsteroids.remove(first);
  }

  void resetAsteroidNum() {
    currentMax = currentMax + asterCountUpgrade;
    if (currentMax > maxAsteroids) {
      currentMax = maxAsteroids;
    }
  }

  void createNewAsteroids() {
    if (currentWave != game.waveManager.waveNumber) {
      currentWave = game.waveManager.waveNumber;
      resetAsteroidNum();
    }
    currentAsteroids = game.asteroids.length;
    if (currentAsteroids < currentMax) {
      final index = rnd.nextInt(3);
      final cycleLocation = spawnLocations[index];
      OrbitTarget target;
      switch (index) {
        case 0:
          target = OrbitTarget.right;
        case 1:
          target = OrbitTarget.bottom;
        case 2:
          target = OrbitTarget.bottom;
        case 3:
          target = OrbitTarget.right;
        default:
          target = OrbitTarget.bottom;
      }

      final missingAsteroids = currentMax - currentAsteroids;

      newAsteroids = List<AsteroidComponent>.generate(
        missingAsteroids,
        (index) {
          final targetList = target == OrbitTarget.bottom
              ? bottomTargetLocations
              : topTargetLocations;

          return AsteroidComponent(
            impulseDirection: impulseDirection(
              orbitTargetLocation: targetList[rnd.nextInt(9)],
              spawnLocation: cycleLocation,
            ),
            startPosition: cycleLocation,
            startingDamage: game.smallDamage,
          );
        },
      );
      if (!individualTimer.isRunning()) {
        individualTimer.start();
      }
    }
  }
}
