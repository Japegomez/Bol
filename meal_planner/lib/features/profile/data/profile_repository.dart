import 'package:image_picker/image_picker.dart';
import 'package:meal_planner/core/supabase/models/profile.dart';
import 'package:meal_planner/core/supabase/supabase_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileRepository {
  static const _avatarBucket = 'avatars';
  static const _signedUrlExpirySeconds = 3600;

  Future<Profile?> fetchProfile(String userId) async {
    final data = await supabase
        .from(Profile.table_name)
        .select('id, username, avatar_url, created_at')
        .eq(Profile.c_id, userId)
        .maybeSingle();

    if (data == null) return null;

    final profile = Profile.fromJson(data);
    final avatarUrl = await _resolveAvatarUrl(profile.avatarUrl);

    // is_admin is not exposed at the column level to peers (see migration
    // 043). For the current user's own profile, read the admin flag via
    // the SECURITY DEFINER auth_is_admin() RPC instead.
    var isAdmin = profile.isAdmin;
    if (userId == supabase.auth.currentUser?.id) {
      try {
        final result = await supabase.rpc<dynamic>('auth_is_admin');
        isAdmin = result == true;
      } catch (_) {
        // Best-effort: leave isAdmin as parsed (false) if the RPC fails.
      }
    }

    return profile.copyWith(avatarUrl: avatarUrl, isAdmin: isAdmin);
  }

  Future<void> updateProfile({
    required String userId,
    String? username,
    String? avatarPath,
  }) async {
    final updates = <String, dynamic>{};
    if (username != null) updates[Profile.c_username] = username;
    if (avatarPath != null) {
      updates[Profile.c_avatarUrl] = avatarPath;
      // Mark custom uploads so they won't be overwritten by Google sign-in
      updates['avatar_source'] = 'uploaded';
    }
    if (updates.isEmpty) return;

    await supabase
        .from(Profile.table_name)
        .update(updates)
        .eq(Profile.c_id, userId);
  }

  /// Clears [avatar_url] and best-effort deletes the Storage object if present.
  /// Sets avatar_source to 'deleted' to prevent re-import on future Google sign-ins.
  Future<void> deleteAvatar(String userId) async {
    try {
      await supabase.storage.from(_avatarBucket).remove(['$userId/avatar.jpg']);
    } catch (_) {
      // Best-effort; avatar may be an external URL (e.g. Google).
    }

    await supabase
        .from(Profile.table_name)
        .update({Profile.c_avatarUrl: null, 'avatar_source': 'deleted'})
        .eq(Profile.c_id, userId);
  }

  Future<String> uploadAvatar(String userId, XFile file) async {
    final path = '$userId/avatar.jpg';
    final bytes = await file.readAsBytes();

    await supabase.storage
        .from(_avatarBucket)
        .uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(
            upsert: true,
            contentType: 'image/jpeg',
          ),
        );

    return path;
  }

  Future<String?> resolveAvatarUrl(String? storedValue) =>
      _resolveAvatarUrl(storedValue);

  Future<String?> _resolveAvatarUrl(String? storedValue) async {
    if (storedValue == null || storedValue.isEmpty) return null;
    if (storedValue.startsWith('http')) return storedValue;

    return supabase.storage
        .from(_avatarBucket)
        .createSignedUrl(storedValue, _signedUrlExpirySeconds);
  }
}
