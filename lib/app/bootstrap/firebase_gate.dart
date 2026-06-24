import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'firebase_web_config.dart';

/// Shown when Firebase fails to initialize (Safari cache / in-app browsers).
class FirebaseBootstrapErrorApp extends StatelessWidget {
  const FirebaseBootstrapErrorApp({super.key, required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    final safari = kIsWeb && isSafariWeb;

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
                      ? safari
                          ? 'Safari may be using an old cached version. Tap "Clear cache & retry" below, or open a Private window and visit lifequest-97bf9.web.app'
                          : 'Open lifequest-97bf9.web.app in Safari or Chrome (not Instagram/WhatsApp in-app browser).'
                      : 'Check your connection and try again.',
                  textAlign: TextAlign.center,
                ),
                if (kIsWeb) ...[
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: hardRefreshWebApp,
                    child: const Text('Clear cache & retry'),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: hardRefreshWebApp,
                    child: const Text('Hard refresh page'),
                  ),
                ],
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
