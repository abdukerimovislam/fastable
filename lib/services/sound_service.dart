import 'package:audioplayers/audioplayers.dart';

class SoundService {
  // Синглтон
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal();

  final AudioPlayer _waterPlayer = AudioPlayer();
  final AudioPlayer _completePlayer = AudioPlayer();

  void playWaterSound() {
    // Мы используем AssetSource и путь, который мы определили в pubspec.yaml
    // PlayerMode.lowLatency обязателен для коротких звуков,
    // чтобы не было задержки.
    _waterPlayer.play(
      AssetSource('sounds/water_drop.mp3'),
      mode: PlayerMode.lowLatency,
    );
  }

  void playCompleteSound() {
    _completePlayer.play(
      AssetSource('sounds/fast_complete.mp3'),
      mode: PlayerMode.lowLatency,
    );
  }

  // Вызовем этот метод при выходе из приложения
  void dispose() {
    _waterPlayer.dispose();
    _completePlayer.dispose();
  }
}