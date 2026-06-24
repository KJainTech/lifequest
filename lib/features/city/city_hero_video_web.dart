import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

bool _viewRegistered = false;

/// Native HTML5 video — most reliable on Flutter Web.
Widget buildPlatformCityHero({required double progress}) {
  if (!_viewRegistered) {
    _viewRegistered = true;
    ui_web.platformViewRegistry.registerViewFactory(
      'lq-city-hero-video',
      (int viewId) {
        final video = web.document.createElement('video') as web.HTMLVideoElement;
        video.src = Uri.base.resolve('assets/assets/video/city_hero.mp4').toString();
        video.autoplay = true;
        video.loop = true;
        video.muted = true;
        video.setAttribute('playsinline', 'true');
        video.setAttribute('webkit-playsinline', 'true');
        video.style.setProperty('width', '100%');
        video.style.setProperty('height', '100%');
        video.style.setProperty('object-fit', 'cover');
        video.style.setProperty('display', 'block');
        video.play();
        return video;
      },
    );
  }

  final reveal = progress.clamp(0.0, 1.0);

  return Stack(
    fit: StackFit.expand,
    children: [
      const SizedBox.expand(
        child: HtmlElementView(viewType: 'lq-city-hero-video'),
      ),
      // Subtle bottom scrim for progress pill readability only.
      Positioned(
        left: 0,
        right: 0,
        bottom: 0,
        height: 72,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withValues(alpha: 0.18),
              ],
            ),
          ),
        ),
      ),
      if (reveal < 1)
        Positioned(
          top: 12,
          right: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${(reveal * 100).round()}% built',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF28B77F),
              ),
            ),
          ),
        ),
    ],
  );
}
