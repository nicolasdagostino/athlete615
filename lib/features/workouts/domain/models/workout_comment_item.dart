class WorkoutCommentItem {
  const WorkoutCommentItem({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.email,
    required this.content,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final String fullName;
  final String email;
  final String content;
  final DateTime createdAt;
}
