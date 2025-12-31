part of 'upgrades_bloc.dart';

enum UpgradeType {
  none,
  damage,
  speed,
  quantity,
  size,
  capacity,
}

@CopyWith()
class UpgradesState extends Equatable {
  const UpgradesState({
    required this.damageLevel,
    required this.speedLevel,
    required this.sizeLevel,
    required this.quantityLevel,
    required this.capacityLevel,
    required this.totalPoints,
    required this.damageCost,
    required this.speedCost,
    required this.sizeCost,
    required this.quantityCost,
    required this.capacityCost,
  });

  final int damageLevel;
  final int speedLevel;
  final int sizeLevel;
  final int quantityLevel;
  final int capacityLevel;

  final int damageCost;
  final int speedCost;
  final int sizeCost;
  final int quantityCost;
  final int capacityCost;

  final int totalPoints;

  const UpgradesState.initial()
      : damageLevel = 0,
        speedLevel = 0,
        sizeLevel = 0,
        quantityLevel = 0,
        capacityLevel = 1,
        damageCost = 10,
        speedCost = 10,
        sizeCost = 10,
        quantityCost = 10,
        capacityCost = 10,
        totalPoints = 0;

  @override
  List<Object?> get props => _$props;
}
