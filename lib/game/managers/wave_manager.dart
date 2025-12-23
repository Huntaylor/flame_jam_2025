import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame_bloc/flame_bloc.dart';
import 'package:flame_jam_2025/game/blocs/wave/wave_bloc.dart';
import 'package:flame_jam_2025/game/forge_components/satellite/satellite_component.dart';
import 'package:flame_jam_2025/game/forge_components/upgrades/upgrade_component.dart';
import 'package:flame_jam_2025/game/satellites_game.dart';
import 'package:logging/logging.dart';

class WaveManager extends Component
    with
        HasGameReference<SatellitesGame>,
        FlameBlocListenable<WaveBloc, WaveState> {
  static final Logger _log = Logger('Wave Manager');
  WaveManager({
    required this.impulseTargets,
  });

  final List<Vector2> impulseTargets;

  late SatelliteComponent easySatellite;
  late SatelliteComponent mediumSatellite;
  late SatelliteComponent hardSatellite;
  late SatelliteComponent bossSatellite;

  late UpgradeComponent upgradeComponent;

  List<UpgradeType> upgradeTypeList = [
    UpgradeType.damage,
    UpgradeType.quantity,
    UpgradeType.size,
    UpgradeType.speed,
  ];

  List<SatelliteCountry> originCountries = [
    SatelliteCountry.green,
    SatelliteCountry.brown,
    SatelliteCountry.cyan,
    SatelliteCountry.pink,
    SatelliteCountry.white,
    SatelliteCountry.grey,
  ];

  List<SatelliteDifficulty> pendingSpawn = [];

  List<UpgradeComponent> currentUpgrades = [];

  int waveNumber = 0;

  final rnd = Random();

  late Timer spawnTimer;
  late Timer waveTimer;
  late Timer upgradeTimer;

  @override
  bool listenWhen(WaveState previousState, WaveState newState) {
    super.listenWhen(previousState, newState);
    return previousState.status != newState.status;
  }

  @override
  void onNewState(WaveState state) {
    waveNumber = state.waveNumber;
    if (state.status == WaveStatus.start) {
      spawnTimer.start();
      pendingSpawn = state.pendingSpawn;
      if (state.waveNumber > 17) {
        final suddenLaunch = rnd.nextInt(20);
        if (suddenLaunch.isEven) {
          waveTimer.limit = 0.2;
        } else {
          waveTimer.limit = 5;
        }
      }
    }
    super.onNewState(state);
  }

  @override
  FutureOr<void> onLoad() {
    upgradeTimer = Timer(20,
        onTick: () => createUpgrade(), autoStart: false, repeat: true);
    waveTimer = Timer(
      5,
      onTick: () => onWaveComplete(),
      autoStart: false,
      repeat: false,
    );

    spawnTimer = Timer(1, onTick: () {
      _log.info('Spawn Timer on tick');
      spawnSatellites();
    }, repeat: true, autoStart: false);

    return super.onLoad();
  }

  void createUpgrade() {
    if (currentUpgrades.length >= 3) {
      return;
    }

    final randomUpgrade = rnd.nextInt(upgradeTypeList.length);
    upgradeComponent = UpgradeComponent(
      newPosition: Vector2(1, game.camera.visibleWorldRect.size.height / 2),
      type: upgradeTypeList[randomUpgrade],
    );
    currentUpgrades.add(upgradeComponent);
    game.world.add(upgradeComponent);
  }

  @override
  void update(double dt) {
    if (upgradeTimer.isRunning()) {
      upgradeTimer.update(dt);
    }
    if (spawnTimer.isRunning()) {
      game.waveTextComponent.text = 'Wave $waveNumber';
      spawnTimer.update(dt);
    }
    if (waveTimer.isRunning()) {
      waveTimer.update(dt);
    }
    if (game.isGameStarted && game.gameState != GameState.end) {
      if (!upgradeTimer.isRunning()) {
        upgradeTimer.start();
      }
      if (game.waveBloc.state.isInProgress) {
        if (game.waveSatellites.length == 1) {
          game.satellitesLeftTextComponent.text =
              '${game.waveSatellites.length} Satellite left';
        } else {
          game.satellitesLeftTextComponent.text =
              '${game.waveSatellites.length} Satellites left';
        }
        // Should be called one time and when all the current wave
        // satellites are destroyed
        if (game.waveSatellites.isEmpty &&
            !waveTimer.isRunning() &&
            pendingSpawn.isEmpty) {
          game.satellitesLeftTextComponent.text = 'Wave Complete!';
          game.waveBloc.add(WaveEnded());
          waveTimer.start();
        }
      }
    } else {
      game.waveTextComponent.text = '';
      game.satellitesLeftTextComponent.text = '';
    }
    super.update(dt);
  }

  void onWaveComplete() {
    game.waveBloc.add(WaveStarted());
  }

  Future<SatelliteComponent> createEnemy(SatelliteDifficulty type) async {
    final indexLength = impulseTargets.length;
    final index = rnd.nextInt(
      indexLength,
    );

    final originCountry =
        (waveNumber == 1) ? SatelliteCountry.green : getOrigin();

    return SatelliteComponent(
      key: ComponentKey.unique(),
      originCountry: originCountry,
      newPosition: game.earthPosition,
      isTooLate: false,
      difficulty: type,
      isBelow: index <= 4,
      stepUpSpeed: game.waveBloc.state.stepUpSpeed,
      stepUpHealth: (game.earthComponent.isAtWar)
          ? game.waveBloc.state.stepUpHealth + 2
          : game.waveBloc.state.stepUpHealth,
    )..setImpulseTarget = impulseTargets[index];
  }

  SatelliteCountry getOrigin() {
    final randomCountry = rnd.nextInt(originCountries.length);
    return originCountries[randomCountry];
  }

  Future<void> spawnSatellites() async {
    _log.info(pendingSpawn.length);
    if (pendingSpawn.isNotEmpty) {
      final currentSatellite = pendingSpawn.first;
      final enemy = await createEnemy(currentSatellite);
      game.world.add(enemy);
      game.waveSatellites.add(enemy);
      game.waveBloc.add(WaveInProgress());
      pendingSpawn.removeAt(0);
    } else {
      spawnTimer.stop();
    }
  }
}
