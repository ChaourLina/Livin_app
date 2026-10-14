import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:livin_app/core/shared/app_input.dart';
import 'package:livin_app/core/shared/app_theme.dart';
import 'package:livin_app/core/shared/livin_logo.dart';
import 'package:livin_app/features/auth/presentation/blocs/auth_bloc/auth_bloc.dart';
import 'package:livin_app/features/auth/presentation/blocs/auth_bloc/auth_event.dart';
import 'package:livin_app/features/auth/presentation/blocs/auth_bloc/auth_state.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(
          AuthLoginSubmitted(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthFailure &&
            (ModalRoute.of(context)?.isCurrent ?? false)) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.primary,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              const SizedBox(height: 28),
              const LivinLogo(size: 44, color: Colors.white),
              const SizedBox(height: 8),
              const Text(
                'Votre prochain chez-vous',
                style: TextStyle(color: AppTheme.silver, fontSize: 15),
              ),
              const SizedBox(height: 28),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(32)),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Connexion',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.primary,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Connectez-vous pour continuer',
                            style: TextStyle(
                              color:
                                  Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 24),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: appInputDecoration(
                              context,
                              'Email',
                              icon: Icons.mail_outline,
                            ),
                            validator: (value) =>
                                (value == null || !value.contains('@'))
                                    ? 'Email invalide'
                                    : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscure,
                            decoration: appInputDecoration(
                              context,
                              'Mot de passe',
                              icon: Icons.lock_outline,
                              suffix: IconButton(
                                icon: Icon(
                                  _obscure
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                ),
                                onPressed: () =>
                                    setState(() => _obscure = !_obscure),
                              ),
                            ),
                            validator: (value) =>
                                (value == null || value.length < 6)
                                    ? '6 caractères minimum'
                                    : null,
                          ),
                          const SizedBox(height: 24),
                          BlocBuilder<AuthBloc, AuthState>(
                            builder: (context, state) {
                              final isLoading = state is AuthLoading;
                              return SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: isLoading ? null : _submit,
                                  child: isLoading
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2),
                                        )
                                      : const Text('Se connecter'),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 8),
                          Center(
                            child: TextButton(
                              onPressed: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const RegisterPage(),
                                ),
                              ),
                              child: const Text(
                                'Pas encore de compte ? Créer un compte',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}