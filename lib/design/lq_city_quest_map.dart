import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../core/motion/lq_motion.dart';
import '../core/tokens/lq_tokens.dart';
import '../core/tokens/lq_typography.dart';
import '../data/content/curriculum_builder.dart';
import '../data/content/lesson_catalog.dart';
import '../data/content/lesson_progression.dart';
import '../data/models/lq_models.dart';
import '../features/city/city_buildings.dart';
import 'lq_city_skyline.dart';

/// Interactive city quest map — zigzag path through stages with skyline progress.
class LQCityQuestMap extends StatelessWidget {
  const LQCityQuestMap({
    super.key,
    required this.colors,
    required this.questLevel,
    required this.progress,
    required this.profile,
    required this.levelUnlocked,
    required this.levelPct,
    required this.currentLessonId,
    required this.coins,
    required this.onStageTap,
    this.currentNodeKey,
  });

  final LQColors colors;
  final int questLevel;
  final List<LessonProgress> progress;
  final UserProfile? profile;
  final bool levelUnlocked;
  final double levelPct;
  final String? currentLessonId;
  final int coins;
  final ValueChanged<LessonMeta> onStageTap;
  final GlobalKey? currentNodeKey;

  @override
  Widget build(BuildContext context) {
    final stages = lessonsForQuestLevel(questLevel);
    final district = kCityDistrictThemes[questLevel - 1];
    final rowHeight = 112.0;
    final mapHeight = rowHeight * stages.length + 160;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _MapHeader(
          colors: colors,
          questLevel: questLevel,
          district: district,
          coins: coins,
        ),
        const SizedBox(height: LQSpacing.md),
        SizedBox(
          height: mapHeight,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: _QuestPathPainter(
                    stageCount: stages.length,
                    rowHeight: rowHeight,
                    color: colors.gold,
                    builtColor: district.accent,
                    progress: levelPct,
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: LQCitySkyline(
                  colors: colors,
                  height: 120,
                  progress: levelPct.clamp(0.08, 1),
                ),
              ),
              ...List.generate(stages.length, (i) {
                final meta = stages[i];
                final status = LessonProgression.statusFor(meta, progress, profile);
                final isCurrent = currentLessonId == meta.id;
                final building = cityBuildingForLesson(meta.id);
                final alignRight = i.isEven;
                final top = i * rowHeight + LQSpacing.sm;

                return Positioned(
                  top: top,
                  left: alignRight ? null : LQSpacing.sm,
                  right: alignRight ? LQSpacing.sm : null,
                  width: MediaQuery.sizeOf(context).width * 0.62,
                  child: _StageNode(
                    key: isCurrent ? currentNodeKey : null,
                    colors: colors,
                    meta: meta,
                    status: status,
                    isCurrent: isCurrent,
                    district: district,
                    buildingEmoji: building?.emoji ?? '🏙️',
                    coinPreview: stageCoinPreview(meta),
                    enabled: levelUnlocked && status != LessonStatus.locked,
                    onTap: () => onStageTap(meta),
                    delay: (i * 50).ms,
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }
}

class _MapHeader extends StatelessWidget {
  const _MapHeader({
    required this.colors,
    required this.questLevel,
    required this.district,
    required this.coins,
  });

  final LQColors colors;
  final int questLevel;
  final CityDistrictTheme district;
  final int coins;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(LQRadius.pill),
            border: Border.all(color: district.accent, width: 2),
            boxShadow: LQElevation.e1(colors.ink),
          ),
          child: Text(
            'L$questLevel · ${kQuestLevelNames[questLevel - 1]}',
            style: LQTypography.label(colors).copyWith(
              color: district.accent,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(LQRadius.pill),
            border: Border.all(color: colors.gold.withValues(alpha: 0.6)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.monetization_on_rounded, color: colors.gold, size: 20),
              const SizedBox(width: 4),
              Text(
                '$coins',
                style: LQTypography.label(colors).copyWith(fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StageNode extends StatefulWidget {
  const _StageNode({
    super.key,
    required this.colors,
    required this.meta,
    required this.status,
    required this.isCurrent,
    required this.district,
    required this.buildingEmoji,
    required this.coinPreview,
    required this.enabled,
    required this.onTap,
    required this.delay,
  });

  final LQColors colors;
  final LessonMeta meta;
  final LessonStatus status;
  final bool isCurrent;
  final CityDistrictTheme district;
  final String buildingEmoji;
  final int coinPreview;
  final bool enabled;
  final VoidCallback onTap;
  final Duration delay;

  @override
  State<_StageNode> createState() => _StageNodeState();
}

class _StageNodeState extends State<_StageNode> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final c = widget.colors;
    final done = widget.status == LessonStatus.completed;
    final accent = widget.district.accent;

    return GestureDetector(
      onTapDown: widget.enabled ? (_) => setState(() => _pressed = true) : null,
      onTapUp: widget.enabled
          ? (_) {
              setState(() => _pressed = false);
              widget.onTap();
            }
          : null,
      onTapCancel: widget.enabled ? () => setState(() => _pressed = false) : null,
      child: AnimatedScale(
        scale: _pressed ? LQMotion.pressScale : 1,
        duration: LQMotion.pressDuration,
        child: Material(
          color: c.surface,
          elevation: widget.isCurrent ? 3 : 0,
          shadowColor: accent.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(LQRadius.card),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(LQRadius.card),
              border: Border.all(
                color: widget.isCurrent
                    ? accent
                    : done
                        ? c.success.withValues(alpha: 0.6)
                        : c.border,
                width: widget.isCurrent ? 2.5 : 1,
              ),
              gradient: LinearGradient(
                colors: [
                  c.surface,
                  accent.withValues(alpha: widget.isCurrent ? 0.08 : 0.04),
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(LQSpacing.md),
              child: Row(
                children: [
                  _NodeBadge(
                    colors: c,
                    label: stageLabel(widget.meta),
                    done: done,
                    isCurrent: widget.isCurrent,
                    locked: !widget.enabled,
                    accent: accent,
                  ),
                  const SizedBox(width: LQSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.meta.title, style: LQTypography.h3(c)),
                        Text(
                          widget.meta.subtitle,
                          style: LQTypography.caption(c),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '+${widget.coinPreview} coins · AED lessons',
                          style: LQTypography.micro(c).copyWith(
                            color: c.gold,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(widget.buildingEmoji, style: const TextStyle(fontSize: 28)),
                ],
              ),
            ),
          ),
        ),
      ),
    )
        .animate(delay: widget.delay)
        .fadeIn(duration: LQMotion.adaptiveDuration(280.ms))
        .slideY(begin: 0.08, end: 0, curve: Curves.easeOutCubic);
  }
}

class _NodeBadge extends StatelessWidget {
  const _NodeBadge({
    required this.colors,
    required this.label,
    required this.done,
    required this.isCurrent,
    required this.locked,
    required this.accent,
  });

  final LQColors colors;
  final String label;
  final bool done;
  final bool isCurrent;
  final bool locked;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final bg = done
        ? colors.success
        : isCurrent
            ? accent
            : locked
                ? colors.inkSoft.withValues(alpha: 0.15)
                : colors.accentMint;

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        boxShadow: isCurrent ? LQElevation.e1(accent) : null,
      ),
      child: Center(
        child: locked
            ? Icon(Icons.lock_rounded, size: 18, color: colors.inkSoft)
            : done
                ? Icon(Icons.check_rounded, size: 22, color: colors.surface)
                : Text(
                    label,
                    style: LQTypography.micro(colors).copyWith(
                      fontWeight: FontWeight.w800,
                      color: isCurrent ? colors.surface : colors.ink,
                      fontSize: 11,
                    ),
                  ),
      ),
    );
  }
}

class _QuestPathPainter extends CustomPainter {
  _QuestPathPainter({
    required this.stageCount,
    required this.rowHeight,
    required this.color,
    required this.builtColor,
    required this.progress,
  });

  final int stageCount;
  final double rowHeight;
  final Color color;
  final Color builtColor;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    if (stageCount < 2) return;

    final path = Path();
    final nodes = <Offset>[];

    for (var i = 0; i < stageCount; i++) {
      final y = i * rowHeight + rowHeight * 0.45 + LQSpacing.sm;
      final x = i.isEven ? size.width * 0.78 : size.width * 0.22;
      nodes.add(Offset(x, y));
    }

    path.moveTo(nodes.first.dx, nodes.first.dy);
    for (var i = 1; i < nodes.length; i++) {
      final prev = nodes[i - 1];
      final cur = nodes[i];
      path.cubicTo(
        prev.dx,
        (prev.dy + cur.dy) / 2,
        cur.dx,
        (prev.dy + cur.dy) / 2,
        cur.dx,
        cur.dy,
      );
    }

    final builtIndex = (progress * stageCount).floor().clamp(0, stageCount - 1);

    _drawDashedPath(canvas, path, color.withValues(alpha: 0.55), 3, 10, 8);

    if (builtIndex > 0) {
      final builtPath = Path();
      builtPath.moveTo(nodes.first.dx, nodes.first.dy);
      for (var i = 1; i <= builtIndex && i < nodes.length; i++) {
        final prev = nodes[i - 1];
        final cur = nodes[i];
        builtPath.cubicTo(
          prev.dx,
          (prev.dy + cur.dy) / 2,
          cur.dx,
          (prev.dy + cur.dy) / 2,
          cur.dx,
          cur.dy,
        );
      }
      canvas.drawPath(
        builtPath,
        Paint()
          ..color = builtColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4
          ..strokeCap = StrokeCap.round,
      );
    }

    for (var i = 0; i < nodes.length; i++) {
      final filled = i <= builtIndex;
      canvas.drawCircle(
        nodes[i],
        6,
        Paint()..color = filled ? builtColor : color.withValues(alpha: 0.5),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _QuestPathPainter old) =>
      old.progress != progress || old.stageCount != stageCount;

  void _drawDashedPath(
    Canvas canvas,
    Path path,
    Color color,
    double strokeWidth,
    double dash,
    double gap,
  ) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = distance + dash;
        canvas.drawPath(metric.extractPath(distance, next.clamp(0, metric.length)), paint);
        distance = next + gap;
      }
    }
  }
}
