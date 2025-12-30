part of 'wave_bloc.dart';

sealed class WaveEvent extends Equatable {
  const WaveEvent();

  @override
  List<Object?> get props => _$props;
}

class WaveStarted extends WaveEvent {
  const WaveStarted();
}

class WaveEnded extends WaveEvent {}

class WaveInProgress extends WaveEvent {}

class WaveStoryProgress extends WaveEvent {}

class WaveStoryEnd extends WaveEvent {}

class EarthWarStarted extends WaveEvent {}

class EarthWarEnded extends WaveEvent {}
