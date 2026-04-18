import '../../../core/config/app_session.dart';
import '../../../infra/supabase/supabase_client_provider.dart';
import '../domain/models/attendance_milestone_summary.dart';

class ProfileRepositoryImpl {
  Future<AttendanceMilestoneSummary?> getAttendanceMilestones() async {
    final client = SupabaseClientProvider.client;
    final gymId = AppSession.gymId;
    if (gymId == null) return null;

    final rows = await client.rpc(
      'get_my_attendance_milestones',
      params: {'p_gym_id': gymId},
    );

    if (rows is! List || rows.isEmpty) return null;
    final row = rows.first as Map<String, dynamic>;

    return AttendanceMilestoneSummary(
      attendedCount: (row['attended_count'] as num?)?.toInt() ?? 0,
    );
  }
}
