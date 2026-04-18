import '../../../core/config/app_session.dart';
import '../../../infra/supabase/supabase_client_provider.dart';
import '../domain/models/class_booking.dart';
import '../domain/models/gym_class.dart';
import '../domain/models/membership_booking_access.dart';

class BookingRepositoryImpl {
  Future<List<GymClass>> listGymClasses() async {
    final client = SupabaseClientProvider.client;
    final gymId = AppSession.gymId;
    if (gymId == null) return const [];

    final rows = await client.rpc(
      'list_gym_classes_with_counts',
      params: {'p_gym_id': gymId},
    );

    return rows.map<GymClass>((row) {
      return GymClass(
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

  Future<List<ClassBooking>> listMyBookings() async {
    final client = SupabaseClientProvider.client;

    final rows = await client
        .from('class_bookings')
        .select('class_id, status')
        .eq('user_id', client.auth.currentUser!.id);

    return rows.map<ClassBooking>((row) {
      return ClassBooking(
        classId: row['class_id'] as String,
        status: row['status'] as String,
      );
    }).toList();
  }

  Future<MembershipBookingAccess?> getMyMembershipBookingAccess() async {
    final client = SupabaseClientProvider.client;
    final gymId = AppSession.gymId;
    if (gymId == null) return null;

    final rows = await client.rpc(
      'get_my_membership_booking_status',
      params: {'p_gym_id': gymId},
    );

    if (rows is! List || rows.isEmpty) return null;
    final row = rows.first as Map<String, dynamic>;

    return MembershipBookingAccess(
      hasActiveMembership: row['has_active_membership'] as bool? ?? false,
      planName: row['plan_name'] as String?,
      planType: row['plan_type'] as String?,
      classesPerPeriod: (row['classes_per_period'] as num?)?.toInt(),
      creditsUsed: (row['credits_used'] as num?)?.toInt() ?? 0,
      creditsRemaining: (row['credits_remaining'] as num?)?.toInt(),
      bookingAllowed: row['booking_allowed'] as bool? ?? false,
      message: (row['message'] as String?) ?? 'Unavailable',
    );
  }

  Future<void> cancelBooking(String classId) async {
    final client = SupabaseClientProvider.client;
    final userId = client.auth.currentUser?.id;
    if (userId == null) return;

    await client
        .from('class_bookings')
        .update({'status': 'cancelled'})
        .eq('class_id', classId)
        .eq('user_id', userId);
  }

  Future<void> bookClass(String classId) async {
    final client = SupabaseClientProvider.client;
    await client.rpc(
      'book_class_with_membership',
      params: {'p_class_id': classId},
    );
  }

  Future<void> checkInToClass(String classId) async {
    final client = SupabaseClientProvider.client;
    final userId = client.auth.currentUser?.id;
    if (userId == null) return;

    await client
        .from('class_bookings')
        .update({'status': 'attended'})
        .eq('class_id', classId)
        .eq('user_id', userId);
  }
}
