import '../../../core/config/app_session.dart';
import '../../../infra/supabase/supabase_client_provider.dart';
import '../domain/models/class_booking.dart';
import '../domain/models/gym_class.dart';

class BookingRepositoryImpl {
  Future<List<GymClass>> listGymClasses() async {
    final client = SupabaseClientProvider.client;
    final gymId = AppSession.gymId;
    if (gymId == null) return const [];

    final rows = await client
        .from('classes')
        .select('id, name, coach_name, starts_at, duration_minutes, capacity, class_bookings(status)')
        .eq('gym_id', gymId)
        .gte('starts_at', DateTime.now().toIso8601String())
        .order('starts_at', ascending: true);

    return rows.map<GymClass>((row) {
      final bookings = List<Map<String, dynamic>>.from(
        row['class_bookings'] as List? ?? const [],
      );

      final bookedCount =
          bookings.where((booking) => booking['status'] == 'booked').length;

      return GymClass(
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
    final userId = client.auth.currentUser?.id;
    if (userId == null) return;

    await client.from('class_bookings').upsert(
      {
        'class_id': classId,
        'user_id': userId,
        'status': 'booked',
      },
      onConflict: 'class_id,user_id',
    );
  }
}
