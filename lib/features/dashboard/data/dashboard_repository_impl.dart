import '../../../core/config/app_session.dart';
import '../../../infra/supabase/supabase_client_provider.dart';

class DashboardSummary {
  const DashboardSummary({
    required this.classesToday,
    required this.bookedToday,
    required this.attendedToday,
    required this.upcomingClassesCount,
    required this.occupancyToday,
  });

  final int classesToday;
  final int bookedToday;
  final int attendedToday;
  final int upcomingClassesCount;
  final double occupancyToday;
}

class DashboardUpcomingClass {
  const DashboardUpcomingClass({
    required this.id,
    required this.name,
    required this.coachName,
    required this.startsAt,
    required this.durationMinutes,
    required this.capacity,
    required this.bookedCount,
  });

  final String id;
  final String name;
  final String coachName;
  final DateTime startsAt;
  final int durationMinutes;
  final int capacity;
  final int bookedCount;

  int get spotsLeft {
    final value = capacity - bookedCount;
    return value < 0 ? 0 : value;
  }
}

class DashboardWeeklyComparison {
  const DashboardWeeklyComparison({
    required this.bookingsLast7d,
    required this.bookingsPrev7d,
    required this.attendedLast7d,
    required this.attendedPrev7d,
  });

  final int bookingsLast7d;
  final int bookingsPrev7d;
  final int attendedLast7d;
  final int attendedPrev7d;
}

class DashboardRepositoryImpl {
  Future<DashboardSummary?> getSummary() async {
    final client = SupabaseClientProvider.client;
    final gymId = AppSession.gymId;
    if (gymId == null) return null;

    final rows = await client.rpc(
      'get_gym_dashboard_summary',
      params: {'p_gym_id': gymId},
    );

    if (rows is! List || rows.isEmpty) return null;
    final row = rows.first as Map<String, dynamic>;

    return DashboardSummary(
      classesToday: (row['classes_today'] as num?)?.toInt() ?? 0,
      bookedToday: (row['booked_today'] as num?)?.toInt() ?? 0,
      attendedToday: (row['attended_today'] as num?)?.toInt() ?? 0,
      upcomingClassesCount: (row['upcoming_classes_count'] as num?)?.toInt() ?? 0,
      occupancyToday: (row['occupancy_today'] as num?)?.toDouble() ?? 0,
    );
  }


  Future<DashboardWeeklyComparison?> getWeeklyComparison() async {
    final client = SupabaseClientProvider.client;
    final gymId = AppSession.gymId;
    if (gymId == null) return null;

    final rows = await client.rpc(
      'get_gym_dashboard_weekly_comparison',
      params: {'p_gym_id': gymId},
    );

    if (rows is! List || rows.isEmpty) return null;
    final row = rows.first as Map<String, dynamic>;

    return DashboardWeeklyComparison(
      bookingsLast7d: (row['bookings_last_7d'] as num?)?.toInt() ?? 0,
      bookingsPrev7d: (row['bookings_prev_7d'] as num?)?.toInt() ?? 0,
      attendedLast7d: (row['attended_last_7d'] as num?)?.toInt() ?? 0,
      attendedPrev7d: (row['attended_prev_7d'] as num?)?.toInt() ?? 0,
    );
  }

  Future<List<DashboardUpcomingClass>> listUpcomingClasses() async {
    final client = SupabaseClientProvider.client;
    final gymId = AppSession.gymId;
    if (gymId == null) return const [];

    final rows = await client.rpc(
      'list_upcoming_classes_for_gym',
      params: {'p_gym_id': gymId},
    );

    return rows.map<DashboardUpcomingClass>((row) {
      return DashboardUpcomingClass(
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
}
