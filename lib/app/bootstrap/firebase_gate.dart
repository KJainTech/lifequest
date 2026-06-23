import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Shown when Firebase fails to initialize (common in in-app browsers).
class FirebaseBootstrapErrorApp extends StatelessWidget {
  const FirebaseBootstrapErrorApp({super.key, required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.wifi_off_rounded, size: 48),
                const SizedBox(height: 16),
                const Text(
                  'Could not connect',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  kIsWeb
                      ? 'Open lifequest-97bf9.web.app in Safari or Chrome instead of an in-app browser (Instagram, WhatsApp, etc.).'
                      : 'Check your connection and try again.',
                  textAlign: TextAlign.center,
                ),
                if (kDebugMode) ...[
                  const SizedBox(height: 16),
                  Text(
                    error.toString(),
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
