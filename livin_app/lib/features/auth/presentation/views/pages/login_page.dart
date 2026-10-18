import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:livin_app/core/router/app_routes.dart';
import 'package:livin_app/core/shared/app_input.dart';
import 'package:livin_app/core/shared/app_theme.dart';
import 'package:livin_app/core/shared/livin_logo.dart';
import 'package:livin_app/features/auth/presentation/blocs/auth_bloc/auth_bloc.dart';
import 'package:livin_app/features/auth/presentation/blocs/auth_bloc/auth_event.dart';
import 'package:livin_app/features/auth/presentation/blocs/auth_bloc/auth_state.dart';

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

  void _resendVerification() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || password.isEmpty) return;
    context.read<AuthBloc>().add(
          AuthVerificationEmailRequested(email: email, password: password),
        );
  }

  Future<void> _showResetDialog() async {
    final email = await showDialog<String>(
      context: context,
      builder: (_) =>
          _ResetPasswordDialog(initialEmail: _emailController.text.trim()),
    );
    if (email == null || !mounted) return;
    if (!email.contains('@')) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Email invalide')));
      return;
    }
    context.read<AuthBloc>().add(AuthPasswordResetRequested(email: email));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        final messenger = ScaffoldMessenger.of(context);
        final isCurrent = ModalRoute.of(context)?.isCurrent ?? false;
        if (state is AuthFailure && isCurrent) {
          messenger.showSnackBar(SnackBar(content: Text(state.message)));
        } else if (state is AuthEmailNotVerified && isCurrent) {
          messenger.showSnackBar(
            SnackBar(
              content: const Text(
                'Email non vérifié. Cliquez sur le lien reçu par email (pensez aux spams).',
              ),
              duration: const Duration(seconds: 8),
              action: SnackBarAction(
                label: 'Renvoyer',
                onPressed: _resendVerification,
              ),
            ),
          );
        } else if (state is AuthVerificationSent) {
          messenger.showSnackBar(
            SnackBar(
              content: Text(
                'Email de vérification envoyé à ${state.email}. Vérifiez aussi vos spams.',
              ),
            ),
          );
        } else if (state is AuthPasswordResetSent && isCurrent) {
          messenger.showSnackBar(
            SnackBar(
              content: Text(
                'Si un compte existe pour ${state.email}, un lien de réinitialisation vient d\'être envoyé.',
              ),
            ),
          );
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
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: _showResetDialog,
                              child: const Text('Mot de passe oublié ?'),
                            ),
                          ),
                          const SizedBox(height: 8),
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
                              onPressed: () => context.push(AppRoutes.register),
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

class _ResetPasswordDialog extends StatefulWidget {
  final String initialEmail;

  const _ResetPasswordDialog({required this.initialEmail});

  @override
  State<_ResetPasswordDialog> createState() => _ResetPasswordDialogState();
}

class _ResetPasswordDialogState extends State<_ResetPasswordDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialEmail);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Mot de passe oublié'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Nous vous enverrons un lien pour choisir un nouveau mot de passe.',
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            keyboardType: TextInputType.emailAddress,
            decoration: appInputDecoration(
              context,
              'Email',
              icon: Icons.mail_outline,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(_controller.text.trim()),
          child: const Text('Envoyer'),
        ),
      ],
    );
  }
}