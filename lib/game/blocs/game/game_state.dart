part of 'game_bloc.dart';

enum GameStatus { mainMenu, start, end }

enum GameOverType { initial, earthDestroyed, satelliteOverwhelm }

@CopyWith()
class GameState extends Equatable {
  const GameState({required this.gameStatus, required this.gameOverType});

  const GameState.initial()
      : gameStatus = GameStatus.mainMenu,
        gameOverType = GameOverType.initial;

  final GameStatus gameStatus;
  final GameOverType gameOverType;

  bool get isGameOver => gameStatus == GameStatus.end;
  bool get isMainMenu => gameStatus == GameStatus.mainMenu;
  bool get isStart => gameStatus == GameStatus.start;

  bool get isNotGameOver => gameStatus != GameStatus.end;
  bool get isNotMainMenu => gameStatus != GameStatus.mainMenu;
  bool get isNotStart => gameStatus != GameStatus.start;

  @override
  List<Object?> get props => _$props;
}
