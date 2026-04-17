import '../../../../infra/supabase/supabase_client_provider.dart';
import '../../../../shared/enums/app_role.dart';
import '../domain/models/user_gym_role.dart';

class GymContextRepositoryImpl {
  Future<List<UserGymRole>> listMyGyms() async {
    final client = SupabaseClientProvider.client;
    final userId = client.auth.currentUser?.id;
    if (userId == null) return const [];

    final ownerGyms = await client
        .from('gyms')
        .select('id, name')
        .eq('owner_id', userId);

    final roleRows = await client
        .from('gym_user_roles')
        .select('role, gyms!inner(id, name)')
        .eq('user_id', userId);

    final result = <UserGymRole>[];

    for (final row in ownerGyms) {
      result.add(
        UserGymRole(
          gymId: row['id'] as String,
          gymName: row['name'] as String,
          role: AppRole.owner,
        ),
      );
    }

    for (final row in roleRows) {
      final gym = row['gyms'] as Map<String, dynamic>;
      final roleText = row['role'] as String;

      result.add(
        UserGymRole(
          gymId: gym['id'] as String,
          gymName: gym['name'] as String,
          role: switch (roleText) {
            'admin' => AppRole.admin,
            'coach' => AppRole.coach,
            'athlete' => AppRole.athlete,
            _ => AppRole.athlete,
          },
        ),
      );
    }

    final byGym = <String, UserGymRole>{};

    for (final item in result) {
      final existing = byGym[item.gymId];

      if (existing == null) {
        byGym[item.gymId] = item;
        continue;
      }

      if (existing.role != AppRole.owner && item.role == AppRole.owner) {
        byGym[item.gymId] = item;
      }
    }

    return byGym.values.toList();
  }


  Future<void> createInvite({
    required String gymId,
    required String email,
    required String role,
  }) async {
    final client = SupabaseClientProvider.client;
    final userId = client.auth.currentUser?.id;
    if (userId == null) return;

    await client.from('gym_invites').insert({
      'gym_id': gymId,
      'email': email.trim().toLowerCase(),
      'role': role,
      'invited_by': userId,
      'accepted': false,
    });
  }


  Future<void> acceptPendingInvitesForCurrentUser() async {
    final client = SupabaseClientProvider.client;
    final currentUser = client.auth.currentUser;
    final userId = currentUser?.id;
    final email = currentUser?.email?.trim().toLowerCase();

    if (userId == null || email == null || email.isEmpty) return;

    final invites = await client
        .from('gym_invites')
        .select('id, gym_id, role, accepted')
        .eq('email', email)
        .eq('accepted', false);

    for (final invite in invites) {
      final gymId = invite['gym_id'] as String;
      final role = invite['role'] as String;
      final inviteId = invite['id'] as String;

      await client.from('gym_user_roles').upsert(
        {
          'user_id': userId,
          'gym_id': gymId,
          'role': role,
        },
        onConflict: 'user_id,gym_id',
        ignoreDuplicates: true,
      );

      await client
          .from('gym_invites')
          .update({'accepted': true})
          .eq('id', inviteId);
    }
  }

  Future<Map<String, dynamic>?> getMyProfile() async {
    final client = SupabaseClientProvider.client;
    final userId = client.auth.currentUser?.id;
    if (userId == null) return null;

    final row = await client
        .from('profiles')
        .select('id, email, full_name')
        .eq('id', userId)
        .maybeSingle();

    return row;
  }

  Future<void> createGym(String name) async {
    final client = SupabaseClientProvider.client;
    final userId = client.auth.currentUser?.id;
    if (userId == null) return;

    final gym = await client
        .from('gyms')
        .insert({
          'name': name,
          'owner_id': userId,
        })
        .select('id')
        .single();

    await client.from('gym_user_roles').upsert({
      'user_id': userId,
      'gym_id': gym['id'],
      'role': 'admin',
    });
  }
}
