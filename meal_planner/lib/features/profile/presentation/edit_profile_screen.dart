import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meal_planner/core/locale/l10n_extension.dart';
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
  bool _removeAvatar = false;
  bool _isSaving = false;
  bool _isModeratingImage = false;
  String? _errorMessage;

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _pickFromGallery() async {
    if (_isModeratingImage) return;

    final image = await _picker.pickImage(
      source: ImageSource.gallery,
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

    if (!mounted) return;

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
        _removeAvatar = false;
      }
    });
  }

  void _clearPhoto() {
    setState(() {
      _pickedImage = null;
      _pickedImageBytes = null;
      _removeAvatar = true;
      _errorMessage = null;
    });
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

      if (_removeAvatar) {
        await notifier.removeAvatar();
      } else if (_pickedImage != null) {
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
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final profileAsync = ref.watch(profileProvider);
    final profile = profileAsync.valueOrNull;
    final avatarUrl = _removeAvatar ? null : profile?.avatarUrl;
    final hasPhoto = _pickedImageBytes != null || avatarUrl != null;

    if (profile != null && _usernameController.text.isEmpty) {
      _usernameController.text = profile.username;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.editProfile),
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
                            : _pickFromGallery,
                        icon: const Icon(Icons.photo_library_outlined),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: _isModeratingImage
                    ? Text(
                        l10n.checkingImage,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      )
                    : hasPhoto
                        ? TextButton(
                            onPressed: _isSaving ? null : _clearPhoto,
                            child: Text(l10n.removeProfilePhoto),
                          )
                        : const SizedBox.shrink(),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: l10n.usernameLabel,
                  prefixIcon: const Icon(Icons.person_outline),
                ),
                textInputAction: TextInputAction.done,
                enabled: !_isSaving,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return l10n.enterUsername;
                  }
                  if (value.trim().length < 2) {
                    return l10n.minTwoCharacters;
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
                label: l10n.save,
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
