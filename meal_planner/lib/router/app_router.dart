import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meal_planner/core/config/legal_urls.dart';
import 'package:meal_planner/core/config/share_urls.dart';
import 'package:meal_planner/core/deep_links/deep_link_listener.dart';
import 'package:meal_planner/core/locale/l10n_extension.dart';
import 'package:meal_planner/features/auth/domain/auth_state.dart';
import 'package:meal_planner/features/auth/presentation/auth_provider.dart';
import 'package:meal_planner/features/auth/presentation/forgot_password_screen.dart';
import 'package:meal_planner/features/auth/presentation/login_screen.dart';
import 'package:meal_planner/features/auth/presentation/register_screen.dart';
import 'package:meal_planner/features/feedback/presentation/admin_feedback_screen.dart';
import 'package:meal_planner/features/feedback/presentation/send_feedback_screen.dart';
import 'package:meal_planner/features/household/presentation/create_household_screen.dart';
import 'package:meal_planner/features/household/presentation/household_screen.dart';
import 'package:meal_planner/features/household/presentation/join_household_screen.dart';
import 'package:meal_planner/features/planner/presentation/planner_screen.dart';
import 'package:meal_planner/features/profile/presentation/delete_account_screen.dart';
import 'package:meal_planner/features/profile/presentation/edit_profile_screen.dart';
import 'package:meal_planner/features/profile/presentation/legal_document_screen.dart';
import 'package:meal_planner/features/profile/presentation/profile_provider.dart';
import 'package:meal_planner/features/profile/presentation/profile_screen.dart';
import 'package:meal_planner/features/recipes/presentation/cooking_glossary_screen.dart';
import 'package:meal_planner/features/recipes/presentation/recipe_detail_screen.dart';
import 'package:meal_planner/features/recipes/presentation/recipe_form_screen.dart';
import 'package:meal_planner/features/recipes/presentation/recipe_list_screen.dart';
import 'package:meal_planner/features/recipes/presentation/share_private_link_screen.dart';
import 'package:meal_planner/features/shopping/presentation/shopping_list_screen.dart';
import 'package:meal_planner/features/social/presentation/explore_screen.dart';
import 'package:meal_planner/features/social/presentation/feed_screen.dart';
import 'package:meal_planner/features/social/presentation/public_screens.dart';
import 'package:meal_planner/router/home_shell.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

