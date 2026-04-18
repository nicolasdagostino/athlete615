class MembershipBookingAccess {
  const MembershipBookingAccess({
    required this.hasActiveMembership,
    required this.planName,
    required this.planType,
    required this.classesPerPeriod,
    required this.creditsUsed,
    required this.creditsRemaining,
    required this.bookingAllowed,
    required this.message,
  });

  final bool hasActiveMembership;
  final String? planName;
  final String? planType;
  final int? classesPerPeriod;
  final int creditsUsed;
  final int? creditsRemaining;
  final bool bookingAllowed;
  final String message;

  String get planLabel => planName ?? 'No active membership';

  String get detailLabel {
    switch (planType) {
      case 'unlimited':
        return 'Unlimited · valid current month';
      case 'class_pack':
      case 'drop_in':
        final total = classesPerPeriod ?? 0;
        final remaining = creditsRemaining ?? 0;
        return '$remaining / $total credits left';
      default:
        return message;
    }
  }
}
