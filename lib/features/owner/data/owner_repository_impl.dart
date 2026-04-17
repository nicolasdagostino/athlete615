import '../../../infra/supabase/supabase_client_provider.dart';
import '../domain/models/owner_gym_summary.dart';

class OwnerRepositoryImpl {
  Future<List<OwnerGymSummary>> listOwnedGyms() async {
    final client = SupabaseClientProvider.client;
    final userId = client.auth.currentUser?.id;
    if (userId == null) return const [];

    final rows = await client
        .from('gyms')
        .select('id, name')
        .eq('owner_id', userId)
        .order('created_at', ascending: false);

    return rows
        .map<OwnerGymSummary>(
          (row) => OwnerGymSummary(
            id: row['id'] as String,
            name: row['name'] as String,
          ),
        )
        .toList();
  }

  Future<List<Map<String, dynamic>>> listRecentInvites() async {
    final client = SupabaseClientProvider.client;
    final userId = client.auth.currentUser?.id;
    if (userId == null) return const [];

    final gymRows = await client
        .from('gyms')
        .select('id')
        .eq('owner_id', userId);

    final gymIds = gymRows.map<String>((row) => row['id'] as String).toList();
    if (gymIds.isEmpty) return const [];

    final inviteRows = await client
        .from('gym_invites')
        .select('id, email, role, accepted, gym_id, created_at')
        .inFilter('gym_id', gymIds)
        .order('created_at', ascending: false)
        .limit(10);

    return List<Map<String, dynamic>>.from(inviteRows);
  }
}
