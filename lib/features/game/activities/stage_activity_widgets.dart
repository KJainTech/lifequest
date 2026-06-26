import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../data/content/money_concept_copy.dart';
import '../../../core/tokens/lq_tokens.dart';
import '../../../core/tokens/lq_typography.dart';
import '../../../data/models/stage_activity.dart';
import '../../../design/lq_button.dart';
import '../../../design/lq_quiz_choice.dart';

String? _bucketHint(String label) {
  final lower = label.toLowerCase();
  if (lower.contains('need')) return MoneyConceptCopy.needsBucketHint;
  if (lower.contains('want')) return MoneyConceptCopy.wantsBucketHint;
  return null;
}

class DragDropBucketActivity extends StatefulWidget {
  const DragDropBucketActivity({
    super.key,
    required this.activity,
    required this.colors,
    required this.onComplete,
  });

  final StageActivity activity;
  final LQColors colors;
  final VoidCallback onComplete;

  @override
  State<DragDropBucketActivity> createState() => _DragDropBucketActivityState();
}

class _DragDropBucketActivityState extends State<DragDropBucketActivity> {
  final _remaining = <String>[];
  final _bucketA = <String>[];
  final _bucketB = <String>[];
  String? _feedback;
  bool _done = false;

  @override
  void initState() {
    super.initState();
    _remaining.addAll(widget.activity.dragItems);
  }

  void _drop(String item, String bucket) {
    if (_done) return;
    final expected = widget.activity.dragCorrectBucket[item] ?? 'B';
    final ok = (bucket == 'A' && expected == 'A') || (bucket == 'B' && expected == 'B');
    setState(() {
      _remaining.remove(item);
      if (bucket == 'A') {
        _bucketA.add(item);
      } else {
        _bucketB.add(item);
      }
      _feedback = ok
          ? 'Right bucket — needs are must-haves, wants are extras.'
          : 'Needs = must-haves (food, school). Wants = fun extras.';
    });
    if (_remaining.isEmpty) {
      setState(() => _done = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Sort each item — needs keep you going, wants are optional fun.',
          style: LQTypography.caption(c).copyWith(color: c.inkSoft),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: LQSpacing.md),
        Row(
          children: [
            Expanded(
              child: _BucketColumn(
                colors: c,
                label: widget.activity.dragTargetA,
                hint: _bucketHint(widget.activity.dragTargetA),
                accent: c.success,
                items: _bucketA,
                bucketId: 'A',
                onDrop: _drop,
              ),
            ),
            const SizedBox(width: LQSpacing.sm),
            Expanded(
              child: _BucketColumn(
                colors: c,
                label: widget.activity.dragTargetB,
                hint: _bucketHint(widget.activity.dragTargetB),
                accent: c.coral,
                items: _bucketB,
                bucketId: 'B',
                onDrop: _drop,
              ),
            ),
          ],
        ),
        const SizedBox(height: LQSpacing.md),
        Wrap(
          spacing: LQSpacing.sm,
          runSpacing: LQSpacing.sm,
          alignment: WrapAlignment.center,
          children: _remaining.map((item) {
            return Draggable<String>(
              data: item,
              feedback: Material(
                color: Colors.transparent,
                child: _Chip(colors: c, label: item, dragging: true),
              ),
              childWhenDragging: Opacity(
                opacity: 0.35,
                child: _Chip(colors: c, label: item),
              ),
              child: _Chip(colors: c, label: item),
            );
          }).toList(),
        ),
        if (_feedback != null) ...[
          const SizedBox(height: LQSpacing.md),
          Text(_feedback!, style: LQTypography.bodySm(c), textAlign: TextAlign.center),
        ],
        if (_done) ...[
          const SizedBox(height: LQSpacing.lg),
          LQButton(
            label: 'Continue',
            colors: c,
            expanded: true,
            onPressed: widget.onComplete,
          ),
        ],
      ],
    );
  }
}

class _BucketColumn extends StatelessWidget {
  const _BucketColumn({
    required this.colors,
    required this.label,
    this.hint,
    required this.accent,
    required this.items,
    required this.bucketId,
    required this.onDrop,
  });

