import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/tokens/lq_tokens.dart';
import '../../core/tokens/lq_typography.dart';
import '../../design/lq_button.dart';
import '../../design/lq_canvas.dart';

/// Math + hold gate — child cannot pass easily (BIBLE §9).
class ParentalGate extends ConsumerStatefulWidget {
  const ParentalGate({
    super.key,
    required this.colors,
    required this.onUnlocked,
  });

  final LQColors colors;
  final VoidCallback onUnlocked;

  @override
  ConsumerState<ParentalGate> createState() => _ParentalGateState();
}

class _ParentalGateState extends ConsumerState<ParentalGate> {
  late int _a;
  late int _b;
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _resetQuestion();
  }

  void _resetQuestion() {
    _a = 12 + DateTime.now().millisecond % 20;
    _b = 15 + DateTime.now().second % 25;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _checkAnswer() {
    final answer = int.tryParse(_controller.text.trim());
    if (answer == _a + _b) {
      widget.onUnlocked();
    } else {
      _controller.clear();
      _resetQuestion();
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'That\'s not quite right. Adults only past this point.',
            style: LQTypography.bodySm(widget.colors),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return LQCanvas(
      colors: widget.colors,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(LQSpacing.gutter),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Grown-up area', style: LQTypography.display(widget.colors)),
              const SizedBox(height: LQSpacing.sm),
              Text(
                'This section is for parents and caregivers.',
                style: LQTypography.bodySm(widget.colors),
              ),
              const SizedBox(height: LQSpacing.xxxl),
              Text(
                'What is $_a + $_b?',
                style: LQTypography.h2(widget.colors),
              ),
              const SizedBox(height: LQSpacing.lg),
              TextField(
                controller: _controller,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Answer',
                  filled: true,
                  fillColor: widget.colors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(LQRadius.control),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: LQSpacing.lg),
              LQButton(
                label: 'Continue',
                colors: widget.colors,
                expanded: true,
                onPressed: _checkAnswer,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
