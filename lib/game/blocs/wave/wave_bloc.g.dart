// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wave_bloc.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$WaveStateCWProxy {
  WaveState waveNumber(int waveNumber);

  WaveState isBossAdded(bool isBossAdded);

  WaveState isBossRound(bool isBossRound);

  WaveState isProbsRefreshed(bool isProbsRefreshed);

  WaveState isAtWar(bool isAtWar);

  WaveState status(WaveStatus status);

  WaveState stepUpHealth(double stepUpHealth);

  WaveState stepUpSpeed(double stepUpSpeed);

  WaveState pendingSpawn(List<SatelliteDifficulty> pendingSpawn);

  WaveState difficultyStatus(DifficultyStatus difficultyStatus);

  WaveState isInitialDifficulty(bool isInitialDifficulty);

  WaveState isPastTutorial(bool isPastTutorial);

  WaveState isPastHard(bool isPastHard);

  WaveState isPastFast(bool isPastFast);

  WaveState satellites(List<SatelliteComponent> satellites);

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `WaveState(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// WaveState(...).copyWith(id: 12, name: "My name")
  /// ```
  WaveState call({
    int waveNumber,
    bool isBossAdded,
    bool isBossRound,
    bool isProbsRefreshed,
    bool isAtWar,
    WaveStatus status,
    double stepUpHealth,
    double stepUpSpeed,
    List<SatelliteDifficulty> pendingSpawn,
    DifficultyStatus difficultyStatus,
    bool isInitialDifficulty,
    bool isPastTutorial,
    bool isPastHard,
    bool isPastFast,
    List<SatelliteComponent> satellites,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfWaveState.copyWith(...)` or call `instanceOfWaveState.copyWith.fieldName(value)` for a single field.
class _$WaveStateCWProxyImpl implements _$WaveStateCWProxy {
  const _$WaveStateCWProxyImpl(this._value);

  final WaveState _value;

  @override
  WaveState waveNumber(int waveNumber) => call(waveNumber: waveNumber);

  @override
  WaveState isBossAdded(bool isBossAdded) => call(isBossAdded: isBossAdded);

  @override
  WaveState isBossRound(bool isBossRound) => call(isBossRound: isBossRound);

  @override
  WaveState isProbsRefreshed(bool isProbsRefreshed) =>
      call(isProbsRefreshed: isProbsRefreshed);

  @override
  WaveState isAtWar(bool isAtWar) => call(isAtWar: isAtWar);

  @override
  WaveState status(WaveStatus status) => call(status: status);

  @override
  WaveState stepUpHealth(double stepUpHealth) =>
      call(stepUpHealth: stepUpHealth);

  @override
  WaveState stepUpSpeed(double stepUpSpeed) => call(stepUpSpeed: stepUpSpeed);

  @override
  WaveState pendingSpawn(List<SatelliteDifficulty> pendingSpawn) =>
      call(pendingSpawn: pendingSpawn);

  @override
  WaveState difficultyStatus(DifficultyStatus difficultyStatus) =>
      call(difficultyStatus: difficultyStatus);

  @override
  WaveState isInitialDifficulty(bool isInitialDifficulty) =>
      call(isInitialDifficulty: isInitialDifficulty);

  @override
  WaveState isPastTutorial(bool isPastTutorial) =>
      call(isPastTutorial: isPastTutorial);

  @override
  WaveState isPastHard(bool isPastHard) => call(isPastHard: isPastHard);

  @override
  WaveState isPastFast(bool isPastFast) => call(isPastFast: isPastFast);

  @override
  WaveState satellites(List<SatelliteComponent> satellites) =>
      call(satellites: satellites);

  @override

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `WaveState(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// WaveState(...).copyWith(id: 12, name: "My name")
  /// ```
  WaveState call({
    Object? waveNumber = const $CopyWithPlaceholder(),
    Object? isBossAdded = const $CopyWithPlaceholder(),
    Object? isBossRound = const $CopyWithPlaceholder(),
    Object? isProbsRefreshed = const $CopyWithPlaceholder(),
    Object? isAtWar = const $CopyWithPlaceholder(),
    Object? status = const $CopyWithPlaceholder(),
    Object? stepUpHealth = const $CopyWithPlaceholder(),
    Object? stepUpSpeed = const $CopyWithPlaceholder(),
    Object? pendingSpawn = const $CopyWithPlaceholder(),
    Object? difficultyStatus = const $CopyWithPlaceholder(),
    Object? isInitialDifficulty = const $CopyWithPlaceholder(),
    Object? isPastTutorial = const $CopyWithPlaceholder(),
    Object? isPastHard = const $CopyWithPlaceholder(),
    Object? isPastFast = const $CopyWithPlaceholder(),
    Object? satellites = const $CopyWithPlaceholder(),
  }) {
    return WaveState(
      waveNumber:
          waveNumber == const $CopyWithPlaceholder() || waveNumber == null
              ? _value.waveNumber
              // ignore: cast_nullable_to_non_nullable
              : waveNumber as int,
      isBossAdded:
          isBossAdded == const $CopyWithPlaceholder() || isBossAdded == null
              ? _value.isBossAdded
              // ignore: cast_nullable_to_non_nullable
              : isBossAdded as bool,
      isBossRound:
          isBossRound == const $CopyWithPlaceholder() || isBossRound == null
              ? _value.isBossRound
              // ignore: cast_nullable_to_non_nullable
              : isBossRound as bool,
      isProbsRefreshed: isProbsRefreshed == const $CopyWithPlaceholder() ||
              isProbsRefreshed == null
          ? _value.isProbsRefreshed
          // ignore: cast_nullable_to_non_nullable
          : isProbsRefreshed as bool,
      isAtWar: isAtWar == const $CopyWithPlaceholder() || isAtWar == null
          ? _value.isAtWar
          // ignore: cast_nullable_to_non_nullable
          : isAtWar as bool,
      status: status == const $CopyWithPlaceholder() || status == null
          ? _value.status
          // ignore: cast_nullable_to_non_nullable
          : status as WaveStatus,
      stepUpHealth:
          stepUpHealth == const $CopyWithPlaceholder() || stepUpHealth == null
              ? _value.stepUpHealth
              // ignore: cast_nullable_to_non_nullable
              : stepUpHealth as double,
      stepUpSpeed:
          stepUpSpeed == const $CopyWithPlaceholder() || stepUpSpeed == null
              ? _value.stepUpSpeed
              // ignore: cast_nullable_to_non_nullable
              : stepUpSpeed as double,
      pendingSpawn:
          pendingSpawn == const $CopyWithPlaceholder() || pendingSpawn == null
              ? _value.pendingSpawn
              // ignore: cast_nullable_to_non_nullable
              : pendingSpawn as List<SatelliteDifficulty>,
      difficultyStatus: difficultyStatus == const $CopyWithPlaceholder() ||
              difficultyStatus == null
          ? _value.difficultyStatus
          // ignore: cast_nullable_to_non_nullable
          : difficultyStatus as DifficultyStatus,
      isInitialDifficulty:
          isInitialDifficulty == const $CopyWithPlaceholder() ||
                  isInitialDifficulty == null
              ? _value.isInitialDifficulty
              // ignore: cast_nullable_to_non_nullable
              : isInitialDifficulty as bool,
      isPastTutorial: isPastTutorial == const $CopyWithPlaceholder() ||
              isPastTutorial == null
          ? _value.isPastTutorial
          // ignore: cast_nullable_to_non_nullable
          : isPastTutorial as bool,
      isPastHard:
          isPastHard == const $CopyWithPlaceholder() || isPastHard == null
              ? _value.isPastHard
              // ignore: cast_nullable_to_non_nullable
              : isPastHard as bool,
      isPastFast:
          isPastFast == const $CopyWithPlaceholder() || isPastFast == null
              ? _value.isPastFast
              // ignore: cast_nullable_to_non_nullable
              : isPastFast as bool,
      satellites:
          satellites == const $CopyWithPlaceholder() || satellites == null
              ? _value.satellites
              // ignore: cast_nullable_to_non_nullable
              : satellites as List<SatelliteComponent>,
    );
  }
}

extension $WaveStateCopyWith on WaveState {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfWaveState.copyWith(...)` or `instanceOfWaveState.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$WaveStateCWProxy get copyWith => _$WaveStateCWProxyImpl(this);
}

// **************************************************************************
// EquatableGenerator
// **************************************************************************

extension _$WaveEventEquatableAnnotations on WaveEvent {
  List<Object?> get _$props => [];
}

extension _$EarthWarStartedEquatableAnnotations on EarthWarStarted {
  List<Object?> get _$props => [isAtWar];
}

extension _$WaveStateEquatableAnnotations on WaveState {
  List<Object?> get _$props => [
        status,
        difficultyStatus,
        isBossAdded,
        isBossRound,
        isProbsRefreshed,
        isAtWar,
        isInitialDifficulty,
        isPastTutorial,
        isPastHard,
        isPastFast,
        waveNumber,
        stepUpHealth,
        stepUpSpeed,
        pendingSpawn,
        satellites,
      ];
}