  final LQColors colors;
  final String label;
  final String? hint;
  final Color accent;
  final List<String> items;
  final String bucketId;
  final void Function(String item, String bucket) onDrop;

  @override
  Widget build(BuildContext context) {
    return DragTarget<String>(
      onAcceptWithDetails: (d) => onDrop(d.data, bucketId),
      builder: (context, candidate, rejected) {
        final active = candidate.isNotEmpty;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(LQSpacing.md),
          constraints: const BoxConstraints(minHeight: 100),
          decoration: BoxDecoration(
            color: accent.withValues(alpha: active ? 0.22 : 0.1),
            borderRadius: BorderRadius.circular(LQRadius.control),
            border: Border.all(color: accent, width: active ? 2.5 : 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                label,
                style: LQTypography.label(colors).copyWith(
                  color: accent,
                  fontWeight: FontWeight.w800,
                ),
                textAlign: TextAlign.center,
              ),
              if (hint != null) ...[
                const SizedBox(height: 2),
                Text(
                  hint!,
                  style: LQTypography.micro(colors).copyWith(color: colors.inkSoft),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: LQSpacing.sm),
              ...items.map(
                (i) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(i, style: LQTypography.bodySm(colors)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.colors, required this.label, this.dragging = false});

  final LQColors colors;
  final String label;
  final bool dragging;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(LQRadius.chip),
        border: Border.all(color: colors.brand),
        boxShadow: dragging ? LQElevation.e2(colors.ink) : null,
      ),
      child: Text(label, style: LQTypography.bodySm(colors)),
    );
  }
}

class SliderQuizActivity extends StatefulWidget {
  const SliderQuizActivity({
    super.key,
    required this.activity,
    required this.colors,
    required this.onAnswer,
  });

  final StageActivity activity;
  final LQColors colors;
  final ValueChanged<bool> onAnswer;

  @override
  State<SliderQuizActivity> createState() => _SliderQuizActivityState();
}

class _SliderQuizActivityState extends State<SliderQuizActivity> {
  late int _value;
  bool? _correct;

  @override
  void initState() {
    super.initState();
    _value = widget.activity.sliderMin;
  }

  @override
  void didUpdateWidget(covariant SliderQuizActivity oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.activity.prompt != widget.activity.prompt) {
      _value = widget.activity.sliderMin;
      _correct = null;
    }
  }

  void _check() {
    if (_correct != null) return;
    final ok = _value == widget.activity.sliderCorrect;
    setState(() => _correct = ok);
    if (!ok) {
      widget.onAnswer(false);
    }
  }

  void _continue() {
    widget.onAnswer(true);
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.colors;
    final a = widget.activity;
    final divisions = (a.sliderMax - a.sliderMin).clamp(1, 100);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '${a.sliderUnit} $_value',
          style: LQTypography.display(c).copyWith(color: c.brand, fontSize: 40),
          textAlign: TextAlign.center,
        ),
        Slider(
          value: _value.toDouble().clamp(a.sliderMin.toDouble(), a.sliderMax.toDouble()),
          min: a.sliderMin.toDouble(),
          max: a.sliderMax.toDouble(),
          divisions: divisions,
          activeColor: c.brand,
          onChanged: _correct == null
              ? (v) => setState(() => _value = v.round())
              : null,
        ),
        if (_correct == null) ...[
          const SizedBox(height: LQSpacing.sm),
          LQButton(
            label: 'Check',
            colors: c,
            expanded: true,
            onPressed: _check,
          ),
        ] else if (_correct!) ...[
          const SizedBox(height: LQSpacing.sm),
          LQQuizChoice(
            label: 'Correct — ${a.sliderUnit} ${a.sliderCorrect}',
            colors: c,
            state: QuizChoiceState.correct,
            onTap: null,
          ).animate().fadeIn(),
          const SizedBox(height: LQSpacing.md),
          LQButton(
            label: 'Continue',
            colors: c,
            expanded: true,
            onPressed: _continue,
          ),
        ] else ...[
          const SizedBox(height: LQSpacing.sm),
          LQQuizChoice(
            label: 'Try ${a.sliderUnit} ${a.sliderCorrect}',
            colors: c,
            state: QuizChoiceState.incorrect,
            onTap: null,
          ).animate().fadeIn(),
          const SizedBox(height: LQSpacing.md),
          LQButton(
            label: 'Try again',
            colors: c,
            variant: LQButtonVariant.secondary,
            expanded: true,
            onPressed: () => setState(() {
              _correct = null;
            }),
          ),
        ],
      ],
    );
  }
}

