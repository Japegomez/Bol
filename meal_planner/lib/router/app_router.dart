import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meal_planner/core/config/legal_urls.dart';
import 'package:meal_planner/core/locale/l10n_extension.dart';
import 'package:meal_planner/features/auth/domain/auth_state.dart';
import 'package:meal_planner/features/auth/presentation/auth_provider.dart';
import 'package:meal_planner/features/auth/presentation/forgot_password_screen.dart';
import 'package:meal_planner/features/auth/presentation/login_screen.dart';
import 'package:meal_planner/features/auth/presentation/register_screen.dart';
import 'package:meal_planner/features/household/presentation/create_household_screen.dart';
import 'package:meal_planner/features/household/presentation/household_screen.dart';
import 'package:meal_planner/features/household/presentation/join_household_screen.dart';
import 'package:meal_planner/features/planner/presentation/planner_screen.dart';
import 'package:meal_planner/features/profile/presentation/delete_account_screen.dart';
import 'package:meal_planner/features/profile/presentation/edit_profile_screen.dart';
import 'package:meal_planner/features/profile/presentation/legal_document_screen.dart';
import 'package:meal_planner/features/profile/presentation/profile_screen.dart';
import 'package:meal_planner/features/recipes/presentation/cooking_glossary_screen.dart';
import 'package:meal_planner/features/recipes/presentation/recipe_detail_screen.dart';
import 'package:meal_planner/features/recipes/presentation/recipe_form_screen.dart';
import 'package:meal_planner/features/recipes/presentation/recipe_list_screen.dart';
import 'package:meal_planner/features/shopping/presentation/shopping_list_screen.dart';
import 'package:meal_planner/features/social/presentation/explore_screen.dart';
import 'package:meal_planner/features/social/presentation/feed_screen.dart';
import 'package:meal_planner/features/social/presentation/public_screens.dart';
import 'package:meal_planner/router/home_shell.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/',
    redirect: (context, state) {
      final isLoggingIn = state.matchedLocation.startsWith('/auth');
      final isLegal = state.matchedLocation.startsWith('/legal');
      final isAuthenticated = authState.maybeWhen(
        data: (value) => value is AuthAuthenticated,
        orElse: () => false,
      );

      if (!isAuthenticated && !isLoggingIn && !isLegal) {
        return '/auth/login';
      }
      if (isAuthenticated && isLoggingIn) {
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
                        builder: (_, _) => const JoinHouseholdScreen(),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'delete-account',
                    builder: (_, _) => const DeleteAccountScreen(),
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
