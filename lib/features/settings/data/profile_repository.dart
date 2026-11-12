import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/models/profile.dart';

/// Reads and updates the signed-in user's `profiles` row.
class ProfileRepository {
  ProfileRepository(this._client);

  final SupabaseClient _client;

  Future<Profile?> fetch(String userId) async {
    final row = await _client
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();
    return row == null ? null : Profile.fromMap(row);
  }

  /// Upserts so it also works if the sign-up trigger did not create the row.
  Future<Profile> save(Profile profile) async {
    final row = await _client
        .from('profiles')
        .upsert({
          ...profile.toMap(),
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        })
        .select()
        .single();
    return Profile.fromMap(row);
  }
}
