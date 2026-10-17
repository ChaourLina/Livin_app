import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:livin_app/core/router/app_routes.dart';
import 'package:livin_app/core/shared/home_shell.dart';
import 'package:livin_app/core/shared/splash_page.dart';
import 'package:livin_app/core/shared/welcome_page.dart';
import 'package:livin_app/core/utils/first_launch.dart';
import 'package:livin_app/features/auth/presentation/blocs/auth_bloc/auth_bloc.dart';
import 'package:livin_app/features/auth/presentation/blocs/auth_bloc/auth_state.dart';
import 'package:livin_app/features/auth/presentation/views/pages/login_page.dart';
import 'package:livin_app/features/auth/presentation/views/pages/profile_page.dart';
import 'package:livin_app/features/auth/presentation/views/pages/register_page.dart';
import 'package:livin_app/features/favorites/presentation/views/pages/favorites_page.dart';
import 'package:livin_app/features/listings/domain/entities/listing.dart';
import 'package:livin_app/features/listings/presentation/views/pages/listing_details_page.dart';
import 'package:livin_app/features/listings/presentation/views/pages/listing_form_page.dart';
import 'package:livin_app/features/listings/presentation/views/pages/listings_page.dart';
import 'package:livin_app/features/listings/presentation/views/pages/my_listings_page.dart';
import 'package:livin_app/features/listings/presentation/views/pages/photo_viewer_page.dart';
import 'package:livin_app/features/auth/presentation/views/pages/edit_profile_page.dart';

class AppRouter {
  static GoRouter create({
    required AuthBloc authBloc,
    required Listenable refreshListenable,
  }) {
    return GoRouter(
      initialLocation: AppRoutes.splash,
      refreshListenable: refreshListenable,
      redirect: (context, state) =>
          _redirect(authBloc.state, state.matchedLocation),
      routes: [
        GoRoute(
          path: AppRoutes.splash,
          builder: (context, state) => const SplashPage(),
        ),
        GoRoute(
          path: AppRoutes.welcome,
          builder: (context, state) => WelcomePage(
            onStart: () async {
              await FirstLaunch.markSeen();
              if (context.mounted) context.go(AppRoutes.home);
            },
          ),
        ),
        GoRoute(
          path: AppRoutes.login,
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: AppRoutes.register,
          builder: (context, state) => const RegisterPage(),
        ),
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) =>
              HomeShell(navigationShell: navigationShell),
          branches: [
            StatefulShellBranch(routes: [
              GoRoute(
                path: AppRoutes.home,
                builder: (context, state) => const ListingsPage(),
              ),
            ]),
            StatefulShellBranch(routes: [
              GoRoute(
                path: AppRoutes.favorites,
                builder: (context, state) => const FavoritesPage(),
              ),
            ]),
            StatefulShellBranch(routes: [
              GoRoute(
                path: AppRoutes.myListings,
                builder: (context, state) => const MyListingsPage(),
              ),
            ]),
            StatefulShellBranch(routes: [
              GoRoute(
                path: AppRoutes.profile,
                builder: (context, state) => const ProfilePage(),
              ),
            ]),
          ],
        ),
        GoRoute(
          path: AppRoutes.editProfile,
          builder: (context, state) => const EditProfilePage(),
        ),
        GoRoute(
          path: AppRoutes.listing,
          builder: (context, state) =>
              ListingDetailsPage(listing: state.extra as Listing),
        ),
        GoRoute(
          path: AppRoutes.photos,
          builder: (context, state) {
            final args = state.extra as ({List<String> photos, int index});
            return PhotoViewerPage(
              photos: args.photos,
              initialIndex: args.index,
            );
          },
        ),
        GoRoute(
          path: AppRoutes.listingForm,
          builder: (context, state) {
            final args = state.extra as ({String ownerId, Listing? listing});
            return ListingFormPage(
              ownerId: args.ownerId,
              listing: args.listing,
            );
          },
        ),
      ],
    );
  }

  static String? _redirect(AuthState auth, String location) {
    if (FirstLaunch.shouldShowWelcome) {
      return location == AppRoutes.welcome ? null : AppRoutes.welcome;
    }
    if (auth is AuthInitial) {
      return location == AppRoutes.splash ? null : AppRoutes.splash;
    }
    final isLoggedIn = auth is AuthSuccess;
    final onAuthPage =
        location == AppRoutes.login || location == AppRoutes.register;
    if (!isLoggedIn) {
      return onAuthPage ? null : AppRoutes.login;
    }
    if (onAuthPage ||
        location == AppRoutes.splash ||
        location == AppRoutes.welcome) {
      return AppRoutes.home;
    }
    return null;
  }
}