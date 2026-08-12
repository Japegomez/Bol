import 'package:meal_planner/core/supabase/models/household.dart';
import 'package:meal_planner/core/supabase/models/household_member.dart';
import 'package:meal_planner/core/supabase/supabase_client.dart';
import 'package:meal_planner/features/household/domain/household_member_info.dart';
import 'package:meal_planner/features/profile/data/profile_repository.dart';

class HouseholdRepository {
  HouseholdRepository({ProfileRepository? profileRepository})
    : _profileRepository = profileRepository ?? ProfileRepository();

  final ProfileRepository _profileRepository;

  Future<Household?> getUserHousehold(String userId) async {
    final data = await supabase
        .from(HouseholdMember.table_name)
        .select('households(*)')
        .eq(HouseholdMember.c_userId, userId)
        .order(HouseholdMember.c_joinedAt, ascending: false)
        .limit(1)
        .maybeSingle();

    if (data == null) return null;

    final householdJson = data['households'];
    if (householdJson is! Map<String, dynamic>) return null;

    return Household.fromJson(householdJson);
  }

  Future<Household> createHousehold(String name) async {
    final data = await supabase.rpc<Map<String, dynamic>>(
      'create_household',
      params: {'name': name},
    );
    return Household.fromJson(data);
  }

  Future<HouseholdMember> joinHousehold(String code) async {
    final data = await supabase.rpc<Map<String, dynamic>?>(
      'join_household',
      params: {'code': code.trim()},
    );
    // Invalid invite codes return NULL so attempt tracking can commit.
    if (data == null) {
      throw Exception('Invalid invite code');
    }
    return HouseholdMember.fromJson(data);
  }

  Future<String> regenerateInviteCode(String householdId) async {
    final data = await supabase.rpc<String>(
      'regenerate_invite_code',
      params: {'household_id': householdId},
    );
    return data;
  }

  Future<List<HouseholdMemberInfo>> getMembers(String householdId) async {
    final data = await supabase
        .from(HouseholdMember.table_name)
        .select('user_id, role, joined_at, profiles(username, avatar_url)')
        .eq(HouseholdMember.c_householdId, householdId)
        .order(HouseholdMember.c_joinedAt);

    final rows = (data as List).cast<Map<String, dynamic>>();

    return Future.wait(
      rows.map((row) async {
        final profile = row['profiles'] as Map<String, dynamic>?;
        final avatarPath = profile?['avatar_url'] as String?;
        final avatarUrl = await _profileRepository.resolveAvatarUrl(avatarPath);

        return HouseholdMemberInfo(
          userId: row['user_id'] as String,
          username: profile?['username'] as String? ?? 'Usuario',
          avatarUrl: avatarUrl,
          role: row['role'] as String,
          joinedAt: DateTime.parse(row['joined_at'] as String),
        );
      }),
    );
  }

  Future<void> kickMember({
    required String householdId,
    required String userId,
  }) async {
    await supabase
        .from(HouseholdMember.table_name)
        .delete()
        .eq(HouseholdMember.c_householdId, householdId)
        .eq(HouseholdMember.c_userId, userId);
  }

  Future<void> leaveHousehold({required String householdId}) async {
    await supabase.rpc<void>(
      'leave_household',
      params: {'p_household_id': householdId},
    );
  }

  Future<String?> getMemberRole({
    required String householdId,
    required String userId,
  }) async {
    final data = await supabase
        .from(HouseholdMember.table_name)
        .select(HouseholdMember.c_role)
        .eq(HouseholdMember.c_householdId, householdId)
        .eq(HouseholdMember.c_userId, userId)
        .maybeSingle();

    return data?[HouseholdMember.c_role] as String?;
  }
}
