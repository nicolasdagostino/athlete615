import '../../../../shared/enums/app_role.dart';

class UserGymRole {
  const UserGymRole({
    required this.gymId,
    required this.gymName,
    required this.role,
  });

  final String gymId;
  final String gymName;
  final AppRole role;
}
