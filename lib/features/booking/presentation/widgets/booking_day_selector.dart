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
      height: 46,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: days.length,
        separatorBuilder: (context, index) =>
            const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final selected = index == selectedIndex;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            child: ChoiceChip(
              label: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Text(days[index]),
              ),
              selected: selected,
              onSelected: (_) => onSelected(index),
              selectedColor: Colors.black,
              backgroundColor: Colors.black.withValues(alpha: 0.05),
              labelStyle: TextStyle(
                color: selected ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w700,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              side: BorderSide(
                color: selected
                    ? Colors.black
                    : Colors.black.withValues(alpha: 0.08),
              ),
            ),
          );
        },
      ),
    );
  }
}
