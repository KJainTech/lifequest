import 'package:web/web.dart' as web;

/// Web sound playback — fresh element per play, pleasant volume.
abstract final class LQSoundPlatform {
  static const _volume = 0.62;

  static String _url(String file) =>
      Uri.base.resolve('assets/audio/$file').toString();

  static void unlock() => play('tap.wav');

  static void play(String file) {
    try {
      final audio = web.HTMLAudioElement();
      audio.src = _url(file);
      audio.volume = _volume;
      audio.play();
    } catch (_) {
      // Browser blocked — needs a user gesture first.
    }
  }
}
