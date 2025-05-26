import 'package:flame_jam_2025/game/satellites_game.dart';
import 'package:flutter/material.dart';

class VictoryOverlay extends StatelessWidget {
  final SatellitesGame game;
  const VictoryOverlay({
    super.key,
    required this.game,
  });

  @override
  Widget build(BuildContext context) {
    const whiteTextColor = Color.fromRGBO(255, 255, 255, 1.0);

    String destroyed =
        'Satellites destroyed: ${game.destroyedSatellites.length}';

    return Material(
      color: Colors.transparent,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(10),
          height: 300,
          decoration: BoxDecoration(
            color: Colors.black.withAlpha(150),
            borderRadius: BorderRadius.all(
              Radius.circular(
                20,
              ),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Victory!',
                style: TextStyle(
                  color: whiteTextColor,
                  fontSize: 24,
                ),
              ),
              Text(
                'Earth is destoryed, you got the hidden ending!',
                style: TextStyle(
                  color: whiteTextColor,
                  fontSize: 12,
                ),
              ),
              Text(
                destroyed,
                style: TextStyle(
                  color: whiteTextColor,
                  fontSize: 12,
                ),
              ),
              const SizedBox(
                height: 40,
              ),
              ElevatedButton(
                onPressed: () {
                  game.gameState == GameState.mainMenu;
                  Navigator.of(context).pushReplacementNamed('NewGame');
                  game.overlays.remove('Victory');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey,
                ),
                child: const Text(
                  'Play Again',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
