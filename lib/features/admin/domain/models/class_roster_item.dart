class ClassRosterItem {
  const ClassRosterItem({
    required this.bookingId,
    required this.classId,
    required this.userId,
    required this.fullName,
    required this.email,
    required this.status,
  });

  final String bookingId;
  final String classId;
  final String userId;
  final String fullName;
  final String email;
  final String status;
}
