import 'package:flame_jam_2025/game/blocs/upgrades/upgrades_bloc.dart';
import 'package:flame_jam_2025/game/satellites_game.dart';
import 'package:flame_jam_2025/overlays/widgets/upgrade_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UpgradeOverlay extends StatelessWidget {
  final SatellitesGame game;
  const UpgradeOverlay({
    super.key,
    required this.game,
  });

  @override
  Widget build(BuildContext context) {
    final totalPoints = context.read<UpgradesBloc>().state.totalPoints;

    final damageCost = context.watch<UpgradesBloc>().state.damageCost;
    final speedCost = context.watch<UpgradesBloc>().state.speedCost;
    final sizeCost = context.watch<UpgradesBloc>().state.sizeCost;
    final quantityCost = context.watch<UpgradesBloc>().state.quantityCost;

    void _purchaseUpgrade(UpgradeType type) =>
        context.read<UpgradesBloc>().add(UpgradeSelected(upgradeType: type));

    return Material(
      color: Colors.transparent,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(10),
          height: 150,
          decoration: BoxDecoration(
            color: Colors.black.withAlpha(150),
            borderRadius: BorderRadius.all(
              Radius.circular(
                20,
              ),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 16,
                children: [
                  Text(
                    'Total points: $totalPoints',
                    style: TextStyle(
                      color: Color.fromRGBO(255, 255, 255, 1.0),
                      fontSize: 12,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 16,
                    children: [
                      const SizedBox(
                        width: 40,
                      ),
                      UpgradeButton(
                        onUpgradePressed: () =>
                            _purchaseUpgrade(UpgradeType.damage),
                        upgradeCost: damageCost,
                        upgradeName: 'Damage Up',
                      ),
                      UpgradeButton(
                        onUpgradePressed: () =>
                            _purchaseUpgrade(UpgradeType.speed),
                        upgradeCost: speedCost,
                        upgradeName: 'Speed Up',
                      ),
                      UpgradeButton(
                        onUpgradePressed: () =>
                            _purchaseUpgrade(UpgradeType.size),
                        upgradeCost: sizeCost,
                        upgradeName: 'Size Up',
                      ),
                      UpgradeButton(
                        onUpgradePressed: () =>
                            _purchaseUpgrade(UpgradeType.quantity),
                        upgradeCost: quantityCost,
                        upgradeName: 'Quantity Up',
                      ),
                    ],
                  ),
                ],
              ),
              IconButton(
                onPressed: () {
                  game.overlays.remove('Upgrades');
                },
                icon: Icon(
                  Icons.close,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
