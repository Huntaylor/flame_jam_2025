import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame_jam_2025/game/forge_components/satellite/satellite_component.dart';
import 'package:flame_jam_2025/game/sateflies_game.dart';

enum WaveType {
  tutorial,
  tutorialComplete,
}

enum WaveState {
  start,
  inProgress,
  end,
}

class WaveManager extends Component with HasGameReference<SatefliesGame> {
  WaveManager({
    required this.impulseTargets,
  });

  WaveState? _waveState;

  bool get hasStarted => state == WaveState.start;
  bool get hasEnded => state == WaveState.end;
  bool get isInProgress => state == WaveState.inProgress;

  WaveState get state => _waveState ?? WaveState.start;

  set state(WaveState localState) {
    _waveState = localState;
  }

  WaveType? _waveType;

  bool get isTutorial => waveType == WaveType.tutorial;
  bool get isTutorialComplete => waveType == WaveType.tutorialComplete;

  WaveType get waveType => _waveType ?? WaveType.tutorial;

  set waveType(WaveType localWaveState) {
    _waveType = localWaveState;
  }

  bool isBossRound = false;
  bool isBossAdded = false;
  bool isProbsRefreshed = false;

  bool initialAdded = false;

  bool introduceFastSate = false;
  bool introduceHardSate = false;

  final List<Vector2> impulseTargets;

  late SatelliteComponent easySatellite;

  late SatelliteComponent mediumSatellite;

  late SatelliteComponent hardSatellite;

  late SatelliteComponent bossSatellite;

  List<SatelliteDifficulty> difficultyList = [];

  List<SatelliteComponent> enemies = [];

  List<SatelliteComponent> pendingSpawn = [];

  int index = 0;

  int waveNumber = 1;

  final rnd = Random();

  late Timer spawnTimer;
  late Timer waveTimer;

  @override
  FutureOr<void> onLoad() {
    waveTimer = Timer(
      5,
      onTick: () => onWaveComplete(),
      autoStart: false,
      repeat: false,
    );
    spawnTimer = Timer(1, onTick: () => spawnSatellites(), repeat: true);
    spawnTimer.start();

    difficultyList.addAll([
      SatelliteDifficulty.easy,
      SatelliteDifficulty.medium,
      SatelliteDifficulty.fast,
      SatelliteDifficulty.hard,
      SatelliteDifficulty.boss,
    ]);

    pendingSpawn = generateWaveEnemies();

    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (spawnTimer.isRunning()) {
      game.waveTextComponent.text = 'Wave $waveNumber';
      spawnTimer.update(dt);
    }
    if (waveTimer.isRunning()) {
      waveTimer.update(dt);
    }
    if (game.isGameStarted) {
      // Should be called one time and when all the current wave
      // satellites are destroyed
      if (isInProgress &&
          game.waveSatellites.isEmpty &&
          !waveTimer.isRunning()) {
        initialAdded = false;
        state = WaveState.end;
        waveTimer.start();
      }
    }
    super.update(dt);
  }

  void onWaveComplete() {
    waveNumber = ++waveNumber;
    if ((waveNumber % 10) == 0) {
      isBossRound = true;
    }

    if (waveNumber > 10 && !introduceFastSate) {
      introduceFastSate = true;
    } else if (waveNumber > 7 && !introduceHardSate) {
      introduceHardSate = true;
    } else if (waveNumber > 3 && !isTutorialComplete) {
      waveType = WaveType.tutorialComplete;
    }
    resetWave();
    pendingSpawn = generateWaveEnemies();
  }

  void resetWave() {
    index = 0;
    spawnTimer.start();
    enemies.clear();
    pendingSpawn.clear();
  }

  int calculateTotalWavePower() =>
      (waveNumber == 1) ? waveNumber : (waveNumber * 2).toInt();

  Map<SatelliteDifficulty, double> getEnemyProbabilities() {
    Map<SatelliteDifficulty, double> probabilities = {};

    for (var type in difficultyList) {
      double? probability;
      switch (type) {
        case SatelliteDifficulty.easy:
          probability = max(0.8 - (waveNumber * 0.05), 0.2);
          break;
        case SatelliteDifficulty.medium:
          probability = isTutorial ? 0 : min(0.1 + (waveNumber * 0.03), 0.4);
          break;
        case SatelliteDifficulty.fast:
          probability =
              !introduceFastSate ? 0 : min(0.1 + (waveNumber * 0.03), 0.2);
          break;
        case SatelliteDifficulty.hard:
          probability =
              !introduceHardSate ? 0 : min(0.05 + (waveNumber * 0.02), 0.3);
          break;
        case SatelliteDifficulty.boss:
          probability = (isBossRound && !isBossAdded) ? 1 : 0;
          break;
      }
      probabilities[type] = probability;
    }

    double total = probabilities.values.reduce((a, b) => a + b);

    probabilities.forEach((key, value) {
      probabilities[key] = value / total;
    });

    return probabilities;
  }

  // Generate enemies for the current wave
  List<SatelliteComponent> generateWaveEnemies() {
    state = WaveState.start;
    int totalPower = calculateTotalWavePower();
    Map<SatelliteDifficulty, double> probabilities = getEnemyProbabilities();

    int remainingPower = totalPower;
    while (remainingPower > 0) {
      if (isBossAdded && !isProbsRefreshed) {
        probabilities = getEnemyProbabilities();
        isProbsRefreshed = true;
      }

      SatelliteDifficulty selectedType = _selectEnemyType(probabilities, rnd);

      final powerLevel = _getPowerLevel(selectedType);

      if (isBossRound && !isBossAdded) {
        enemies.add(createEnemy(SatelliteDifficulty.boss));
        remainingPower -= powerLevel;
        isBossAdded = true;
      }

      if (powerLevel <= remainingPower) {
        enemies.add(createEnemy(selectedType));
        remainingPower -= powerLevel;
      } else {
        int lowestPower = _getPowerLevel(SatelliteDifficulty.easy);

        if (lowestPower <= remainingPower) {
          enemies.add(createEnemy(SatelliteDifficulty.easy));
        }
        break;
      }
    }
    return enemies;
  }

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

  int _getPowerLevel(SatelliteDifficulty type) {
    switch (type) {
      case SatelliteDifficulty.easy:
        return 1;
      case SatelliteDifficulty.medium:
        return 3;
      case SatelliteDifficulty.fast:
        return 4;
      case SatelliteDifficulty.hard:
        return 5;
      case SatelliteDifficulty.boss:
        return 10;
    }
  }

  SatelliteComponent createEnemy(SatelliteDifficulty type) {
    final indexLength = impulseTargets.length;
    final index = rnd.nextInt(
      indexLength,
    );

    return SatelliteComponent(difficulty: type, isBelow: index <= 4)
      ..setImpulseTarget = impulseTargets[index];
  }

  void spawnSatellites() {
    if (index < pendingSpawn.length) {
      final currentSatellite = pendingSpawn[index];
      ++index;
      game.world.add(currentSatellite);
      game.waveSatellites.add(currentSatellite);
      state = WaveState.inProgress;
    } else if (index >= pendingSpawn.length) {
      spawnTimer.stop();
    }
  }
}