/// Keeps a single [GoRouter] instance and only re-runs redirects when auth /
/// admin profile access relevant state changes.
final routerProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier<int>(0);
  ref.onDispose(refresh.dispose);

  ref.listen<AsyncValue<AuthState>>(authStateProvider, (prev, next) {
    final prevAuth = prev?.valueOrNull is AuthAuthenticated;
    final nextAuth = next.valueOrNull is AuthAuthenticated;
    final prevExpired = prev?.valueOrNull is AuthUnauthenticated &&
        (prev!.valueOrNull! as AuthUnauthenticated).sessionExpired;
    final nextExpired = next.valueOrNull is AuthUnauthenticated &&
        (next.valueOrNull! as AuthUnauthenticated).sessionExpired;
    if (prevAuth != nextAuth || prevExpired != nextExpired) {
      refresh.value++;
    }
  });

  ref.listen(profileProvider, (prev, next) {
    final prevAdmin = prev?.valueOrNull?.isAdmin ?? false;
    final nextAdmin = next.valueOrNull?.isAdmin ?? false;
    final prevLoading = prev?.isLoading == true && prev?.hasValue != true;
    final nextLoading = next.isLoading && !next.hasValue;
    if (prevAdmin != nextAdmin || prevLoading != nextLoading) {
      refresh.value++;
    }
  });

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/',
    refreshListenable: refresh,
    onException: (context, state, router) {
      final mapped = ShareUrls.appLocationForIncomingUri(state.uri);
      if (mapped == null) return;

      final authState = ref.read(authStateProvider);
      final isAuthenticated = authState.maybeWhen(
        data: (value) => value is AuthAuthenticated,
        orElse: () => false,
      );
      if (!isAuthenticated) {
        final pending = ref.read(pendingShareLinkProvider);
        if (pending != state.uri) {
          ref.read(pendingShareLinkProvider.notifier).state = state.uri;
          unawaited(PendingShareLinkStore.save(state.uri));
        }
        router.go('/auth/login');
        return;
      }
      router.go(mapped);
    },
    redirect: (context, state) {
      final authState = ref.read(authStateProvider);
      final profileAsync = ref.read(profileProvider);

      final isLoggingIn = state.matchedLocation.startsWith('/auth');
      final isLegal = state.matchedLocation.startsWith('/legal');
      final isShareResolve = state.matchedLocation.startsWith('/share/');
      final isAuthenticated = authState.maybeWhen(
        data: (value) => value is AuthAuthenticated,
        orElse: () => false,
      );

      if (state.matchedLocation.startsWith('/home/profile/admin')) {
        // Wait until profile finished loading before denying access.
        if (profileAsync.isLoading && !profileAsync.hasValue) {
          return null;
        }
        if (profileAsync.valueOrNull?.isAdmin != true) {
          return '/home/profile';
        }
      }

      final shareLocation = ShareUrls.appLocationForIncomingUri(state.uri);
      final isIncomingSharePath = state.uri.path.startsWith('/p/') ||
          state.uri.path.startsWith('/r/') ||
          state.uri.path.startsWith('/h/') ||
          ShareUrls.isShareHost(state.uri.host);

      if (shareLocation != null && (isIncomingSharePath || isShareResolve)) {
        if (!isAuthenticated) {
          // Preserve for DeepLinkListener after login.
          final pending = ref.read(pendingShareLinkProvider);
          if (pending != state.uri) {
            ref.read(pendingShareLinkProvider.notifier).state = state.uri;
            unawaited(PendingShareLinkStore.save(state.uri));
          }
          return isLoggingIn ? null : '/auth/login';
        }
        if (isIncomingSharePath) return shareLocation;
      }

      if (!isAuthenticated && !isLoggingIn && !isLegal) {
        return '/auth/login';
      }
      if (isAuthenticated && isLoggingIn) {
        final pending = ref.read(pendingShareLinkProvider);
        if (pending != null) {
          final mapped = ShareUrls.appLocationForIncomingUri(pending);
          if (mapped != null) {
            ref.read(pendingShareLinkProvider.notifier).state = null;
            unawaited(PendingShareLinkStore.clear());
            return mapped;
          }
        }
        return '/home/planner';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        redirect: (_, _) => '/home/planner',
      ),
      GoRoute(
        path: '/share/r/:token',
        builder: (_, state) => SharePrivateLinkScreen(
          token: state.pathParameters['token']!,
        ),
      ),
      GoRoute(
        path: '/p/:id',
        redirect: (_, state) =>
            '/home/explore/${state.pathParameters['id']}',
      ),
      GoRoute(
        path: '/r/:token',
        redirect: (_, state) =>
            '/share/r/${state.pathParameters['token']}',
      ),
      GoRoute(
        path: '/h/:code',
        redirect: (_, state) {
          final code = state.pathParameters['code']!;
          return '/home/profile/household/join?code=${Uri.encodeComponent(code)}';
        },
      ),
      GoRoute(
        path: '/auth/login',
        builder: (_, _) => const LoginScreen(),
      ),
      GoRoute(
        path: '/auth/register',
        builder: (_, _) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/auth/forgot-password',
        builder: (_, _) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/legal/terms',
        builder: (context, _) => LegalDocumentScreen(
          title: context.l10n.termsAndConditions,
          url: LegalUrls.terms,
        ),
      ),
      GoRoute(
        path: '/legal/privacy',
        builder: (context, _) => LegalDocumentScreen(
          title: context.l10n.privacyPolicy,
          url: LegalUrls.privacy,
        ),
      ),
      StatefulShellRoute.indexedStack(
        builder: (_, _, navigationShell) =>
            HomeShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home/explore',
                builder: (_, _) => const ExploreScreen(),
                routes: [
                  GoRoute(
                    path: 'feed',
                    builder: (_, _) => const FeedScreen(),
                  ),
                  GoRoute(
                    path: 'user/:userId',
                    builder: (_, state) => PublicProfileScreen(
                      userId: state.pathParameters['userId']!,
                    ),
                  ),
                  GoRoute(
                    path: ':id',
                    builder: (_, state) => PublicRecipeDetailScreen(
                      recipeId: state.pathParameters['id']!,
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home/recipes',
                builder: (_, _) => const RecipeListScreen(),
                routes: [
                  GoRoute(
                    path: 'glossary',
                    builder: (_, _) => const CookingGlossaryScreen(),
                  ),
                  GoRoute(
                    path: 'new',
                    builder: (_, _) => const RecipeFormScreen(),
                  ),
                  GoRoute(
                    path: ':id',
                    builder: (_, state) => RecipeDetailScreen(
                      recipeId: state.pathParameters['id']!,
                    ),
                    routes: [
                      GoRoute(
                        path: 'edit',
                        builder: (_, state) => RecipeFormScreen(
                          recipeId: state.pathParameters['id'],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home/planner',
                builder: (_, _) => const PlannerScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home/shopping',
                builder: (_, _) => const ShoppingListScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home/profile',
                builder: (_, _) => const ProfileScreen(),
                routes: [
                  GoRoute(
                    path: 'edit',
                    builder: (_, _) => const EditProfileScreen(),
                  ),
                  GoRoute(
                    path: 'household',
                    builder: (_, _) => const HouseholdScreen(),
                    routes: [
                      GoRoute(
                        path: 'create',
                        builder: (_, _) => const CreateHouseholdScreen(),
                      ),
                      GoRoute(
                        path: 'join',
                        builder: (_, state) => JoinHouseholdScreen(
                          initialCode: state.uri.queryParameters['code'],
                        ),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'delete-account',
                    builder: (_, _) => const DeleteAccountScreen(),
                  ),
                  GoRoute(
                    path: 'feedback',
                    builder: (_, _) => const SendFeedbackScreen(),
                  ),
                  GoRoute(
                    path: 'admin/feedback',
                    builder: (_, _) => const AdminFeedbackScreen(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
