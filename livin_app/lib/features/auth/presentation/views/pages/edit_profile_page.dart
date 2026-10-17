import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:livin_app/core/shared/app_input.dart';
import 'package:livin_app/features/auth/presentation/blocs/auth_bloc/auth_bloc.dart';
import 'package:livin_app/features/auth/presentation/blocs/auth_bloc/auth_event.dart';
import 'package:livin_app/features/auth/presentation/blocs/auth_bloc/auth_state.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  String? _newPhotoPath;

  @override
  void initState() {
    super.initState();
    final state = context.read<AuthBloc>().state;
    final user = state is AuthSuccess ? state.user : null;
    _nameController = TextEditingController(text: user?.name ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
      maxWidth: 800,
    );
    if (file == null) return;
    setState(() => _newPhotoPath = file.path);
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(
          AuthProfileUpdated(
            name: _nameController.text.trim(),
            phone: _phoneController.text.trim(),
            newPhotoPath: _newPhotoPath,
          ),
        );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listenWhen: (previous, current) => previous is AuthProfileUpdating,
      listener: (context, state) {
        if (state is AuthProfileFailure) {
          _showMessage(state.message);
        } else if (state is AuthSuccess) {
          _showMessage('Profil mis à jour');
          context.pop();
        }
      },
      builder: (context, state) {
        final user = state is AuthSuccess ? state.user : null;
        final isSaving = state is AuthProfileUpdating;

        ImageProvider? avatar;
        if (_newPhotoPath != null) {
          avatar = FileImage(File(_newPhotoPath!));
        } else if (user != null && user.photoUrl.isNotEmpty) {
          avatar = NetworkImage(user.photoUrl);
        }
        final initial = (user != null && user.name.isNotEmpty)
            ? user.name[0].toUpperCase()
            : '?';

        return Scaffold(
          appBar: AppBar(title: const Text('Modifier le profil')),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 52,
                      backgroundImage: avatar,
                      child: avatar == null
                          ? Text(initial, style: const TextStyle(fontSize: 32))
                          : null,
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      icon: const Icon(Icons.photo_camera_outlined),
                      label: const Text('Changer la photo'),
                      onPressed: isSaving ? null : _pickPhoto,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nameController,
                      decoration: appInputDecoration(
                        context,
                        'Nom',
                        icon: Icons.person_outline,
                      ),
                      validator: (value) =>
                          (value == null || value.trim().isEmpty)
                              ? 'Nom obligatoire'
                              : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      enabled: false,
                      decoration: appInputDecoration(
                        context,
                        'Email',
                        icon: Icons.mail_outline,
                      ).copyWith(
                        helperText: 'L\'email ne peut pas être modifié.',
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: appInputDecoration(
                        context,
                        'Téléphone',
                        icon: Icons.phone_outlined,
                      ),
                      validator: (value) {
                        final text = value?.trim() ?? '';
                        if (text.isNotEmpty && text.length < 8) {
                          return 'Numéro invalide';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isSaving ? null : _save,
                        child: isSaving
                            ? const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  ),
                                  SizedBox(width: 12),
                                  Text('Enregistrement…'),
                                ],
                              )
                            : const Text('Enregistrer'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}