import '../../shared/enums/app_role.dart';
import '../../shared/models/app_user.dart';

class AppSession {
  static AppUser? user;
  static String? gymId;
  static String? gymName;

  static AppRole? get role => user?.role;

  static String get roleLabel => user?.roleLabel ?? 'Unknown';

  static String get fullName => user?.fullName ?? 'Unknown User';

  static String get email => user?.email ?? 'unknown@example.com';

  static void startMockSession(AppRole role) {
    user = switch (role) {
      AppRole.owner => const AppUser(
        fullName: 'Nicolás D’Agostino',
        email: 'owner@ath615.com',
        role: AppRole.owner,
      ),
      AppRole.admin => const AppUser(
        fullName: 'Gym Admin',
        email: 'admin@gym.com',
        role: AppRole.admin,
      ),
      AppRole.coach => const AppUser(
        fullName: 'Head Coach',
        email: 'coach@gym.com',
        role: AppRole.coach,
      ),
      AppRole.athlete => const AppUser(
        fullName: 'Athlete Member',
        email: 'athlete@gym.com',
        role: AppRole.athlete,
      ),
    };
  }

  static void overrideEmail(String email) {
    final currentUser = user;
    if (currentUser == null) {
      user = AppUser(
        fullName: 'Unknown User',
        email: email,
        role: AppRole.athlete,
      );
      return;
    }

    user = AppUser(
      fullName: currentUser.fullName,
      email: email,
      role: currentUser.role,
    );
  }

  static void overrideFullName(String fullName) {
    final currentUser = user;
    if (currentUser == null) return;

    user = AppUser(
      fullName: fullName,
      email: currentUser.email,
      role: currentUser.role,
    );
  }

  static void overrideRole(AppRole role) {
    final currentUser = user;
    if (currentUser == null) {
      user = AppUser(
        fullName: 'Unknown User',
        email: 'unknown@example.com',
        role: role,
      );
      return;
    }

    user = AppUser(
      fullName: currentUser.fullName,
      email: currentUser.email,
      role: role,
    );
  }

  static bool get hasActiveSession => user != null;

  static void setGymContext({
    required String id,
    required String name,
  }) {
    gymId = id;
    gymName = name;
  }

  static void clear() {
    user = null;
    gymId = null;
    gymName = null;
  }
}
