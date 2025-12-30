import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:equatable/equatable.dart';
import 'package:flame_jam_2025/game/forge_components/satellite/satellite_component.dart';
import 'package:logging/logging.dart';

part 'wave_event.dart';
part 'wave_state.dart';
part 'wave_bloc.g.dart';

class WaveBloc extends Bloc<WaveEvent, WaveState> {
  final _rnd = Random();

  static final Logger _log = Logger('WaveBloc');
  WaveBloc() : super(WaveState.initial()) {
    on<WaveEnded>(_endWave);
    on<WaveStarted>(_startWave);
    on<WaveInProgress>(_progressWave);
    on<WaveStoryProgress>(_storyProgressWave);
    on<WaveStoryEnd>(_storyEndWave);
    on<EarthWarStarted>(_startEarthWar);
    on<EarthWarEnded>(_endEarthWar);
  }

  Future<void> _endWave(WaveEnded event, Emitter<WaveState> emit) async {
    _log.info('$event is emitted');

    emit(state.copyWith(status: WaveStatus.end));

    _incrementWave(emit);
  }

  Future<void> _startWave(WaveStarted event, Emitter<WaveState> emit) async {
    _log.info('$event is emitted');

    final pendingSpawn = await _generateWaveEnemies(emit);

    emit(state.copyWith(status: WaveStatus.start, pendingSpawn: pendingSpawn));
  }

  Future<void> _progressWave(
      WaveInProgress event, Emitter<WaveState> emit) async {
    _log.info('$event is emitted');

    emit(state.copyWith(status: WaveStatus.inProgress));
  }

  Future<void> _storyProgressWave(
      WaveStoryProgress event, Emitter<WaveState> emit) async {
    _log.info('$event is emitted');

    emit(state.copyWith(triggerStory: true));
  }

  Future<void> _storyEndWave(
      WaveStoryEnd event, Emitter<WaveState> emit) async {
    _log.info('$event is emitted');

    emit(state.copyWith(triggerStory: false));
  }

  Future<void> _startEarthWar(
      EarthWarStarted event, Emitter<WaveState> emit) async {
    _log.info('$event is emitted');

    emit(state.copyWith(isAtWar: true));
  }

  Future<void> _endEarthWar(
      EarthWarEnded event, Emitter<WaveState> emit) async {
    _log.info('$event is emitted');

    emit(state.copyWith(isEarthDestroyed: true));
  }

  Future<void> _incrementWave(Emitter<WaveState> emit) async {
    emit(state.copyWith(waveNumber: state.waveNumber + 1));

    _log.info('Number of waves incremented: ${state.waveNumber}');
  }

  // Generate enemies for the current wave
  Future<List<SatelliteDifficulty>> _generateWaveEnemies(
      Emitter<WaveState> emit) async {
    await _checkWaveDifficulty(emit);
    await _checkBossRound(emit);

    List<SatelliteDifficulty> tempEnemyList = [];

    int totalPower = _calculateTotalWavePower();

    Map<SatelliteDifficulty, double> probabilities = _getEnemyProbabilities();

    int remainingPower = totalPower;
    while (remainingPower > 0) {
      if (state.isBossAdded && !state.isProbsRefreshed) {
        probabilities = _getEnemyProbabilities();
        emit(state.copyWith(isProbsRefreshed: true));
      }

      SatelliteDifficulty selectedType = _selectEnemyType(probabilities, _rnd);

      final powerLevel = _getPowerLevel(selectedType);

      if (selectedType == SatelliteDifficulty.boss && state.waveNumber == 10) {
        emit(state.copyWith(isBossAdded: true));
      }

      if (powerLevel <= remainingPower) {
        tempEnemyList.add(selectedType);
        remainingPower -= powerLevel;
      } else {
        int lowestPower = _getPowerLevel(SatelliteDifficulty.easy);

        if (lowestPower <= remainingPower) {
          tempEnemyList.add(SatelliteDifficulty.easy);
        }
        break;
      }
    }
    if (state.isBossRound &&
        !tempEnemyList.any((e) => e == SatelliteDifficulty.boss)) {
      Logger('Wave Manager -- Wave did not contain a boss at Boss Round');
      tempEnemyList.add(SatelliteDifficulty.boss);
    }
    return tempEnemyList;
  }

  Future<void> _checkWaveDifficulty(Emitter<WaveState> emit) async {
    if (state.waveNumber > 15 && state.isPastFast) {
      emit(
        state.copyWith(
          isPastHard: true,
          difficultyStatus: DifficultyStatus.pastHardSatellies,
        ),
      );
    } else if (state.waveNumber > 10 && state.isPastTutorial) {
      emit(
        state.copyWith(
          isPastFast: true,
          difficultyStatus: DifficultyStatus.pastFastSatellies,
        ),
      );
    } else if (state.waveNumber > 3 && state.isInitialDifficulty) {
      emit(
        state.copyWith(
          isPastTutorial: true,
          difficultyStatus: DifficultyStatus.pastTutorial,
        ),
      );
    }
  }

  Future<void> _checkBossRound(Emitter<WaveState> emit) async {
    if ((state.waveNumber % 10) == 0) {
      emit(state.copyWith(
          isBossRound: true,
          stepUpHealth: state.stepUpHealth + .5,
          stepUpSpeed: state.stepUpSpeed + 1));
    } else {
      emit(state.copyWith(isBossRound: false));
    }
  }

  Map<SatelliteDifficulty, double> _getEnemyProbabilities() {
    Map<SatelliteDifficulty, double> probabilities = {};
    for (var type in state.difficultyList) {
      double? probability;
      switch (type) {
        case SatelliteDifficulty.easy:
          probability = max(0.8 - (state.waveNumber * 0.05), 0.2);
          break;
        case SatelliteDifficulty.medium:
          probability = !state.isPastTutorial
              ? 0
              : min(0.1 + (state.waveNumber * 0.03), 0.4);
          break;
        case SatelliteDifficulty.fast:
          probability =
              !state.isPastFast ? 0 : min(0.1 + (state.waveNumber * 0.03), 0.2);
          break;
        case SatelliteDifficulty.hard:
          probability = !state.isPastHard
              ? 0
              : min(0.05 + (state.waveNumber * 0.02), 0.3);
          break;
        case SatelliteDifficulty.boss:
          probability = 0;

          if (state.isBossRound) {
            if (state.waveNumber > 10) {
              probability = min(0.05 + (state.waveNumber * 0.02), 0.15);
            } else if (!state.isBossAdded) {
              probability = 1;
            }
          }
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

  int _calculateTotalWavePower() {
    if (state.isAtWar) {
      (state.waveNumber * 5).toInt();
    }
    return (state.waveNumber == 1)
        ? state.waveNumber
        : (state.waveNumber * 2).toInt();
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
    return state.difficultyList.first;
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
}
