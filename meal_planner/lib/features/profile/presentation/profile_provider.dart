import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meal_planner/core/supabase/models/profile.dart';
import 'package:meal_planner/features/auth/domain/auth_state.dart';
import 'package:meal_planner/features/auth/presentation/auth_provider.dart';
import 'package:meal_planner/features/profile/data/profile_repository.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository();
});

final profileProvider = AsyncNotifierProvider<ProfileNotifier, Profile?>(
  ProfileNotifier.new,
);

class ProfileNotifier extends AsyncNotifier<Profile?> {
  ProfileRepository get _repository => ref.read(profileRepositoryProvider);

  String? get _userId {
    final authState = ref.read(authStateProvider).valueOrNull;
    if (authState is AuthAuthenticated) return authState.user.id;
    return null;
  }

  @override
  Future<Profile?> build() async {
    ref.watch(authStateProvider);
    final userId = _userId;
    if (userId == null) return null;
    return _repository.fetchProfile(userId);
  }

  Future<void> updateUsername(String username) async {
    final userId = _userId;
    if (userId == null) return;

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _repository.updateProfile(userId: userId, username: username);
      return _repository.fetchProfile(userId);
    });
  }

  Future<void> updateAvatar(XFile file) async {
    final userId = _userId;
    if (userId == null) return;

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final path = await _repository.uploadAvatar(userId, file);
      await _repository.updateProfile(userId: userId, avatarPath: path);
      return _repository.fetchProfile(userId);
    });
  }

  Future<void> removeAvatar() async {
    final userId = _userId;
    if (userId == null) return;

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _repository.deleteAvatar(userId);
      return _repository.fetchProfile(userId);
    });
  }

  Future<void> refresh() async {
    final userId = _userId;
    if (userId == null) {
      state = const AsyncData(null);
      return;
    }

    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repository.fetchProfile(userId));
  }
}
