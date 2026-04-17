import '../../features/gym_context/data/gym_context_repository_impl.dart';
import '../../infra/auth/auth_repository.dart';
import '../../shared/enums/app_role.dart';
import 'app_session.dart';
import 'env.dart';

class AppSessionInitializer {
  static Future<void> restore() async {
    if (!Env.isSupabaseConfigured) return;

    final user = AuthRepository().currentUser;
    if (user == null) return;

    await GymContextRepositoryImpl().acceptPendingInvitesForCurrentUser();

    final email = user.email?.trim();
    final detectedRole = _roleFromEmail(email);

    AppSession.startMockSession(detectedRole);

    if (email != null && email.isNotEmpty) {
      AppSession.overrideEmail(email);
    }
  }

  static AppRole _roleFromEmail(String? email) {
    final value = (email ?? '').toLowerCase();

    if (value.contains('owner')) return AppRole.owner;
    if (value.contains('admin')) return AppRole.admin;
    if (value.contains('coach')) return AppRole.coach;
    return AppRole.athlete;
  }
}
