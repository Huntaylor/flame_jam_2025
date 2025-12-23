import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'game_event.dart';
part 'game_state.dart';
part 'game_bloc.g.dart';

class GameBloc extends Bloc<GameEvent, GameState> {
  GameBloc() : super(const GameState.initial()) {
    on<GameEvent>((event, emit) {});
  }
}
