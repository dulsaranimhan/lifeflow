import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/models/profile.dart';
import '../../auth/data/auth_providers.dart';
import '../../home/data/home_providers.dart';
import 'profile_repository.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(Supabase.instance.client);
});

/// The signed-in user's profile, with defaults if the row is missing.
final profileProvider = FutureProvider<Profile?>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;
  final profile = await ref.watch(profileRepositoryProvider).fetch(user.id);
  return profile ??
      Profile(id: user.id, name: (user.userMetadata?['name'] as String?) ?? '');
});

/// Saves profile changes and refreshes everything that depends on them
/// (Home recommendation, reminders).
final profileActionsProvider = Provider<ProfileActions>(ProfileActions.new);

class ProfileActions {
  ProfileActions(this._ref);

  final Ref _ref;

  Future<void> save(Profile profile) async {
    await _ref.read(profileRepositoryProvider).save(profile);
    _ref.invalidate(profileProvider);
    _ref.invalidate(homeDataProvider);
  }
}
