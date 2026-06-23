import 'package:flutter/material.dart';

import '../core/haptics/lq_haptics.dart';
import '../core/tokens/lq_tokens.dart';
import '../core/tokens/lq_typography.dart';
import 'lq_icons.dart';

enum LQNavTab { home, learn, city, progress, profile }

/// Bottom navigation with custom duotone icons per §4.4
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
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        boxShadow: LQElevation.e2(colors.ink),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.only(
        top: LQSpacing.sm,
        bottom: LQSpacing.sm,
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: LQNavTab.values.map((tab) {
            final isActive = tab == current;
            return _NavItem(
              colors: colors,
              tab: tab,
              isActive: isActive,
              onTap: () {
                LQHaptics.selectionClick();
                onChanged(tab);
              },
            );
          }).toList(),
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
              size: 24,
              primaryColor: isActive ? colors.brand : colors.inkSoft,
              secondaryColor: isActive
                  ? colors.brand.withValues(alpha: 0.3)
                  : colors.inkSoft.withValues(alpha: 0.2),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: LQTypography.microNav(colors, isActive: isActive),
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
        LQNavTab.progress => (LQIconType.progress, 'Progress'),
        LQNavTab.profile => (LQIconType.profile, 'Profile'),
      };
}
