import 'package:flashcards_app/ui/deck_detail_screen.dart';
import 'package:flashcards_app/ui/edit_card_screen.dart';
import 'package:flashcards_app/ui/home_screen.dart';
import 'package:flashcards_app/ui/notifications_screen.dart';
import 'package:flashcards_app/ui/performance_settings_screen.dart';
import 'package:flashcards_app/ui/review_screen.dart';
import 'package:flashcards_app/ui/stats_screen.dart';
import 'package:flashcards_app/ui/theme_settings_screen.dart';
import 'package:flashcards_app/ui/dashboard_screen.dart';
import 'package:flashcards_app/ui/study_modes_screen.dart';
import 'package:flashcards_app/ui/quiz_mode_screen.dart';
import 'package:flashcards_app/ui/speed_round_screen.dart';
import 'package:flashcards_app/viewmodels/review_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flashcards_app/ui/onboarding_screen.dart';
import 'package:flashcards_app/ui/components/main_layout.dart';
import 'package:flashcards_app/domain/usecases/card_usecases.dart';
import 'package:flashcards_app/domain/usecases/review_usecases.dart';
import 'package:flashcards_app/domain/entities/deck.dart' as domain;
import 'package:flashcards_app/domain/entities/card.dart' as domain;

class AppRouter {
  static final GoRouter router = GoRouter(
    debugLogDiagnostics: true,
    redirect: (BuildContext context, GoRouterState state) async {
      final prefs = await SharedPreferences.getInstance();
      final seen = prefs.getBool('seenOnboarding') ?? false;
      final loc = state.uri.toString();
      if (!seen && loc != '/onboarding') {
        return '/onboarding';
      }
      if (seen && loc == '/onboarding') {
        return '/';
      }
      return null;
    },
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(child: Text('Page not found: ${state.error}\n${state.uri}')),
    ),
    routes: <RouteBase>[
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/',
        name: 'dashboard',
        builder: (BuildContext context, GoRouterState state) =>
            const MainLayout(child: DashboardScreen()),
        routes: [
          GoRoute(
            path: 'decks',
            name: 'home',
            builder: (context, state) => const MainLayout(child: HomeScreen()),
            routes: <RouteBase>[
              GoRoute(
                name: 'deckDetail',
                path: 'deck/:deckId',                builder: (context, state) {
                  final deck = state.extra
                      as domain.Deck?; // Use domain.Deck
                  if (deck == null) {
                    return _navError(state.uri);
                  }
                  return MainLayout(child: DeckDetailScreen(deck: deck));
                },
                routes: [                  GoRoute(
                    name: 'newCard',
                    path: 'card/new',
                    builder: (context, state) {
                      final deck = state.extra
                          as domain.Deck?; // Use domain.Deck
                      if (deck == null) {
                        return _navError(state.uri);
                      }
                      // EditCardScreen expects domain.Deck and domain.Card?
                      return MainLayout(
                          child: EditCardScreen(deck: deck));
                    },
                  ),                  GoRoute(
                    name: 'editCard',
                    path: 'card/:cardId/edit',
                    builder: (context, state) {
                      final map = state.extra as Map<String, dynamic>?;
                      final deck = map?['deck']
                          as domain.Deck?; // Use domain.Deck
                      final card = map?['card']
                          as domain.Card?; // Use domain.Card
                      if (deck == null || card == null) {
                        return _navError(state.uri);
                      }
                      // EditCardScreen expects domain.Deck and domain.Card?
                      return MainLayout(
                          child:
                              EditCardScreen(deck: deck, card: card));
                    },
                  ),                  GoRoute(
                    name: 'review',
                    path: 'review',
                    builder: (context, state) {
                      final deck = state.extra
                          as domain.Deck?; // Use domain.Deck
                      if (deck == null) {
                        return _navError(state.uri);
                      }                      return ChangeNotifierProvider<ReviewViewModel>(
                        create: (ctx) => ReviewViewModel(
                            getCardsByDeckUseCase: ctx.read<GetCardsByDeckUseCase>(),
                            reviewCardUseCase: ctx.read<ReviewCardUseCase>(),
                            deckId: deck.id),
                        child: MainLayout(
                            child: ReviewScreen(
                                deckId: deck.id, deckName: deck.name)),
                      );
                    },
                  ),                  GoRoute(
                    name: 'studyModes',
                    path: 'study',
                    builder: (context, state) {
                      final deck = state.extra
                          as domain.Deck?; // Use domain.Deck
                      if (deck == null) {
                        return _navError(state.uri);
                      }
                      return StudyModesScreen(deck: deck);
                    },
                  ),
                  GoRoute(
                    name: 'quizMode',
                    path: 'quiz',
                    builder: (context, state) {
                      final deck = state.extra
                          as domain.Deck?; // Use domain.Deck
                      if (deck == null) {
                        return _navError(state.uri);
                      }
                      return QuizModeScreen(
                          deckId: deck.id, deckName: deck.name);
                    },
                  ),
                  GoRoute(
                    name: 'speedRound',
                    path: 'speed',
                    builder: (context, state) {
                      final deck = state.extra
                          as domain.Deck?; // Use domain.Deck
                      if (deck == null) {
                        return _navError(state.uri);
                      }
                      return SpeedRoundScreen(
                          deckId: deck.id, deckName: deck.name);
                    },
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            name: 'statsGlobal',
            path: 'stats',
            builder: (context, state) => const MainLayout(child: StatsScreen()),
            routes: [
              GoRoute(
                  name: 'statsDeck',
                  path: 'deck/:deckId',
                  builder: (context, state) {
                    final id = state.pathParameters['deckId'];
                    if (id == null) {
                      return _navError(state.uri);
                    }
                    return MainLayout(
                        child: StatsScreen(
                            deckId: int.parse(id),
                            deckName: state.uri.queryParameters['deckName']));
                  }),
            ],
          ),
          GoRoute(
            name: 'notifications',
            path: 'notifications',
            builder: (context, state) =>
                const MainLayout(child: NotificationsScreen()),
          ),
          GoRoute(
            name: 'settings',
            path: 'settings',
            redirect: (ctx, state) {
              if (state.uri.toString() == '/settings') {
                return '/settings/performance';
              }
              return null;
            },
            routes: [
              GoRoute(
                  name: 'themeSettings',
                  path: 'theme',
                  builder: (ctx, state) =>
                      const MainLayout(child: ThemeSettingsScreen())),
              GoRoute(
                  name: 'performanceSettings',
                  path: 'performance',
                  builder: (ctx, state) =>
                      const MainLayout(child: PerformanceSettingsScreen())),
            ],
          ),
        ],
      ),
      GoRoute(
          path: '/navError',
          builder: (ctx, state) => Scaffold(
              appBar: AppBar(title: const Text('Erreur')),
              body: Center(child: Text('Navigation error: ${state.uri}')))),
    ],
  );

  static Scaffold _navError(Uri uri) => Scaffold(
      appBar: AppBar(title: const Text('Navigation Error')),
      body: Center(child: Text('Navigation error for path: $uri')));
}
