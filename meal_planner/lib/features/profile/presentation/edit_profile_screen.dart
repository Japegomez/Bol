import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meal_planner/core/moderation/image_moderation_ui.dart';
import 'package:meal_planner/core/widgets/app_button.dart';
import 'package:meal_planner/features/profile/presentation/profile_provider.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _picker = ImagePicker();

  XFile? _pickedImage;
  Uint8List? _pickedImageBytes;
  bool _isSaving = false;
  bool _isModeratingImage = false;
  String? _errorMessage;

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    if (_isModeratingImage) return;

    final image = await _picker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 512,
      maxHeight: 512,
    );
    if (image == null || !mounted) return;

    final bytes = await image.readAsBytes();
    setState(() {
      _isModeratingImage = true;
      _errorMessage = null;
    });

    final allowed = await moderatePickedImage(
      context: context,
      ref: ref,
      bytes: bytes,
    );

    if (!mounted) return;
    setState(() {
      _isModeratingImage = false;
      if (allowed) {
        _pickedImage = image;
        _pickedImageBytes = bytes;
      }
    });
  }

  Future<void> _showImageSourceSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Galería'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            if (!kIsWeb)
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: const Text('Cámara'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      final notifier = ref.read(profileProvider.notifier);
      final currentProfile = ref.read(profileProvider).valueOrNull;
      final newUsername = _usernameController.text.trim();

      if (_pickedImage != null) {
        await notifier.updateAvatar(_pickedImage!);
      }

      if (currentProfile == null ||
          newUsername != currentProfile.username) {
        await notifier.updateUsername(newUsername);
      }

      if (mounted) context.pop();
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profileAsync = ref.watch(profileProvider);
    final profile = profileAsync.valueOrNull;
    final avatarUrl = profile?.avatarUrl;

    if (profile != null && _usernameController.text.isEmpty) {
      _usernameController.text = profile.username;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar perfil'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 56,
                      backgroundColor: theme.colorScheme.primaryContainer,
                      backgroundImage: _pickedImageBytes != null
                          ? MemoryImage(_pickedImageBytes!)
                          : avatarUrl != null
                              ? CachedNetworkImageProvider(avatarUrl)
                              : null,
                      child: _isModeratingImage
                          ? const CircularProgressIndicator()
                          : _pickedImageBytes == null && avatarUrl == null
                              ? Icon(
                                  Icons.person,
                                  size: 56,
                                  color: theme.colorScheme.onPrimaryContainer,
                                )
                              : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: IconButton.filled(
                        onPressed: (_isSaving || _isModeratingImage)
                            ? null
                            : _showImageSourceSheet,
                        icon: const Icon(Icons.camera_alt),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: _isModeratingImage
                    ? Text(
                        'Comprobando imagen...',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      )
                    : TextButton(
                        onPressed: _isSaving ? null : _showImageSourceSheet,
                        child: const Text('Cambiar foto'),
                      ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre de usuario',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                textInputAction: TextInputAction.done,
                enabled: !_isSaving,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Introduce un nombre de usuario';
                  }
                  if (value.trim().length < 2) {
                    return 'Mínimo 2 caracteres';
                  }
                  return null;
                },
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Text(
                  _errorMessage!,
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              ],
              const SizedBox(height: 24),
              AppButton(
                label: 'Guardar',
                isLoading: _isSaving,
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
