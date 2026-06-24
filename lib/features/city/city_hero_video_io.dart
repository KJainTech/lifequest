import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// video_player fallback for iOS / Android / desktop.
Widget buildPlatformCityHero({required double progress}) {
  return _NativeCityHero(progress: progress);
}

class _NativeCityHero extends StatefulWidget {
  const _NativeCityHero({required this.progress});
  final double progress;

  @override
  State<_NativeCityHero> createState() => _NativeCityHeroState();
}

class _NativeCityHeroState extends State<_NativeCityHero> {
  VideoPlayerController? _controller;
  bool _ready = false;
  bool _usePoster = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final controller = VideoPlayerController.asset('assets/video/city_hero.mp4');
    try {
      await controller.initialize();
      await controller.setLooping(true);
      await controller.setVolume(0);
      await controller.play();
      if (mounted) {
        setState(() {
          _controller = controller;
          _ready = true;
        });
      }
    } catch (_) {
      await controller.dispose();
      if (mounted) setState(() => _usePoster = true);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_usePoster) {
      return Image.asset(
        'assets/img/city/city_poster.png',
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    }
    if (!_ready || _controller == null) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }
    return FittedBox(
      fit: BoxFit.cover,
      clipBehavior: Clip.hardEdge,
      child: SizedBox(
        width: _controller!.value.size.width,
        height: _controller!.value.size.height,
        child: VideoPlayer(_controller!),
      ),
    );
  }
}
