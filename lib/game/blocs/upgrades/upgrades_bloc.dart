import 'package:bloc/bloc.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:equatable/equatable.dart';
import 'package:flame_jam_2025/game/forge_components/satellite/satellite_component.dart';

part 'upgrades_event.dart';
part 'upgrades_state.dart';
part 'upgrades_bloc.g.dart';

class UpgradesBloc extends Bloc<UpgradesEvent, UpgradesState> {
  UpgradesBloc() : super(UpgradesState.initial()) {
    on<UpgradeSelected>(_onUpgradePurchase);
    on<UpgradePointsGained>(_onPointsGained);
    on<UpgradeCometPointsGained>(_onCometPointsGained);
  }

  Future<void> _onCometPointsGained(
      UpgradeCometPointsGained event, Emitter<UpgradesState> emit) async {
    emit(state.copyWith(totalPoints: state.totalPoints + 20));
  }

  Future<void> _onUpgradePurchase(
      UpgradeSelected event, Emitter<UpgradesState> emit) async {
    switch (event.upgradeType) {
      case UpgradeType.damage:
        if (_checkPurchasePower(cost: state.damageCost)) {
          break;
        }

        int newTotal = state.totalPoints - state.damageCost;

        if (newTotal < 0) {
          newTotal = 0;
        }

        final newLevel = state.damageLevel + 1;

        emit(state.copyWith(
          damageLevel: newLevel,
          damageCost: _upgradeCost(newLevel),
          totalPoints: newTotal,
        ));

      case UpgradeType.speed:
        if (_checkPurchasePower(cost: state.speedCost)) {
          break;
        }

        int newTotal = state.totalPoints - state.speedCost;

        if (newTotal < 0) {
          newTotal = 0;
        }

        final newLevel = state.speedLevel + 1;

        emit(state.copyWith(
          speedLevel: newLevel,
          speedCost: _upgradeCost(newLevel),
          totalPoints: newTotal,
        ));

      case UpgradeType.quantity:
        if (_checkPurchasePower(cost: state.quantityCost)) {
          break;
        }

        int newTotal = state.totalPoints - state.quantityCost;

        if (newTotal < 0) {
          newTotal = 0;
        }

        final newLevel = state.quantityLevel + 1;

        emit(state.copyWith(
          quantityLevel: newLevel,
          quantityCost: _upgradeCost(newLevel),
          totalPoints: newTotal,
        ));

      case UpgradeType.size:
        if (_checkPurchasePower(cost: state.sizeCost)) {
          break;
        }

        int newTotal = state.totalPoints - state.sizeCost;

        if (newTotal < 0) {
          newTotal = 0;
        }

        final newLevel = state.sizeLevel + 1;

        emit(state.copyWith(
          sizeLevel: newLevel,
          sizeCost: _upgradeCost(newLevel),
          totalPoints: newTotal,
        ));

      case UpgradeType.capacity:
        if (_checkPurchasePower(cost: state.capacityCost)) {
          break;
        }

        int newTotal = state.totalPoints - state.capacityCost;

        if (newTotal < 0) {
          newTotal = 0;
        }

        final newLevel = state.capacityLevel + 1;
        emit(state.copyWith(
          capacityLevel: newLevel,
          capacityCost: _upgradeCost(newLevel),
          totalPoints: newTotal,
        ));

      case UpgradeType.none:
        break;
    }
  }

  Future<void> _onPointsGained(
      UpgradePointsGained event, Emitter<UpgradesState> emit) async {
    switch (event.satelliteDifficulty) {
      //? Worth 1 Point
      case SatelliteDifficulty.easy:
        emit(state.copyWith(totalPoints: state.totalPoints + 1));

      //? Worth 3 Points
      case SatelliteDifficulty.medium:
        emit(state.copyWith(totalPoints: state.totalPoints + 3));

      //? Worth 8 Points
      case SatelliteDifficulty.hard:
        emit(state.copyWith(totalPoints: state.totalPoints + 8));

      //? Worth 10 Points
      case SatelliteDifficulty.boss:
        emit(state.copyWith(totalPoints: state.totalPoints + 10));

      //? Worth 4 Points
      case SatelliteDifficulty.fast:
        emit(state.copyWith(totalPoints: state.totalPoints + 4));
    }
  }

  int _upgradeCost(int stateLevel) =>
      (5 + (stateLevel * (stateLevel / 1.5))).round();

  bool _checkPurchasePower({required int cost}) =>
      false /* state.totalPoints < cost */;
}
