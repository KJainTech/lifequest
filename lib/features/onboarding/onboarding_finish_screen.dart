import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/lq_theme.dart';
import '../../design/lq_button.dart';
import '../../design/lq_canvas.dart';
import 'onboarding_complete.dart';

/// Saves profile and routes to home (beginning path or post-screening).
class OnboardingFinishScreen extends ConsumerStatefulWidget {
  const OnboardingFinishScreen({super.key, required this.level});

  final int level;

  @override
  ConsumerState<OnboardingFinishScreen> createState() =>
      _OnboardingFinishScreenState();
}

class _OnboardingFinishScreenState extends ConsumerState<OnboardingFinishScreen> {
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _save();
  }

  Future<void> _save() async {
    try {
      await completeOnboarding(ref: ref, proficiencyLevel: widget.level);
      if (mounted) context.go('/home');
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = ref.watch(lqColorsProvider);

    return Scaffold(
      body: LQCanvas(
        colors: colors,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: _error != null
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Let\'s try that again.', style: TextStyle(color: colors.ink)),
                      const SizedBox(height: 16),
                      LQButton(
                        label: 'Retry',
                        colors: colors,
                        onPressed: () {
                          setState(() {
                            _loading = true;
                            _error = null;
                          });
                          _save();
                        },
                      ),
                    ],
                  )
                : _loading
                    ? const CircularProgressIndicator()
                    : const SizedBox.shrink(),
          ),
        ),
      ),
    );
  }
}
