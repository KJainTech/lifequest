import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/lq_theme.dart';
import '../../core/tokens/lq_tokens.dart';
import '../../core/tokens/lq_typography.dart';
import '../../data/content/lesson_catalog.dart';
import '../../data/models/lq_models.dart';
import '../../data/providers/app_providers.dart';
import '../../design/lq_canvas.dart';
import '../../design/lq_card.dart';
import '../../design/lq_icons.dart';
import '../../features/onboarding/auth_service.dart';

/// Learn tab — lesson path with done / current / locked nodes.
class LearnScreen extends ConsumerWidget {
  const LearnScreen({super.key});

  LessonStatus _statusFor(LessonMeta meta, List<LessonProgress> progress) {
    final p = progress.where((x) => x.lessonId == meta.id).firstOrNull;
    if (p != null) return p.status;
    if (meta.id == 'lesson_6') return LessonStatus.available;
    if (meta.prerequisiteId == null) return LessonStatus.available;
    final prereq = progress.where((x) => x.lessonId == meta.prerequisiteId).firstOrNull;
    if (prereq?.status == LessonStatus.completed) return LessonStatus.available;
    return LessonStatus.locked;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(lqColorsProvider);
    final profile = ref.watch(userProfileProvider).valueOrNull;
    final lessonsAsync = ref.watch(userLessonsProvider);
    final ageBand = profile?.ageBand ?? '5-8';

    return LQCanvas(
      colors: colors,
      child: SafeArea(
        child: lessonsAsync.when(
          loading: () => Center(child: CircularProgressIndicator(color: colors.brand)),
          error: (e, _) => Center(
            child: Text('Could not load lessons ($e)', style: LQTypography.bodySm(colors)),
          ),
          data: (progress) => CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(LQSpacing.gutter),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Learn', style: LQTypography.display(colors)),
                      const SizedBox(height: LQSpacing.sm),
                      Text(
                        'Your quest path · $ageBand',
                        style: LQTypography.bodySm(colors),
                      ),
                      const SizedBox(height: LQSpacing.xxl),
                    ],
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) {
                    final meta = kCurriculum[i];
                    final status = _statusFor(meta, progress);
                    return Padding(
                      padding: EdgeInsets.only(
                        left: LQSpacing.gutter,
                        right: LQSpacing.gutter,
                        bottom: LQSpacing.lg,
                      ),
                      child: _LessonNode(
                        colors: colors,
                        meta: meta,
                        status: status,
                        index: i,
                        onTap: status == LessonStatus.locked
                            ? null
                            : () {
                                if (meta.id == 'lesson_6') {
                                  context.push('/lesson/${meta.id}');
                                }
                              },
                      ).animate(delay: (i * 60).ms).fadeIn().slideY(begin: 0.08, end: 0),
                    );
                  },
                  childCount: kCurriculum.length,
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 88)),
            ],
          ),
        ),
      ),
    );
  }
}

class _LessonNode extends StatelessWidget {
  const _LessonNode({
    required this.colors,
    required this.meta,
    required this.status,
    required this.index,
    this.onTap,
  });

  final LQColors colors;
  final LessonMeta meta;
  final LessonStatus status;
  final int index;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isLocked = status == LessonStatus.locked;
    final isDone = status == LessonStatus.completed;
    final isCurrent = !isLocked && !isDone && meta.id == 'lesson_6';

    return LQCard(
      colors: colors,
      onTap: onTap,
      elevation: isCurrent ? 2 : 1,
      child: Row(
        children: [
          _NodeIcon(
            colors: colors,
            isLocked: isLocked,
            isDone: isDone,
            isCurrent: isCurrent,
            order: meta.conceptOrder,
          ),
          const SizedBox(width: LQSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meta.title,
                  style: LQTypography.h3(colors).copyWith(
                    color: isLocked ? colors.inkSoft : colors.ink,
                  ),
                ),
                const SizedBox(height: LQSpacing.xs),
                Text(meta.subtitle, style: LQTypography.bodySm(colors)),
                if (isCurrent) ...[
                  const SizedBox(height: LQSpacing.sm),
                  Text(
                    'Ready now',
                    style: LQTypography.microLabel(colors, color: colors.brand),
                  ),
                ],
              ],
            ),
          ),
          if (isDone)
            LQDuotoneIcon(
              icon: LQIconType.trophy,
              size: 28,
              primaryColor: colors.gold,
              secondaryColor: colors.gold.withValues(alpha: 0.3),
            ),
        ],
      ),
    );
  }
}

class _NodeIcon extends StatelessWidget {
  const _NodeIcon({
    required this.colors,
    required this.isLocked,
    required this.isDone,
    required this.isCurrent,
    required this.order,
  });

  final LQColors colors;
  final bool isLocked;
  final bool isDone;
  final bool isCurrent;
  final int order;

  @override
  Widget build(BuildContext context) {
    final bg = isDone
        ? colors.gold.withValues(alpha: 0.2)
        : isCurrent
            ? colors.brand.withValues(alpha: 0.2)
            : colors.inkSoft.withValues(alpha: 0.12);

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        border: isCurrent
            ? Border.all(color: colors.brand, width: 2)
            : null,
      ),
      alignment: Alignment.center,
      child: isLocked
          ? Icon(Icons.lock_outline_rounded, color: colors.inkSoft, size: 22)
          : Text(
              '$order',
              style: LQTypography.h3(colors).copyWith(
                color: isDone ? colors.gold : colors.brand,
              ),
            ),
    );
  }
}

extension _FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull {
    final it = iterator;
    return it.moveNext() ? it.current : null;
  }
}
