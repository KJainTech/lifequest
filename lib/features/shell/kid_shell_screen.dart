import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/lq_theme.dart';
import '../../design/lq_bottom_nav.dart';
import '../../services/session_timer_service.dart';

/// Kid shell — Home · Learn · City · Awards · Me
class KidShellScreen extends ConsumerWidget {
  const KidShellScreen({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(lqColorsProvider);

    void onTab(LQNavTab tab) {
      final index = switch (tab) {
        LQNavTab.home => 0,
        LQNavTab.learn => 1,
        LQNavTab.city => 2,
        LQNavTab.awards => 3,
        LQNavTab.profile => 4,
      };
      navigationShell.goBranch(
        index,
        initialLocation: index == navigationShell.currentIndex,
      );
    }

    final current = switch (navigationShell.currentIndex) {
      0 => LQNavTab.home,
      1 => LQNavTab.learn,
      2 => LQNavTab.city,
      3 => LQNavTab.awards,
      _ => LQNavTab.profile,
    };

    return Scaffold(
      backgroundColor: colors.canvas,
      extendBody: false,
      body: Stack(
        fit: StackFit.expand,
        children: [
          navigationShell,
          const SessionBreakOverlay(),
        ],
      ),
      bottomNavigationBar: LQBottomNav(
        colors: colors,
        current: current,
        onChanged: onTab,
      ),
    );
  }
}
