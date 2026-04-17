class AdminClassSummary {
  const AdminClassSummary({
    required this.id,
    required this.name,
    required this.coachName,
    required this.startsAt,
    required this.durationMinutes,
    required this.capacity,
    required this.bookedCount,
  });

  final String id;
  final String name;
  final String coachName;
  final DateTime startsAt;
  final int durationMinutes;
  final int capacity;
  final int bookedCount;

  int get spotsLeft {
    final value = capacity - bookedCount;
    return value < 0 ? 0 : value;
  }

  bool get isFull => spotsLeft <= 0;
}
