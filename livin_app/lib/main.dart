import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:livin_app/core/di/injection.dart';
import 'package:livin_app/core/shared/app_theme.dart';
import 'package:livin_app/core/shared/home_shell.dart';
import 'package:livin_app/core/shared/welcome_page.dart';
import 'package:livin_app/core/utils/first_launch.dart';
import 'package:livin_app/features/auth/presentation/blocs/auth_bloc/auth_bloc.dart';
import 'package:livin_app/features/auth/presentation/blocs/auth_bloc/auth_event.dart';
import 'package:livin_app/features/auth/presentation/blocs/auth_bloc/auth_state.dart';
import 'package:livin_app/features/auth/presentation/views/pages/login_page.dart';
import 'package:livin_app/features/favorites/presentation/blocs/favorites_bloc/favorites_bloc.dart';
import 'package:livin_app/features/favorites/presentation/blocs/favorites_bloc/favorites_event.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  setupDependencies();
  final isFirstLaunch = await FirstLaunch.isFirstLaunch();
  runApp(MyApp(showWelcome: isFirstLaunch));
}

class MyApp extends StatefulWidget {
  final bool showWelcome;

  const MyApp({super.key, required this.showWelcome});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late bool _showWelcome;

  @override
  void initState() {
    super.initState();
    _showWelcome = widget.showWelcome;
  }

  Future<void> _onStart() async {
    await FirstLaunch.markSeen();
    if (mounted) setState(() => _showWelcome = false);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AuthBloc>()..add(const AuthStarted()),
      child: MaterialApp(
        title: 'Livin',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: _showWelcome
            ? WelcomePage(onStart: _onStart)
            : BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  if (state is AuthSuccess) {
                    return BlocProvider(
                      create: (_) => sl<FavoritesBloc>()
                        ..add(FavoritesStarted(userId: state.user.uid)),
                      child: HomeShell(userId: state.user.uid),
                    );
                  }
                  return const LoginPage();
                },
              ),
      ),
    );
  }
}