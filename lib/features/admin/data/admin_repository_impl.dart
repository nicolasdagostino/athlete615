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

    final rows = await client.rpc(
      'list_gym_classes_with_counts',
      params: {'p_gym_id': gymId},
    );

    return rows.map<AdminClassSummary>((row) {
      return AdminClassSummary(
        id: row['id'] as String,
        name: row['name'] as String,
        coachName: (row['coach_name'] as String?) ?? 'Unknown coach',
        startsAt: DateTime.parse(row['starts_at'] as String).toLocal(),
        durationMinutes: (row['duration_minutes'] as num).toInt(),
        capacity: (row['capacity'] as num).toInt(),
        bookedCount: (row['booked_count'] as num).toInt(),
      );
    }).toList();
  }

  Future<List<ClassRosterItem>> listClassRoster(String classId) async {
    final client = SupabaseClientProvider.client;

    final rows = await client.rpc(
      'list_class_roster',
      params: {'p_class_id': classId},
    );

    return rows.map<ClassRosterItem>((row) {
      return ClassRosterItem(
        bookingId: row['booking_id'] as String,
        classId: row['class_id'] as String,
        userId: row['user_id'] as String,
        fullName: row['full_name'] as String,
        email: row['email'] as String,
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


  Future<AdminMemberDetail?> getMemberDetail(String userId) async {
    final client = SupabaseClientProvider.client;
    final gymId = AppSession.gymId;
    if (gymId == null) return null;

    final rows = await client.rpc(
      'get_member_detail',
      params: {
        'p_user_id': userId,
        'p_gym_id': gymId,
      },
    );

    if (rows is! List || rows.isEmpty) return null;
    final row = rows.first as Map<String, dynamic>;

    return AdminMemberDetail(
      userId: row['user_id'] as String,
      fullName: row['full_name'] as String,
      email: row['email'] as String,
      role: row['role'] as String,
      activePlanName: row['active_plan_name'] as String?,
      activePlanType: row['active_plan_type'] as String?,
      activePlanCredits: (row['active_plan_credits'] as num?)?.toInt(),
      membershipStartDate: row['membership_start_date'] != null
          ? DateTime.parse(row['membership_start_date'] as String)
          : null,
      membershipEndDate: row['membership_end_date'] != null
          ? DateTime.parse(row['membership_end_date'] as String)
          : null,
      membershipActive: row['membership_active'] as bool? ?? false,
    );
  }

  Future<List<AdminMemberSummary>> listGymMembers() async {
    final client = SupabaseClientProvider.client;
    final gymId = AppSession.gymId;
    if (gymId == null) return const [];

    final rows = await client.rpc(
      'list_gym_members',
      params: {'p_gym_id': gymId},
    );

    return rows.map<AdminMemberSummary>((row) {
      return AdminMemberSummary(
        userId: row['user_id'] as String,
        fullName: row['full_name'] as String,
        email: row['email'] as String,
        role: row['role'] as String,
      );
    }).toList();
  }
}
