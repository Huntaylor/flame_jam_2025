// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_bloc.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$GameStateCWProxy {
  GameState gameStatus(GameStatus gameStatus);

  GameState gameOverType(GameOverType gameOverType);

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `GameState(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// GameState(...).copyWith(id: 12, name: "My name")
  /// ```
  GameState call({
    GameStatus gameStatus,
    GameOverType gameOverType,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfGameState.copyWith(...)` or call `instanceOfGameState.copyWith.fieldName(value)` for a single field.
class _$GameStateCWProxyImpl implements _$GameStateCWProxy {
  const _$GameStateCWProxyImpl(this._value);

  final GameState _value;

  @override
  GameState gameStatus(GameStatus gameStatus) => call(gameStatus: gameStatus);

  @override
  GameState gameOverType(GameOverType gameOverType) =>
      call(gameOverType: gameOverType);

  @override

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `GameState(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// GameState(...).copyWith(id: 12, name: "My name")
  /// ```
  GameState call({
    Object? gameStatus = const $CopyWithPlaceholder(),
    Object? gameOverType = const $CopyWithPlaceholder(),
  }) {
    return GameState(
      gameStatus:
          gameStatus == const $CopyWithPlaceholder() || gameStatus == null
              ? _value.gameStatus
              // ignore: cast_nullable_to_non_nullable
              : gameStatus as GameStatus,
      gameOverType:
          gameOverType == const $CopyWithPlaceholder() || gameOverType == null
              ? _value.gameOverType
              // ignore: cast_nullable_to_non_nullable
              : gameOverType as GameOverType,
    );
  }
}

extension $GameStateCopyWith on GameState {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfGameState.copyWith(...)` or `instanceOfGameState.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$GameStateCWProxy get copyWith => _$GameStateCWProxyImpl(this);
}

// **************************************************************************
// EquatableGenerator
// **************************************************************************

extension _$GameEventEquatableAnnotations on GameEvent {
  List<Object?> get _$props => [];
}

extension _$GameStateEquatableAnnotations on GameState {
  List<Object?> get _$props => [gameStatus, gameOverType];
}
