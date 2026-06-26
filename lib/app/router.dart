import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/games/concept/concept_game_practice_screen.dart';
import '../features/games/concept/concept_game_types.dart';
import '../features/games/concept/concept_games_hub_screen.dart';
import '../features/money/money_hub_screen.dart';
import '../features/faq/faq_screen.dart';
import '../features/city/city_screen.dart';
import '../features/home/home_screen.dart';
import '../features/learn/learn_screen.dart';
import '../features/learn/lesson_loop_screen.dart';
import '../features/onboarding/age_screen.dart';
import '../features/onboarding/guide_pick_screen.dart';
import '../features/onboarding/onboarding_finish_screen.dart';
import '../features/onboarding/onboarding_shell.dart';
import '../features/onboarding/placement_result_screen.dart';
import '../features/onboarding/screening_screen.dart';
import '../features/onboarding/start_point_screen.dart';
import '../features/onboarding/auth_service.dart';
import '../features/progress/progress_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/showcase/showcase_screen.dart';
import '../features/shell/kid_shell_screen.dart';
import '../features/splash/splash_screen.dart';
import '../features/wallet/wallet_screen.dart';
import 'bootstrap/firebase_providers.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

class _RouterRefresh extends ChangeNotifier {
  _RouterRefresh(Ref ref) {
    ref.listen(authProvider, (_, __) => notifyListeners());
    ref.listen(userProfileProvider, (_, __) => notifyListeners());
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = _RouterRefresh(ref);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    refreshListenable: refresh,
    redirect: (context, state) {
      final path = state.uri.path;
      if (path == '/' || path == '/showcase') return null;

      final user = ref.read(authProvider).valueOrNull;
      final profile = ref.read(userProfileProvider).valueOrNull;

      if (user == null && path.startsWith('/onboarding')) {
        return '/';
      }

      if (profile?.onboardingComplete == true && path.startsWith('/onboarding')) {
        return '/home';
      }

      if (user != null &&
          profile != null &&
          !profile.onboardingComplete &&
          !path.startsWith('/onboarding')) {
        return '/onboarding/age';
      }

      if (path == '/progress') return '/awards';

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/showcase',
        builder: (context, state) => const ShowcaseScreen(),
      ),
      GoRoute(
        path: '/onboarding/age',
        pageBuilder: (context, state) => lqSharedAxisPage(
          key: state.pageKey,
          child: const AgeScreen(),
        ),
      ),
      GoRoute(
        path: '/onboarding/guide',
        pageBuilder: (context, state) => lqSharedAxisPage(
          key: state.pageKey,
          child: const GuidePickScreen(),
        ),
      ),
      GoRoute(
        path: '/onboarding/start',
        pageBuilder: (context, state) => lqSharedAxisPage(
          key: state.pageKey,
          child: const StartPointScreen(),
        ),
      ),
      GoRoute(
        path: '/onboarding/screening',
        pageBuilder: (context, state) => lqSharedAxisPage(
          key: state.pageKey,
          child: const ScreeningScreen(),
        ),
      ),
      GoRoute(
        path: '/onboarding/placement',
        pageBuilder: (context, state) => lqSharedAxisPage(
          key: state.pageKey,
          child: const PlacementResultScreen(),
        ),
      ),
      GoRoute(
        path: '/onboarding/finish',
        pageBuilder: (context, state) {
          final level =
              int.tryParse(state.uri.queryParameters['level'] ?? '1') ?? 1;
          return lqSharedAxisPage(
            key: state.pageKey,
            child: OnboardingFinishScreen(level: level),
          );
        },
      ),
      GoRoute(
        path: '/city',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const CityScreen(),
      ),
      GoRoute(
        path: '/money',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const MoneyHubScreen(),
      ),
      GoRoute(
        path: '/wallet',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const WalletScreen(),
      ),
      GoRoute(
        path: '/concept-games',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ConceptGamesHubScreen(),
        routes: [
          GoRoute(
            path: ':gameId',
            builder: (context, state) => ConceptGamePracticeScreen(
              gameId: conceptGameFromParam(state.pathParameters['gameId']),
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/faq',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const FaqScreen(),
      ),
      GoRoute(
        path: '/lesson/:lessonId',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          final lessonId = state.pathParameters['lessonId']!;
          return lqSharedAxisPage(
            key: state.pageKey,
            child: LessonLoopScreen(lessonId: lessonId),
          );
        },
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return KidShellScreen(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/learn',
                builder: (context, state) => const LearnScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/city',
                builder: (context, state) => const CityScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/awards',
                builder: (context, state) => const ProgressScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

GoRouter createRouter(WidgetRef ref) => ref.read(routerProvider);
