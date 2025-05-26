import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flame_jam_2025/game/satellites_game.dart';

class AudioComponent extends Component with HasGameReference<SatellitesGame> {
  AudioComponent();

  onAsteroidDestoryed() async {
    if (game.isPlaying) {
      await FlameAudio.play('explosion.wav', volume: 0.1);
    }
  }

  onSatelliteDestoryed() async {
    if (game.isPlaying) {
      await FlameAudio.play('satellite_explosion.wav', volume: 0.1);
    }
  }

  onEnterOrbit() async {
    if (game.isPlaying) {
      await FlameAudio.play('entering_orbit.wav', volume: 0.1);
    }
  }

  onPowerUp() async {
    if (game.isPlaying) {
      await FlameAudio.play('powerUp.wav', volume: 0.1);
    }
  }
}
