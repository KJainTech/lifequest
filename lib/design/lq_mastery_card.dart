import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../core/tokens/lq_tokens.dart';
import '../core/tokens/lq_typography.dart';

/// Debit-card-style mastery card — rewards earned coins & LQ score (GoHenry-inspired).
class LQMasteryCard extends StatefulWidget {
  const LQMasteryCard({
    super.key,
    required this.colors,
    required this.displayName,
    required this.coins,
    required this.lqScore,
    required this.questLevelName,
    required this.streakDays,
    this.questLevel = 1,
    this.onTap,
  });

  final LQColors colors;
  final String displayName;
  final int coins;
  final int lqScore;
  final String questLevelName;
  final int streakDays;
  final int questLevel;
  final VoidCallback? onTap;

  static String formatMasteryId(int lqScore) {
    final padded = lqScore.clamp(0, 9999).toString().padLeft(4, '0');
    return '$padded · LQ · ${(lqScore * 7 % 10000).toString().padLeft(4, '0')} · ${(lqScore * 13 % 10000).toString().padLeft(4, '0')}';
  }

  @override
  State<LQMasteryCard> createState() => _LQMasteryCardState();
}

class _LQMasteryCardState extends State<LQMasteryCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shine;
  bool _showBack = false;

  @override
  void initState() {
    super.initState();
    _shine = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat();
  }

  @override
  void dispose() {
    _shine.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final aspect = 1.586; // ISO 7810 ID-1
    return GestureDetector(
      onTap: () {
        if (widget.onTap != null) {
          widget.onTap!();
        } else {
          setState(() => _showBack = !_showBack);
        }
      },
      child: AspectRatio(
        aspectRatio: aspect,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 420),
          transitionBuilder: (child, anim) {
            final rotate = Tween(begin: math.pi, end: 0.0).animate(anim);
            return AnimatedBuilder(
              animation: rotate,
              child: child,
              builder: (context, child) {
                final v = rotate.value;
                final isUnder = v > math.pi / 2;
                return Transform(
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..rotateY(v),
                  alignment: Alignment.center,
                  child: isUnder
                      ? Transform(
                          transform: Matrix4.identity()..rotateY(math.pi),
                          alignment: Alignment.center,
                          child: child,
                        )
                      : child,
                );
              },
            );
          },
          child: _showBack
              ? _CardBack(
                  key: const ValueKey('back'),
                  colors: widget.colors,
                  lqScore: widget.lqScore,
                  questLevelName: widget.questLevelName,
                  streakDays: widget.streakDays,
                )
              : _CardFront(
                  key: const ValueKey('front'),
                  colors: widget.colors,
                  displayName: widget.displayName,
                  coins: widget.coins,
                  lqScore: widget.lqScore,
                  questLevelName: widget.questLevelName,
                  questLevel: widget.questLevel,
                  shine: _shine,
                ),
        ),
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.08, end: 0);
  }
}

class _CardFront extends StatelessWidget {
  const _CardFront({
    super.key,
    required this.colors,
    required this.displayName,
    required this.coins,
    required this.lqScore,
    required this.questLevelName,
    required this.questLevel,
    required this.shine,
  });

