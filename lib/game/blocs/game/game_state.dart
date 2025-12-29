part of 'game_bloc.dart';

enum GameStatus { mainMenu, start, end }

@CopyWith()
class GameState extends Equatable {
  const GameState({required this.gameStatus});

  const GameState.initial() : gameStatus = GameStatus.mainMenu;

  final GameStatus gameStatus;

  bool get isGameOver => gameStatus == GameStatus.end;
  bool get isMainMenu => gameStatus == GameStatus.mainMenu;
  bool get isStart => gameStatus == GameStatus.start;

  bool get isNotGameOver => gameStatus != GameStatus.end;
  bool get isNotMainMenu => gameStatus != GameStatus.mainMenu;
  bool get isNotStart => gameStatus != GameStatus.start;

  @override
  List<Object?> get props => _$props;
}
