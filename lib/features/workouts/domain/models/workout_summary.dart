class WorkoutSummary {
  const WorkoutSummary({
    required this.id,
    required this.title,
    required this.description,
    required this.programKey,
    required this.scheduledDate,
    required this.publishedAt,
    required this.likesCount,
    required this.commentsCount,
    required this.likedByMe,
  });

  final String id;
  final String title;
  final String description;
  final String programKey;
  final DateTime scheduledDate;
  final DateTime? publishedAt;
  final int likesCount;
  final int commentsCount;
  final bool likedByMe;

  String get programLabel {
    switch (programKey) {
      case 'crossfit':
        return 'CrossFit';
      case 'hyrox':
        return 'Hyrox';
      case 'functional':
        return 'Functional';
      case 'kids':
        return 'Kids';
      default:
        return programKey.isEmpty ? 'General' : programKey;
    }
  }
}
