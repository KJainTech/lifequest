import 'package:flutter/material.dart';

import '../core/haptics/lq_haptics.dart';
import '../core/tokens/lq_tokens.dart';
import '../core/tokens/lq_typography.dart';
import 'lq_icons.dart';

/// Play-first nav: Home · Learn · City · Awards · Me
enum LQNavTab { home, learn, city, awards, profile }

class LQBottomNav extends StatelessWidget {
  const LQBottomNav({
    super.key,
    required this.colors,
    required this.current,
    required this.onChanged,
  });

  final LQColors colors;
  final LQNavTab current;
  final ValueChanged<LQNavTab> onChanged;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(top: BorderSide(color: colors.border)),
        boxShadow: [
          BoxShadow(
            color: colors.ink.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: LQSpacing.sm,
            vertical: LQSpacing.xs,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: LQNavTab.values.map((tab) {
              return _NavItem(
                colors: colors,
                tab: tab,
                isActive: tab == current,
                onTap: () {
                  LQHaptics.selectionClick();
                  onChanged(tab);
                },
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.colors,
    required this.tab,
    required this.isActive,
    required this.onTap,
  });

  final LQColors colors;
  final LQNavTab tab;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final (icon, label) = _tabData(tab);
    final tint = isActive ? colors.brand : colors.inkSoft;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 64,
        height: LQTouch.minTarget,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LQDuotoneIcon(
              icon: icon,
              size: isActive ? 24 : 22,
              primaryColor: tint,
              secondaryColor: tint.withValues(alpha: 0.25),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: LQTypography.microNav(colors, isActive: isActive).copyWith(
                color: tint,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  (LQIconType, String) _tabData(LQNavTab tab) => switch (tab) {
        LQNavTab.home => (LQIconType.home, 'Home'),
        LQNavTab.learn => (LQIconType.learn, 'Learn'),
        LQNavTab.city => (LQIconType.city, 'City'),
        LQNavTab.awards => (LQIconType.trophy, 'Awards'),
        LQNavTab.profile => (LQIconType.profile, 'Me'),
      };
}
