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