class ScenarioTapActivity extends StatefulWidget {
  const ScenarioTapActivity({
    super.key,
    required this.activity,
    required this.colors,
    required this.correctIndex,
    required this.onSelect,
  });

  final StageActivity activity;
  final LQColors colors;
  final int correctIndex;
  final ValueChanged<int> onSelect;

  @override
  State<ScenarioTapActivity> createState() => _ScenarioTapActivityState();
}

class _ScenarioTapActivityState extends State<ScenarioTapActivity> {
  int? _picked;

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors;
    final correct = _picked == widget.correctIndex;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.activity.sceneText != null)
          Container(
            padding: const EdgeInsets.all(LQSpacing.lg),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(LQRadius.card),
              border: Border.all(color: colors.border),
            ),
            child: Text(widget.activity.sceneText!, style: LQTypography.body(colors)),
          ),
        const SizedBox(height: LQSpacing.lg),
        ...List.generate(widget.activity.options.length, (i) {
          final picked = _picked == i;
          final state = _picked == null
              ? QuizChoiceState.idle
              : picked
                  ? (i == widget.correctIndex
                      ? QuizChoiceState.correct
                      : QuizChoiceState.incorrect)
                  : QuizChoiceState.idle;
          return Padding(
            padding: const EdgeInsets.only(bottom: LQSpacing.sm),
            child: LQQuizChoice(
              label: widget.activity.options[i],
              colors: colors,
              state: state,
              onTap: _picked == null ? () => setState(() => _picked = i) : null,
            ),
          );
        }),
        if (_picked != null) ...[
          const SizedBox(height: LQSpacing.md),
          LQButton(
            label: correct ? 'Continue' : 'Try again',
            colors: colors,
            expanded: true,
            onPressed: () {
              if (correct) {
                widget.onSelect(widget.correctIndex);
              } else {
                setState(() => _picked = null);
              }
            },
          ),
        ],
      ],
    );
  }
}

class CardSortActivity extends StatefulWidget {
  const CardSortActivity({
    super.key,
    required this.activity,
    required this.colors,
    required this.onComplete,
  });

  final StageActivity activity;
  final LQColors colors;
  final VoidCallback onComplete;

  @override
  State<CardSortActivity> createState() => _CardSortActivityState();
}

class _CardSortActivityState extends State<CardSortActivity> {
  int _index = 0;
  int _sorted = 0;
  bool _done = false;

  void _swipe(bool higher) {
    if (_done) return;
    setState(() {
      _sorted++;
      _index = (_index + 1).clamp(0, widget.activity.options.length);
      if (_sorted >= widget.activity.options.length) _done = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.colors;
    if (_done) {
      return Column(
        children: [
          Text('Sorted!', style: LQTypography.h3(c), textAlign: TextAlign.center),
          const SizedBox(height: LQSpacing.lg),
          LQButton(
            label: 'Continue',
            colors: c,
            expanded: true,
            onPressed: widget.onComplete,
          ),
        ],
      );
    }
    if (_index >= widget.activity.options.length) {
      return const SizedBox.shrink();
    }
    final card = widget.activity.options[_index];
    return Column(
      children: [
        Text(
          'Swipe: ${widget.activity.dragTargetA} ← → ${widget.activity.dragTargetB}',
          style: LQTypography.caption(c),
        ),
        const SizedBox(height: LQSpacing.lg),
        GestureDetector(
          onHorizontalDragEnd: (d) {
            if (d.primaryVelocity == null) return;
            _swipe(d.primaryVelocity! > 0);
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(LQSpacing.xl),
            decoration: BoxDecoration(
              color: c.surface,
              borderRadius: BorderRadius.circular(LQRadius.card),
              boxShadow: LQElevation.e2(c.ink),
            ),
            child: Text(card, style: LQTypography.h3(c), textAlign: TextAlign.center),
          ),
        ).animate().fadeIn().slideY(begin: 0.08, end: 0),
      ],
    );
  }
}
