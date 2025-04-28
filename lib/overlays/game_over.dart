import 'package:flame_jam_2025/game/satellites_game.dart';
import 'package:flutter/material.dart';

class GameOver extends StatelessWidget {
  final SatellitesGame game;
  const GameOver({
    super.key,
    required this.game,
  });

  @override
  Widget build(BuildContext context) {
    const whiteTextColor = Color.fromRGBO(255, 255, 255, 1.0);

    String destroyed =
        'Satellites destroyed: ${game.destroyedSatellites.length}';

    String countryWon =
        'The ${game.storyComponent.bestCountryName} had the most amount of satellites in orbit - ${game.storyComponent.bestCountryCount}';

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
                'Game Over',
                style: TextStyle(
                  color: whiteTextColor,
                  fontSize: 24,
                ),
              ),
              Text(
                destroyed,
                style: TextStyle(
                  color: whiteTextColor,
                  fontSize: 12,
                ),
              ),
              Text(
                countryWon,
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
                  Navigator.of(context).pushNamed('NewGame');
                  game.overlays.remove('Game Over');
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
