import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/core/supabase/models/household.dart';
import 'package:meal_planner/features/auth/domain/auth_state.dart';
import 'package:meal_planner/features/auth/presentation/auth_provider.dart';
import 'package:meal_planner/features/household/data/household_repository.dart';
import 'package:meal_planner/features/household/domain/household_member_info.dart';
import 'package:meal_planner/features/profile/presentation/profile_provider.dart';

final householdRepositoryProvider = Provider<HouseholdRepository>((ref) {
  return HouseholdRepository(
    profileRepository: ref.read(profileRepositoryProvider),
  );
});

final currentHouseholdProvider =
    AsyncNotifierProvider<HouseholdNotifier, Household?>(HouseholdNotifier.new);

class HouseholdNotifier extends AsyncNotifier<Household?> {
  HouseholdRepository get _repository => ref.read(householdRepositoryProvider);

  String? get _userId {
    final authState = ref.read(authStateProvider).valueOrNull;
    if (authState is AuthAuthenticated) return authState.user.id;
    return null;
  }

  @override
  Future<Household?> build() async {
    ref.watch(authStateProvider);
    final userId = _userId;
    if (userId == null) return null;
    return _repository.getUserHousehold(userId);
  }

  Future<void> create(String name) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repository.createHousehold(name));
  }

  Future<void> join(String code) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _repository.joinHousehold(code);
      final userId = _userId;
      if (userId == null) return null;
      return _repository.getUserHousehold(userId);
    });
  }

  Future<String> regenerateCode() async {
    final household = state.valueOrNull;
    if (household == null) {
      throw StateError('No household loaded');
    }

    final newCode =
        await _repository.regenerateInviteCode(household.id);
    state = AsyncData(household.copyWith(inviteCode: newCode));
    return newCode;
  }

  Future<void> kickMember(String userId) async {
    final household = state.valueOrNull;
    if (household == null) return;

    await _repository.kickMember(
      householdId: household.id,
      userId: userId,
    );
  }

  Future<void> leave() async {
    final household = state.valueOrNull;
    final userId = _userId;
    if (household == null || userId == null) return;

    await _repository.leaveHousehold(
      householdId: household.id,
    );
    state = const AsyncData(null);
  }

  Future<void> refresh() async {
    final userId = _userId;
    if (userId == null) {
      state = const AsyncData(null);
      return;
    }

    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repository.getUserHousehold(userId));
  }
}

final householdMembersByIdProvider = FutureProvider.autoDispose
    .family<List<HouseholdMemberInfo>, String>((ref, householdId) async {
  return ref.read(householdRepositoryProvider).getMembers(householdId);
});

final currentUserHouseholdRoleProvider =
    FutureProvider.autoDispose<String?>((ref) async {
  final household = ref.watch(currentHouseholdProvider).valueOrNull;
  final authState = ref.watch(authStateProvider).valueOrNull;
  if (household == null || authState is! AuthAuthenticated) return null;

  return ref.read(householdRepositoryProvider).getMemberRole(
        householdId: household.id,
        userId: authState.user.id,
      );
});
