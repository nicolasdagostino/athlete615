import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';

class BookingDaySelector extends StatelessWidget {
  const BookingDaySelector({
    super.key,
    required this.days,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<String> days;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: days.length,
        separatorBuilder: (context, index) =>
            const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final selected = index == selectedIndex;

          return ChoiceChip(
            label: Text(days[index]),
            selected: selected,
            onSelected: (_) => onSelected(index),
          );
        },
      ),
    );
  }
}
