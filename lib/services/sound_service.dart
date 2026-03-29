import 'package:audioplayers/audioplayers.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class SoundService {
  final AudioPlayer _waterPlayer = AudioPlayer();
  final AudioPlayer _completePlayer = AudioPlayer();

  SoundService() {
    // Настраиваем плееры, чтобы они останавливались после завершения
    // Это важно для повторного воспроизведения коротких звуков
    _waterPlayer.setReleaseMode(ReleaseMode.stop);
    _completePlayer.setReleaseMode(ReleaseMode.stop);
  }

  Future<void> playWaterSound() async {
    // Исправлено расширение на .wav (как в папке assets)
    await _waterPlayer.play(
      AssetSource('sounds/water_drop.wav'),
      mode: PlayerMode.lowLatency,
    );
  }

  Future<void> playCompleteSound() async {
    // Исправлено расширение на .wav
    await _completePlayer.play(
      AssetSource('sounds/fast_complete.wav'),
      mode: PlayerMode.lowLatency,
    );
  }

  void dispose() {
    _waterPlayer.dispose();
    _completePlayer.dispose();
  }
}
