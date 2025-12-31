part of 'upgrades_bloc.dart';

sealed class UpgradesEvent extends Equatable {
  const UpgradesEvent();

  @override
  List<Object?> get props => _$props;
}

class UpgradeSelected extends UpgradesEvent {
  const UpgradeSelected({required this.upgradeType});
  final UpgradeType upgradeType;
  @override
  List<Object?> get props => _$props;
}

class UpgradePointsGained extends UpgradesEvent {
  const UpgradePointsGained({required this.satelliteDifficulty});
  final SatelliteDifficulty satelliteDifficulty;
  @override
  List<Object?> get props => _$props;
}
