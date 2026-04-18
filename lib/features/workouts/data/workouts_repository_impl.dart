import '../../../core/config/app_session.dart';
import '../../../infra/supabase/supabase_client_provider.dart';
import '../domain/models/workout_comment_item.dart';
import '../domain/models/workout_summary.dart';

class WorkoutsRepositoryImpl {

  Future<List<WorkoutSummary>> listManageWorkouts() async {
    final client = SupabaseClientProvider.client;
    final gymId = AppSession.gymId;
    if (gymId == null) return const [];

    final rows = await client.rpc(
      'list_manage_workouts',
      params: {'p_gym_id': gymId},
    );

    return rows.map<WorkoutSummary>((row) {
      return WorkoutSummary(
        id: row['id'] as String,
        title: (row['title'] as String?) ?? 'Untitled workout',
        description: (row['description'] as String?) ?? '',
        programKey: (row['program_key'] as String?) ?? 'general',
        scheduledDate: DateTime.parse(row['scheduled_date'] as String),
        publishedAt: row['published_at'] != null
            ? DateTime.parse(row['published_at'] as String).toLocal()
            : null,
        likesCount: (row['likes_count'] as num?)?.toInt() ?? 0,
        commentsCount: (row['comments_count'] as num?)?.toInt() ?? 0,
        likedByMe: false,
      );
    }).toList();
  }

  Future<void> updateWorkout({
    required String workoutId,
    required String title,
    required String description,
    required String programKey,
    required DateTime scheduledDate,
    required bool isPublished,
  }) async {
    final client = SupabaseClientProvider.client;

    await client.rpc(
      'update_workout',
      params: {
        'p_workout_id': workoutId,
        'p_title': title,
        'p_description': description,
        'p_program_key': programKey,
        'p_scheduled_date': scheduledDate.toIso8601String().split('T').first,
        'p_is_published': isPublished,
      },
    );
  }



  Future<void> createWorkout({
    required String title,
    required String description,
    required String programKey,
    required DateTime scheduledDate,
    required bool isPublished,
  }) async {
    final client = SupabaseClientProvider.client;
    final gymId = AppSession.gymId;
    if (gymId == null) return;

    await client.rpc(
      'create_workout',
      params: {
        'p_gym_id': gymId,
        'p_title': title,
        'p_description': description,
        'p_program_key': programKey,
        'p_scheduled_date': scheduledDate.toIso8601String().split('T').first,
        'p_is_published': isPublished,
      },
    );
  }



  Future<List<WorkoutSummary>> listWorkoutHistory() async {
    final client = SupabaseClientProvider.client;
    final gymId = AppSession.gymId;
    if (gymId == null) return const [];

    final rows = await client.rpc(
      'list_workouts_history',
      params: {'p_gym_id': gymId},
    );

    return rows.map<WorkoutSummary>((row) {
      return WorkoutSummary(
        id: row['id'] as String,
        title: (row['title'] as String?) ?? 'Untitled workout',
        description: (row['description'] as String?) ?? '',
        programKey: (row['program_key'] as String?) ?? 'general',
        scheduledDate: DateTime.parse(row['scheduled_date'] as String),
        publishedAt: row['published_at'] != null
            ? DateTime.parse(row['published_at'] as String).toLocal()
            : null,
        likesCount: (row['likes_count'] as num?)?.toInt() ?? 0,
        commentsCount: (row['comments_count'] as num?)?.toInt() ?? 0,
        likedByMe: false,
      );
    }).toList();
  }

  Future<List<WorkoutSummary>> listTodayWorkouts() async {
    final client = SupabaseClientProvider.client;
    final gymId = AppSession.gymId;
    if (gymId == null) return const [];

    final rows = await client.rpc(
      'list_today_workouts',
      params: {'p_gym_id': gymId},
    );

    return rows.map<WorkoutSummary>((row) {
      return WorkoutSummary(
        id: row['id'] as String,
        title: (row['title'] as String?) ?? 'Untitled workout',
        description: (row['description'] as String?) ?? '',
        programKey: (row['program_key'] as String?) ?? 'general',
        scheduledDate: DateTime.parse(row['scheduled_date'] as String),
        publishedAt: row['published_at'] != null
            ? DateTime.parse(row['published_at'] as String).toLocal()
            : null,
        likesCount: (row['likes_count'] as num?)?.toInt() ?? 0,
        commentsCount: (row['comments_count'] as num?)?.toInt() ?? 0,
        likedByMe: row['liked_by_me'] as bool? ?? false,
      );
    }).toList();
  }

  Future<WorkoutSummary?> getWorkoutDetail(String workoutId) async {
    final client = SupabaseClientProvider.client;

    final rows = await client.rpc(
      'get_workout_detail',
      params: {'p_workout_id': workoutId},
    );

    if (rows is! List || rows.isEmpty) return null;
    final row = rows.first as Map<String, dynamic>;

    return WorkoutSummary(
      id: row['id'] as String,
      title: (row['title'] as String?) ?? 'Untitled workout',
      description: (row['description'] as String?) ?? '',
      programKey: (row['program_key'] as String?) ?? 'general',
      scheduledDate: DateTime.parse(row['scheduled_date'] as String),
      publishedAt: row['published_at'] != null
          ? DateTime.parse(row['published_at'] as String).toLocal()
          : null,
      likesCount: (row['likes_count'] as num?)?.toInt() ?? 0,
      commentsCount: (row['comments_count'] as num?)?.toInt() ?? 0,
      likedByMe: row['liked_by_me'] as bool? ?? false,
    );
  }

  Future<List<WorkoutCommentItem>> listWorkoutComments(String workoutId) async {
    final client = SupabaseClientProvider.client;

    final rows = await client.rpc(
      'get_workout_comments',
      params: {'p_workout_id': workoutId},
    );

    return rows.map<WorkoutCommentItem>((row) {
      return WorkoutCommentItem(
        id: row['id'] as String,
        userId: row['user_id'] as String,
        fullName: row['full_name'] as String,
        email: row['email'] as String,
        content: row['content'] as String,
        createdAt: DateTime.parse(row['created_at'] as String).toLocal(),
      );
    }).toList();
  }

  Future<void> toggleLike(String workoutId) async {
    final client = SupabaseClientProvider.client;
    await client.rpc(
      'toggle_workout_like',
      params: {'p_workout_id': workoutId},
    );
  }

  Future<void> addComment({
    required String workoutId,
    required String content,
  }) async {
    final client = SupabaseClientProvider.client;
    await client.rpc(
      'add_workout_comment',
      params: {
        'p_workout_id': workoutId,
        'p_content': content,
      },
    );
  }
}
