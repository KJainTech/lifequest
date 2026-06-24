import 'dart:html' as html;

// Ensures Firebase web implementations are bundled (fixes Safari / stale SW issues).
import 'package:cloud_firestore_web/cloud_firestore_web.dart';
import 'package:cloud_functions_web/cloud_functions_web.dart';
import 'package:firebase_auth_web/firebase_auth_web.dart';
import 'package:firebase_core_web/firebase_core_web.dart';

Future<void> configureFirebaseWeb() async {
  // Imports above register web Firebase plugins with the FlutterFire core.
}

bool get isSafariWeb {
  final ua = html.window.navigator.userAgent.toLowerCase();
  return ua.contains('safari') &&
      !ua.contains('chrome') &&
      !ua.contains('crios') &&
      !ua.contains('fxios');
}

Future<void> clearWebAppCaches() async {
  if (html.window.navigator.serviceWorker != null) {
    final regs = await html.window.navigator.serviceWorker!.getRegistrations();
    for (final reg in regs) {
      await reg.unregister();
    }
  }
  final cacheKeys = await html.window.caches?.keys();
  if (cacheKeys != null) {
    for (final key in cacheKeys) {
      await html.window.caches?.delete(key);
    }
  }
}

Future<void> hardRefreshWebApp() async {
  await clearWebAppCaches();
  final uri = Uri.base.replace(
    queryParameters: {
      ...Uri.base.queryParameters,
      'fresh': DateTime.now().millisecondsSinceEpoch.toString(),
    },
  );
  html.window.location.href = uri.toString();
}
