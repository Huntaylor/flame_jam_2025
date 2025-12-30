import 'package:bloc/bloc.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:equatable/equatable.dart';

part 'game_event.dart';
part 'game_state.dart';
part 'game_bloc.g.dart';

class GameBloc extends Bloc<GameEvent, GameState> {
  GameBloc() : super(const GameState.initial()) {
    on<GameStarted>(_startGame);
    on<GameLost>(_gameOver);
    on<GameWon>(_victory);
  }

  Future<void> _startGame(GameStarted event, Emitter<GameState> emit) async {
    emit(state.copyWith(gameStatus: GameStatus.start));
  }

  Future<void> _gameOver(GameLost event, Emitter<GameState> emit) async {
    emit(state.copyWith(
        gameStatus: GameStatus.end,
        gameOverType: GameOverType.satelliteOverwhelm));
  }

  Future<void> _victory(GameWon event, Emitter<GameState> emit) async {
    emit(state.copyWith(
        gameStatus: GameStatus.end, gameOverType: GameOverType.earthDestroyed));
  }
}
