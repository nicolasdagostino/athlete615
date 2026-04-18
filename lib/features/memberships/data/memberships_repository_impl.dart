import '../../../core/config/app_session.dart';
import '../../../infra/supabase/supabase_client_provider.dart';
import '../domain/models/membership_plan_summary.dart';

class MembershipsRepositoryImpl {

  Future<void> updatePlan({
    required String planId,
    required String name,
    required String planType,
    required int? classesPerPeriod,
    required double price,
  }) async {
    final client = SupabaseClientProvider.client;

    await client.rpc(
      'update_membership_plan',
      params: {
        'p_plan_id': planId,
        'p_name': name,
        'p_plan_type': planType,
        'p_classes_per_period': classesPerPeriod,
        'p_price': price,
      },
    );
  }


  Future<void> assignPlanCash({
    required String userId,
    required String planId,
  }) async {
    final client = SupabaseClientProvider.client;
    await client.rpc(
      'assign_membership_plan_cash',
      params: {
        'p_user_id': userId,
        'p_plan_id': planId,
      },
    );
  }


  Future<List<MembershipPlanSummary>> listGymPlans() async {
    final client = SupabaseClientProvider.client;
    final gymId = AppSession.gymId;
    if (gymId == null) return const [];

    final rows = await client.rpc(
      'list_gym_membership_plans',
      params: {'p_gym_id': gymId},
    );

    return rows.map<MembershipPlanSummary>((row) {
      return MembershipPlanSummary(
        id: row['id'] as String,
        name: (row['name'] as String?) ?? 'Unnamed plan',
        planType: (row['plan_type'] as String?) ?? 'class_pack',
        classesPerPeriod: (row['classes_per_period'] as num?)?.toInt(),
        price: (row['price'] as num?)?.toDouble() ?? 0,
        createdAt: row['created_at'] != null
            ? DateTime.parse(row['created_at'] as String).toLocal()
            : null,
      );
    }).toList();
  }

  Future<void> createPlan({
    required String name,
    required String planType,
    required int? classesPerPeriod,
    required double price,
  }) async {
    final client = SupabaseClientProvider.client;
    final gymId = AppSession.gymId;
    if (gymId == null) return;

    await client.rpc(
      'create_membership_plan',
      params: {
        'p_gym_id': gymId,
        'p_name': name,
        'p_plan_type': planType,
        'p_classes_per_period': classesPerPeriod,
        'p_price': price,
      },
    );
  }
}
