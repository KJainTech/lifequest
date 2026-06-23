import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/bootstrap/firebase_bootstrap.dart';
import 'app/bootstrap/firebase_gate.dart';
import 'app/locale/locale_provider.dart';
import 'app/router.dart';
import 'app/theme/lq_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  Object? firebaseError;
  try {
    await bootstrapFirebase();
  } catch (e) {
    firebaseError = e;
  }

  runApp(
    ProviderScope(
      child: firebaseError != null
          ? FirebaseBootstrapErrorApp(error: firebaseError)
          : const LifeQuestApp(),
    ),
  );
}

class LifeQuestApp extends ConsumerWidget {
  const LifeQuestApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(lqColorsProvider);
    final router = ref.watch(routerProvider);
    final localeCode = ref.watch(appLocaleProvider);

    return MaterialApp.router(
      title: 'LifeQuest',
      debugShowCheckedModeBanner: false,
      theme: buildLQTheme(colors),
      locale: Locale(localeCode),
      supportedLocales: const [
        Locale('en'),
        Locale('ar'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: router,
    );
  }
}
