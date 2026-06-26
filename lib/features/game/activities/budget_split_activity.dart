import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/tokens/lq_tokens.dart';
import '../../../core/tokens/lq_typography.dart';
import '../../../design/lq_button.dart';

/// Needs / Wants / Save sliders that sum to 100 — values stay until user changes them.
class BudgetSplitActivity extends StatefulWidget {
  const BudgetSplitActivity({
    super.key,
    required this.colors,
    required this.prompt,
    required this.onComplete,
  });

  final LQColors colors;
  final String prompt;
  final VoidCallback onComplete;

  @override
  State<BudgetSplitActivity> createState() => _BudgetSplitActivityState();
}

class _BudgetSplitActivityState extends State<BudgetSplitActivity> {
  int _needs = 50;
  int _wants = 30;
  int _save = 20;
  bool? _correct;

  int get _total => _needs + _wants + _save;

  void _setNeeds(int v) => setState(() => _needs = v.clamp(0, 100));
  void _setWants(int v) => setState(() => _wants = v.clamp(0, 100));
  void _setSave(int v) => setState(() => _save = v.clamp(0, 100));

  void _check() {
    final ok = _total == 100 && _needs >= 40 && _save >= 10;
    setState(() => _correct = ok);
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.colors;
    final totalOk = _total == 100;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Split 100% across needs, wants, and save',
          style: LQTypography.caption(c).copyWith(color: c.inkSoft),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: LQSpacing.md),
        _SplitRow(
          colors: c,
          label: 'Needs',
          value: _needs,
          accent: c.success,
          enabled: _correct == null,
          onChanged: _setNeeds,
        ),
        _SplitRow(
          colors: c,
          label: 'Wants',
          value: _wants,
          accent: c.coral,
          enabled: _correct == null,
          onChanged: _setWants,
        ),
        _SplitRow(
          colors: c,
          label: 'Save',
          value: _save,
          accent: c.brand,
          enabled: _correct == null,
          onChanged: _setSave,
        ),
        const SizedBox(height: LQSpacing.sm),
        Text(
          'Total: $_total%',
          style: LQTypography.label(c).copyWith(
            color: totalOk ? c.success : c.warn,
          ),
          textAlign: TextAlign.center,
        ),
        if (_correct == null) ...[
          const SizedBox(height: LQSpacing.lg),
          LQButton(
            label: 'Confirm split',
            colors: c,
            expanded: true,
            enabled: totalOk,
            onPressed: _check,
          ),
        ] else if (_correct!) ...[
          const SizedBox(height: LQSpacing.md),
          Text(
            'Strong budget split!',
            style: LQTypography.bodySm(c).copyWith(color: c.success),
            textAlign: TextAlign.center,
          ).animate().fadeIn(),
          const SizedBox(height: LQSpacing.md),
          LQButton(
            label: 'Continue',
            colors: c,
            expanded: true,
            onPressed: widget.onComplete,
          ),
        ] else ...[
          const SizedBox(height: LQSpacing.md),
          Text(
            'Try needs ~50%, wants ~30%, save ~20% (must total 100%).',
            style: LQTypography.bodySm(c),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: LQSpacing.md),
          LQButton(
            label: 'Try again',
            colors: c,
            variant: LQButtonVariant.secondary,
            expanded: true,
            onPressed: () => setState(() {
              _correct = null;
              _needs = 50;
              _wants = 30;
              _save = 20;
            }),
          ),
        ],
      ],
    );
  }
}

class _SplitRow extends StatelessWidget {
  const _SplitRow({
    required this.colors,
    required this.label,
    required this.value,
    required this.accent,
    required this.enabled,
    required this.onChanged,
  });

  final LQColors colors;
  final String label;
  final int value;
  final Color accent;
  final bool enabled;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: LQSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(label, style: LQTypography.label(colors).copyWith(color: accent)),
              const Spacer(),
              Text('$value%', style: LQTypography.h3(colors).copyWith(color: accent)),
            ],
          ),
          Slider(
            value: value.toDouble(),
            min: 0,
            max: 100,
            divisions: 100,
            activeColor: accent,
            onChanged: enabled ? (v) => onChanged(v.round()) : null,
          ),
        ],
      ),
    );
  }
}

bool promptUsesBudgetSplit(String prompt) {
  final p = prompt.toLowerCase();
  return p.contains('100') &&
      p.contains('%') &&
      (p.contains('need') || p.contains('want') || p.contains('save'));
}
