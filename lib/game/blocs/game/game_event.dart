part of 'game_bloc.dart';

sealed class GameEvent extends Equatable {
  const GameEvent();

  @override
  List<Object?> get props => _$props;
}

class GameStarted extends GameEvent {}

class GameLost extends GameEvent {}

class GameWon extends GameEvent {}

class GameMainMenu extends GameEvent {}
