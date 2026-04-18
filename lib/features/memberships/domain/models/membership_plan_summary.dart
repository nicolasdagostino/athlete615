class MembershipPlanSummary {
  const MembershipPlanSummary({
    required this.id,
    required this.name,
    required this.planType,
    required this.classesPerPeriod,
    required this.price,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String planType;
  final int? classesPerPeriod;
  final double price;
  final DateTime? createdAt;

  String get typeLabel {
    switch (planType) {
      case 'unlimited':
        return 'Unlimited';
      case 'drop_in':
        return 'Drop-in';
      case 'class_pack':
        return 'Credits pack';
      case 'weekly_limit':
        return 'Weekly limit';
      default:
        return planType;
    }
  }

  String get ruleLabel {
    switch (planType) {
      case 'unlimited':
        return 'Unlimited bookings · 1 month';
      case 'drop_in':
        return '1 credit · valid for 1 month';
      case 'class_pack':
        final credits = classesPerPeriod ?? 0;
        return '$credits credits · valid for 1 month';
      case 'weekly_limit':
        final credits = classesPerPeriod ?? 0;
        return '$credits classes per period';
      default:
        return 'Plan rule';
    }
  }

  String get priceLabel {
    if (price == 0) return 'Free';
    return '€${price.toStringAsFixed(price.truncateToDouble() == price ? 0 : 2)}';
  }
}
