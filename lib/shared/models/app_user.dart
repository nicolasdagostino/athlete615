import '../enums/app_role.dart';

class AppUser {
  const AppUser({
    required this.fullName,
    required this.email,
    required this.role,
  });

  final String fullName;
  final String email;
  final AppRole role;

  String get roleLabel {
    return switch (role) {
      AppRole.owner => 'Owner',
      AppRole.admin => 'Admin',
      AppRole.coach => 'Coach',
      AppRole.athlete => 'Athlete',
    };
  }
}
