import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flame_jam_2025/game/satellites_game.dart';
import 'package:logging/logging.dart';

class AudioComponent extends Component with HasGameReference<SatellitesGame> {
  AudioComponent();
  static final Logger _log = Logger('Asteroid Component');
  Future<void> onAsteroidDestoryed() async {
    if (game.isPlaying) {
      try {
        await FlameAudio.play('explosion.wav', volume: 0.1);
      } catch (e) {
        _log.severe('Audio error', e);
      }
    }
  }

  Future<void> onSatelliteDestoryed() async {
    if (game.isPlaying) {
      try {
        await FlameAudio.play('satellite_explosion.wav', volume: 0.1);
      } catch (e) {
        _log.severe('Audio error', e);
      }
    }
  }

  Future<void> onEnterOrbit() async {
    if (game.isPlaying) {
      try {
        await FlameAudio.play('entering_orbit.wav', volume: 0.1);
      } catch (e) {
        _log.severe('Audio error', e);
      }
    }
  }

  Future<void> onPowerUp() async {
    if (game.isPlaying) {
      try {
        await FlameAudio.play('powerUp.wav', volume: 0.1);
      } catch (e) {
        _log.severe('Audio error', e);
      }
    }
  }
}
