class AdminMemberSummary {
  const AdminMemberSummary({
    required this.userId,
    required this.fullName,
    required this.email,
    required this.role,
  });

  final String userId;
  final String fullName;
  final String email;
  final String role;
}


class AdminMemberDetail {
  const AdminMemberDetail({
    required this.userId,
    required this.fullName,
    required this.email,
    required this.role,
    required this.activePlanName,
    required this.activePlanType,
    required this.activePlanCredits,
    required this.membershipStartDate,
    required this.membershipEndDate,
    required this.membershipActive,
  });

  final String userId;
  final String fullName;
  final String email;
  final String role;
  final String? activePlanName;
  final String? activePlanType;
  final int? activePlanCredits;
  final DateTime? membershipStartDate;
  final DateTime? membershipEndDate;
  final bool membershipActive;
}
