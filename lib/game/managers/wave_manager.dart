import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame_jam_2025/game/forge_components/satellite_component.dart';
import 'package:flame_jam_2025/game/pesky_satellites.dart';

class WaveManager extends Component with HasGameReference<PeskySatellites> {
  WaveManager({
    required this.waveNumber,
    required this.impulseTargets,
  });

  final List<Vector2> impulseTargets;
  final int waveNumber;

  int? satellitePowerLevel;

  late SatelliteComponent easySatellite;

  late SatelliteComponent mediumSatellite;

  late SatelliteComponent hardSatellite;

  late SatelliteComponent bossSatellite;

  List<SatelliteComponent> difficultyList = [];

  List<SatelliteComponent> waveEnemies = [];
  List<SatelliteComponent> pendingSpawn = [];

  final rnd = Random();

  late Timer spawnTimer;

  @override
  FutureOr<void> onLoad() {
    spawnTimer = Timer(1, onTick: () => spawnSatellites(), repeat: true);
    spawnTimer.start();
    easySatellite = SatelliteComponent(difficulty: SatelliteDifficulty.easy);
    mediumSatellite =
        SatelliteComponent(difficulty: SatelliteDifficulty.medium);
    hardSatellite = SatelliteComponent(difficulty: SatelliteDifficulty.hard);
    bossSatellite = SatelliteComponent(difficulty: SatelliteDifficulty.boss);
    difficultyList.addAll([
      easySatellite,
      mediumSatellite,
      hardSatellite,
      bossSatellite,
    ]);

    generateWave();

    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (spawnTimer.isRunning()) {
      spawnTimer.update(dt);
    }
    super.update(dt);
  }

  void onWaveComplete() {
    ++game.waveNumber;
  }

  int getPowerForWave() {
    return (10 + waveNumber * 5); // Scale as needed
  }

  //Only spawning 4 because the list I have only has 4 within the list, duh
  //Need to set this up to generate the list, based on the enemy chance
  List<SatelliteComponent> getWeightedEnemyPool() {
    // Increase difficulty by making tougher enemies more likely
    double difficultyFactor = waveNumber * 0.05;
    List<SatelliteComponent> newList = [];
    for (var satellite in difficultyList) {
      double adjustedChance =
          (satellite.spawnChance! + (satellite.powerLevel! * difficultyFactor))
              .clamp(0.0, 1.0);
      int weight = (adjustedChance * 100).toInt();

      newList.add(satellite..spawnChance = weight.toDouble());
    }

    return newList;
  }

  void generateWave() {
    int wavePower = getPowerForWave();

    List<SatelliteComponent> weightedPool = getWeightedEnemyPool();

    int currentPower = 0;

    while (currentPower < wavePower && weightedPool.isNotEmpty) {
      SatelliteComponent satelliteComponent = (weightedPool..shuffle()).first;
      if (currentPower + satelliteComponent.powerLevel! <= wavePower) {
        satelliteComponent.setImpulseTarget =
            impulseTargets[rnd.nextInt((impulseTargets.length - 1))];
        waveEnemies.add(satelliteComponent);
        currentPower += satelliteComponent.powerLevel!.toInt();
      } else {
        // Prevent infinite loop if remaining power is too small
        weightedPool
            .removeWhere((e) => e.powerLevel! > (wavePower - currentPower));
      }
    }
    pendingSpawn = waveEnemies;
  }

  void spawnSatellites() {
    if (pendingSpawn.isNotEmpty) {
      SatelliteComponent? currentSatellite = pendingSpawn.first;
      game.world.add(currentSatellite);
      pendingSpawn.removeWhere((e) => currentSatellite == e);
    } else {
      spawnTimer.stop();
    }
  }
}
