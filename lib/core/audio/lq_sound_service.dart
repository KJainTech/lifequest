import 'lq_sound_io.dart' if (dart.library.html) 'lq_sound_web.dart' as platform;

import '../../core/haptics/lq_haptics.dart';

/// Kid-friendly SFX — HTML Audio on web, audioplayers on mobile/desktop.
abstract final class LQSound {
  static bool enabled = true;
  static bool _unlocked = false;

  /// Call synchronously inside a tap/click handler before any await.
  static void unlock() {
    if (!enabled || _unlocked) return;
    _unlocked = true;
    platform.LQSoundPlatform.unlock();
  }

  static void tap() {
    if (!enabled) return;
    unlock();
    LQHaptics.selectionClick();
    platform.LQSoundPlatform.play('tap.wav');
  }

  static void success() {
    if (!enabled) return;
    unlock();
    LQHaptics.mediumImpact();
    platform.LQSoundPlatform.play('success.wav');
  }

  static void celebrate() {
    if (!enabled) return;
    unlock();
    LQHaptics.heavyImpact();
    platform.LQSoundPlatform.play('celebrate.wav');
  }

  static void wrong() {
    if (!enabled) return;
    unlock();
    LQHaptics.heavyImpact();
    platform.LQSoundPlatform.play('wrong.wav');
  }

  static void levelUp() {
    if (!enabled) return;
    unlock();
    LQHaptics.mediumImpact();
    platform.LQSoundPlatform.play('level_up.wav');
  }

  static void build() {
    if (!enabled) return;
    unlock();
    LQHaptics.mediumImpact();
    platform.LQSoundPlatform.play('build.wav');
  }

  static void coin() {
    if (!enabled) return;
    unlock();
    LQHaptics.lightImpact();
    platform.LQSoundPlatform.play('coin.wav');
  }
}
