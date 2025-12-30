part of 'wave_bloc.dart';

enum WaveStatus {
  initial,
  start,
  inProgress,
  end,
}

enum DifficultyStatus {
  initial,
  pastTutorial,
  pastHardSatellies,
  pastFastSatellies,
}

@CopyWith()
class WaveState extends Equatable {
  const WaveState({
    this.waveNumber = 1,
    required this.isBossAdded,
    required this.isBossRound,
    required this.isProbsRefreshed,
    required this.isAtWar,
    required this.status,
    required this.stepUpHealth,
    required this.stepUpSpeed,
    required this.pendingSpawn,
    required this.difficultyStatus,
    required this.isInitialDifficulty,
    required this.isPastTutorial,
    required this.isPastHard,
    required this.isPastFast,
    required this.satellites,
    required this.triggerStory,
    required this.isEarthDestroyed,
  });

  final WaveStatus status;

  bool get isStarted => status == WaveStatus.start;
  bool get hasEnded => status == WaveStatus.end;
  bool get isInProgress => status == WaveStatus.inProgress;

  final DifficultyStatus difficultyStatus;

  bool get isInitialDifficultyStatus =>
      difficultyStatus == DifficultyStatus.initial;
  bool get isPastTutorialStatus =>
      difficultyStatus == DifficultyStatus.pastTutorial;
  bool get isPastHardStatus =>
      difficultyStatus == DifficultyStatus.pastHardSatellies;
  bool get isPastFastStatus =>
      difficultyStatus == DifficultyStatus.pastFastSatellies;

  final bool isBossAdded;
  final bool isBossRound;
  final bool isProbsRefreshed;
  final bool isAtWar;
  final bool isEarthDestroyed;

  final bool isInitialDifficulty;
  final bool isPastTutorial;
  final bool isPastHard;
  final bool isPastFast;

  final bool triggerStory;

  final int waveNumber;

  final double stepUpHealth;
  final double stepUpSpeed;

  final List<SatelliteDifficulty> pendingSpawn;
  final List<SatelliteComponent> satellites;

  List<SatelliteDifficulty> get difficultyList => [
        SatelliteDifficulty.easy,
        SatelliteDifficulty.medium,
        SatelliteDifficulty.fast,
        SatelliteDifficulty.hard,
        SatelliteDifficulty.boss,
      ];

  WaveState.initial()
      : waveNumber = 1,
        isBossAdded = false,
        isBossRound = false,
        isProbsRefreshed = false,
        isAtWar = false,
        isInitialDifficulty = true,
        isPastTutorial = false,
        isPastHard = false,
        isPastFast = false,
        difficultyStatus = DifficultyStatus.initial,
        status = WaveStatus.initial,
        stepUpSpeed = 0,
        stepUpHealth = 1,
        satellites = [],
        pendingSpawn = <SatelliteDifficulty>[],
        triggerStory = false,
        isEarthDestroyed = false;

  @override
  List<Object?> get props => _$props;
}
