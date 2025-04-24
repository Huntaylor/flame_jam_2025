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

  List<SatelliteDifficulty> difficultyList = [];

  List<SatelliteComponent> enemies = [];

  List<SatelliteComponent> pendingSpawn = [];

  int index = 0;

  final rnd = Random();

  late Timer spawnTimer;

  @override
  FutureOr<void> onLoad() {
    spawnTimer = Timer(1, onTick: () => spawnSatellites(), repeat: true);
    spawnTimer.start();

    difficultyList.addAll([
      SatelliteDifficulty.easy,
      SatelliteDifficulty.medium,
      SatelliteDifficulty.hard,
      SatelliteDifficulty.boss,
    ]);

    generateWaveEnemies();

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

  int calculateTotalWavePower(int waveNumber) {
    return 10 + (waveNumber * 5) + (waveNumber * waveNumber);
  }

  Map<SatelliteDifficulty, double> getEnemyProbabilities(int waveNumber) {
    // Initialize with base probabilities
    Map<SatelliteDifficulty, double> probabilities = {};

    // Example probability calculation
    // Adjust these formulas based on your preferred difficulty curve
    for (var type in difficultyList) {
      double? probability;
      switch (type) {
        case SatelliteDifficulty.easy:
          probability = max(0.8 - (waveNumber * 0.05), 0.2);
          break;
        case SatelliteDifficulty.medium:
          probability = min(0.1 + (waveNumber * 0.03), 0.4);
          break;
        case SatelliteDifficulty.hard:
          probability = min(0.05 + (waveNumber * 0.02), 0.3);
          break;
        case SatelliteDifficulty.boss:
          probability = min(0.05 + (waveNumber * 0.01), 0.1);
          break;
      }
      probabilities[type] = probability;
    }
    // Normalize probabilities to sum to 1.0
    double total = probabilities.values.reduce((a, b) => a + b);
    probabilities.forEach((key, value) {
      probabilities[key] = value / total;
    });

    return probabilities;
  }

  // Generate enemies for the current wave
  List<SatelliteComponent> generateWaveEnemies() {
    int totalPower = calculateTotalWavePower(waveNumber);
    Map<SatelliteDifficulty, double> probabilities =
        getEnemyProbabilities(waveNumber);

    int remainingPower = totalPower;
    while (remainingPower > 0) {
      // Select enemy type using probability distribution
      SatelliteDifficulty selectedType = _selectEnemyType(probabilities, rnd);

      // Get power level for this enemy type
      int powerLevel = _getPowerLevelForType(selectedType);

      // Add enemy if it fits in remaining power budget
      if (powerLevel <= remainingPower) {
        enemies.add(createEnemy(selectedType));
        remainingPower -= powerLevel;
      } else {
        // If remaining power is too low, try to add the lowest power enemy
        SatelliteDifficulty lowestType = _getLowestPowerEnemyType();
        int lowestPower = _getPowerLevelForType(lowestType);

        if (lowestPower <= remainingPower) {
          enemies.add(createEnemy(lowestType));
        }
        break;
      }
    }
    pendingSpawn = List.from(enemies);
    print(
        'Enemies length: ${enemies.length} and Pending Spawn Length: ${pendingSpawn.length}');
    return enemies;
  }

  // Helper to select enemy type based on probability distribution
  SatelliteDifficulty _selectEnemyType(
      Map<SatelliteDifficulty, double> probabilities, Random random) {
    double roll = random.nextDouble();
    double cumulativeProbability = 0.0;

    for (var entry in probabilities.entries) {
      cumulativeProbability += entry.value;
      if (roll <= cumulativeProbability) {
        return entry.key;
      }
    }

    // Fallback to first enemy type (should never reach here if probabilities sum to 1.0)
    return difficultyList.first;
  }

  // Helper to find lowest power enemy type
  SatelliteDifficulty _getLowestPowerEnemyType() {
    SatelliteDifficulty lowestType = difficultyList.first;
    int lowestPower = _getPowerLevelForType(lowestType);

    for (var type in difficultyList) {
      int power = _getPowerLevelForType(type);
      if (power < lowestPower) {
        lowestType = type;
        lowestPower = power;
      }
    }

    return lowestType;
  }

  // Helper to get power level for an enemy type
  int _getPowerLevelForType(SatelliteDifficulty type) {
    // Replace with your actual way of getting power levels
    switch (type) {
      case SatelliteDifficulty.easy:
        return 1;
      case SatelliteDifficulty.medium:
        return 3;
      case SatelliteDifficulty.hard:
        return 5;
      case SatelliteDifficulty.boss:
        return 10;
    }
  }

  // Factory method to create enemy components
  SatelliteComponent createEnemy(SatelliteDifficulty type) {
    // Replace this with your actual enemy creation logic
    return SatelliteComponent(difficulty: type)
      ..setImpulseTarget = impulseTargets[rnd.nextInt(
        (impulseTargets.length - 1),
      )];
  }

  void spawnSatellites() {
    if (index < pendingSpawn.length) {
      final currentSatellite = pendingSpawn[index];
      ++index;
      game.world.add(currentSatellite);
    }
  }
}
