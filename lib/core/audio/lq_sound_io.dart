import 'package:audioplayers/audioplayers.dart';

/// Native/desktop sound playback via audioplayers.
abstract final class LQSoundPlatform {
  static const _volume = 0.62;
  static final List<AudioPlayer> _pool =
      List.generate(4, (_) => AudioPlayer()..setReleaseMode(ReleaseMode.stop));
  static int _next = 0;

  static void unlock() => play('tap.wav');

  static void play(String file) {
    final player = _pool[_next++ % _pool.length];
    player.play(AssetSource('audio/$file'), volume: _volume);
  }
}
