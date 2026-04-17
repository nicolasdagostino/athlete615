import '../../../core/config/app_session.dart';
import '../../../infra/supabase/supabase_client_provider.dart';
import '../domain/models/admin_class_summary.dart';
import '../domain/models/admin_member_summary.dart';
import '../domain/models/class_roster_item.dart';

class AdminRepositoryImpl {
  Future<void> createClass({
    required String name,
    required String coachName,
    required DateTime startsAt,
    required int durationMinutes,
    required int capacity,
  }) async {
    final client = SupabaseClientProvider.client;
    final gymId = AppSession.gymId;
    final userId = client.auth.currentUser?.id;

    if (gymId == null || userId == null) return;

    await client.from('classes').insert({
      'gym_id': gymId,
      'name': name,
      'coach_name': coachName,
      'starts_at': startsAt.toIso8601String(),
      'duration_minutes': durationMinutes,
      'capacity': capacity,
      'created_by': userId,
    });
  }

  Future<List<AdminClassSummary>> listGymClasses() async {
    final client = SupabaseClientProvider.client;
    final gymId = AppSession.gymId;
    if (gymId == null) return const [];

    final rows = await client
        .from('classes')
        .select('id, name, coach_name, starts_at, duration_minutes, capacity, class_bookings(status)')
        .eq('gym_id', gymId)
        .order('starts_at', ascending: true);

    return rows.map<AdminClassSummary>((row) {
      final bookings = List<Map<String, dynamic>>.from(
        row['class_bookings'] as List? ?? const [],
      );

      final bookedCount =
          bookings.where((booking) => booking['status'] == 'booked').length;

      return AdminClassSummary(
        id: row['id'] as String,
        name: row['name'] as String,
        coachName: (row['coach_name'] as String?) ?? 'Unknown coach',
        startsAt: DateTime.parse(row['starts_at'] as String),
        durationMinutes: (row['duration_minutes'] as num).toInt(),
        capacity: (row['capacity'] as num).toInt(),
        bookedCount: bookedCount,
      );
    }).toList();
  }

  Future<List<ClassRosterItem>> listClassRoster(String classId) async {
    final client = SupabaseClientProvider.client;

    final rows = await client
        .from('class_bookings')
        .select('id, class_id, user_id, status, profiles!inner(full_name, email)')
        .eq('class_id', classId)
        .order('created_at', ascending: true);

    return rows.map<ClassRosterItem>((row) {
      final profile = row['profiles'] as Map<String, dynamic>;

      return ClassRosterItem(
        bookingId: row['id'] as String,
        classId: row['class_id'] as String,
        userId: row['user_id'] as String,
        fullName: (profile['full_name'] as String?)?.trim().isNotEmpty == true
            ? profile['full_name'] as String
            : 'Unnamed user',
        email: (profile['email'] as String?) ?? '',
        status: row['status'] as String,
      );
    }).toList();
  }

  Future<void> updateBookingStatus({
    required String bookingId,
    required String status,
  }) async {
    final client = SupabaseClientProvider.client;

    await client
        .from('class_bookings')
        .update({'status': status})
        .eq('id', bookingId);
  }

  Future<List<AdminMemberSummary>> listGymMembers() async {
    final client = SupabaseClientProvider.client;
    final gymId = AppSession.gymId;
    if (gymId == null) return const [];

    final rows = await client
        .from('gym_user_roles')
        .select('role, user_id, profiles!inner(full_name, email)')
        .eq('gym_id', gymId)
        .order('created_at', ascending: false);

    return rows.map<AdminMemberSummary>((row) {
      final profile = row['profiles'] as Map<String, dynamic>;

      return AdminMemberSummary(
        userId: row['user_id'] as String,
        fullName: (profile['full_name'] as String?)?.trim().isNotEmpty == true
            ? profile['full_name'] as String
            : 'Unnamed user',
        email: (profile['email'] as String?) ?? '',
        role: row['role'] as String,
      );
    }).toList();
  }
}
