import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/models/recommendation.dart';

/// Stores how the user responded to a recommendation (start / postpone /
/// done) in the `recommendations` table.
class RecommendationRepository {
  RecommendationRepository(this._client);

  final SupabaseClient _client;

  Future<void> save(Recommendation recommendation) async {
    await _client.from('recommendations').insert(recommendation.toMap());
  }
}
