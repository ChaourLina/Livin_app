import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:livin_app/core/di/injection.dart';
import 'package:livin_app/core/router/app_router.dart';
import 'package:livin_app/core/router/go_router_refresh_stream.dart';
import 'package:livin_app/core/shared/app_theme.dart';
import 'package:livin_app/core/utils/first_launch.dart';
import 'package:livin_app/features/auth/presentation/blocs/auth_bloc/auth_bloc.dart';
import 'package:livin_app/features/auth/presentation/blocs/auth_bloc/auth_event.dart';
import 'package:livin_app/features/auth/presentation/blocs/auth_bloc/auth_state.dart';
import 'package:livin_app/features/favorites/presentation/blocs/favorites_bloc/favorites_bloc.dart';
import 'package:livin_app/features/favorites/presentation/blocs/favorites_bloc/favorites_event.dart';
import 'package:livin_app/features/listings/presentation/blocs/listings_bloc/listings_bloc.dart';
import 'package:livin_app/features/listings/presentation/blocs/listings_bloc/listings_event.dart';
import 'package:livin_app/features/listings/presentation/blocs/my_listings_bloc/my_listings_bloc.dart';
import 'package:livin_app/features/listings/presentation/blocs/my_listings_bloc/my_listings_event.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  setupDependencies();
  await FirstLaunch.load();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final AuthBloc _authBloc;
  late final GoRouterRefreshStream _refreshListenable;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _authBloc = sl<AuthBloc>()..add(const AuthStarted());
    _refreshListenable = GoRouterRefreshStream(_authBloc.stream);
    _router = AppRouter.create(
      authBloc: _authBloc,
      refreshListenable: _refreshListenable,
    );
  }

  @override
  void dispose() {
    _router.dispose();
    _refreshListenable.dispose();
    _authBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(value: _authBloc),
        BlocProvider<ListingsBloc>(create: (_) => sl<ListingsBloc>()),
        BlocProvider<MyListingsBloc>(create: (_) => sl<MyListingsBloc>()),
        BlocProvider<FavoritesBloc>(create: (_) => sl<FavoritesBloc>()),
      ],
      child: BlocListener<AuthBloc, AuthState>(
        listenWhen: (previous, current) =>
            current is AuthSuccess && previous is! AuthSuccess,
        listener: (context, state) {
          final user = (state as AuthSuccess).user;
          context.read<ListingsBloc>().add(const ListingsStarted());
          context
              .read<MyListingsBloc>()
              .add(MyListingsStarted(ownerId: user.uid));
          context.read<FavoritesBloc>().add(FavoritesStarted(userId: user.uid));
        },
        child: MaterialApp.router(
          title: 'Livin',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          routerConfig: _router,
        ),
      ),
    );
  }
}