  final LQColors colors;
  final String displayName;
  final int coins;
  final int lqScore;
  final String questLevelName;
  final int questLevel;
  final Animation<double> shine;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(LQRadius.card),
        boxShadow: [
          BoxShadow(
            color: colors.brandDeep.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors.brand,
            colors.brandDeep,
            Color.lerp(colors.brandDeep, colors.ink, 0.15)!,
          ],
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(LQRadius.card),
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _HoloStripePainter(shine: shine, gold: colors.gold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(LQSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      _GoldChip(colors: colors),
                      const Spacer(),
                      Text(
                        'LifeQuest',
                        style: LQTypography.label(colors).copyWith(
                          color: Colors.white.withValues(alpha: 0.95),
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    LQMasteryCard.formatMasteryId(lqScore),
                    style: LQTypography.h3(colors).copyWith(
                      color: Colors.white,
                      letterSpacing: 2,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  const SizedBox(height: LQSpacing.sm),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              displayName.toUpperCase(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: LQTypography.label(colors).copyWith(
                                color: Colors.white.withValues(alpha: 0.9),
                                letterSpacing: 1.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              questLevelName,
                              style: LQTypography.micro(colors).copyWith(
                                color: colors.gold,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '$coins',
                            style: LQTypography.h2(colors).copyWith(
                              color: colors.gold,
                              height: 1,
                            ),
                          ),
                          Text(
                            'coins',
                            style: LQTypography.micro(colors).copyWith(
                              color: Colors.white.withValues(alpha: 0.75),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: LQSpacing.xs),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'LQ $lqScore',
                        style: LQTypography.micro(colors).copyWith(
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                      Text(
                        'LV $questLevel',
                        style: LQTypography.micro(colors).copyWith(
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardBack extends StatelessWidget {
  const _CardBack({
    super.key,
    required this.colors,
    required this.lqScore,
    required this.questLevelName,
    required this.streakDays,
  });

  final LQColors colors;
  final int lqScore;
  final String questLevelName;
  final int streakDays;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(LQRadius.card),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colors.surfaceMuted, colors.surface],
        ),
        border: Border.all(color: colors.border),
        boxShadow: [
          BoxShadow(
            color: colors.ink.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(LQSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Your mastery', style: LQTypography.h3(colors)),
            const SizedBox(height: LQSpacing.md),
            _StatRow(colors: colors, label: 'LifeQuest score', value: '$lqScore'),
            _StatRow(colors: colors, label: 'Quest rank', value: questLevelName),
            _StatRow(
              colors: colors,
              label: 'Streak',
              value: streakDays == 0 ? 'Start today!' : '$streakDays days',
            ),
            const Spacer(),
            Text(
              'Tap to flip · Earn coins by completing stages',
              style: LQTypography.micro(colors),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({
    required this.colors,
    required this.label,
    required this.value,
  });

  final LQColors colors;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: LQSpacing.sm),
      child: Row(
        children: [
          Expanded(child: Text(label, style: LQTypography.bodySm(colors))),
          Text(
            value,
            style: LQTypography.label(colors).copyWith(color: colors.brand),
          ),
        ],
      ),
    );
  }
}

class _GoldChip extends StatelessWidget {
  const _GoldChip({required this.colors});

  final LQColors colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 32,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.lerp(colors.gold, Colors.white, 0.35)!,
            colors.gold,
            Color.lerp(colors.gold, colors.warn, 0.2)!,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: colors.gold.withValues(alpha: 0.4),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: 28,
          height: 20,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.35),
              width: 1,
            ),
          ),
        ),
      ),
    );
  }
}

class _HoloStripePainter extends CustomPainter {
  _HoloStripePainter({required this.shine, required this.gold});

  final Animation<double> shine;
  final Color gold;

  @override
  void paint(Canvas canvas, Size size) {
    final t = shine.value;
    final stripePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment(-1 + t * 2, -1),
        end: Alignment(t * 2, 1),
        colors: [
          Colors.white.withValues(alpha: 0),
          Colors.white.withValues(alpha: 0.12),
          gold.withValues(alpha: 0.18),
          Colors.white.withValues(alpha: 0.08),
          Colors.white.withValues(alpha: 0),
        ],
        stops: const [0, 0.35, 0.5, 0.65, 1],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.55, size.height * 0.08, size.width * 0.5, size.height * 0.84),
        const Radius.circular(20),
      ),
      stripePaint,
    );

    final dots = Paint()..color = Colors.white.withValues(alpha: 0.06);
    for (var i = 0; i < 8; i++) {
      canvas.drawCircle(
        Offset(size.width * (0.1 + i * 0.11), size.height * 0.15),
        3 + (i % 2),
        dots,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _HoloStripePainter oldDelegate) =>
      oldDelegate.shine.value != shine.value;
}

/// GoHenry-style quick actions under the mastery card.
class LQCardQuickActions extends StatelessWidget {
  const LQCardQuickActions({
    super.key,
    required this.colors,
    required this.onEarn,
    required this.onSave,
    required this.onCity,
    required this.onProgress,
  });

  final LQColors colors;
  final VoidCallback onEarn;
  final VoidCallback onSave;
  final VoidCallback onCity;
  final VoidCallback onProgress;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _Action(
          colors: colors,
          icon: Icons.school_rounded,
          label: 'Earn',
          onTap: onEarn,
        ),
        _Action(
          colors: colors,
          icon: Icons.savings_outlined,
          label: 'Save',
          onTap: onSave,
        ),
        _Action(
          colors: colors,
          icon: Icons.location_city_outlined,
          label: 'City',
          onTap: onCity,
        ),
        _Action(
          colors: colors,
          icon: Icons.leaderboard_outlined,
          label: 'Progress',
          onTap: onProgress,
        ),
      ],
    );
  }
}

class _Action extends StatelessWidget {
  const _Action({
    required this.colors,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final LQColors colors;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(LQRadius.control),
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: colors.surface,
              shape: BoxShape.circle,
              border: Border.all(color: colors.border),
              boxShadow: [
                BoxShadow(
                  color: colors.ink.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, color: colors.brand, size: 24),
          ),
          const SizedBox(height: LQSpacing.xs),
          Text(label, style: LQTypography.micro(colors)),
        ],
      ),
    );
  }
}
