import 'package:flutter/material.dart';
import '../../../../core/config/app_session.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/enums/app_role.dart';
import '../../../../shared/widgets/cards/app_card.dart';
import '../../../../shared/widgets/feedback/app_loader.dart';
import '../../../../shared/widgets/layout/app_scaffold.dart';
import '../../data/booking_repository_impl.dart';
import '../../domain/models/class_booking.dart';
import '../../domain/models/gym_class.dart';
import '../widgets/booking_day_selector.dart';
import '../widgets/class_card.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _repo = BookingRepositoryImpl();

  bool _loading = true;
  List<GymClass> _allClasses = const [];
  List<ClassBooking> _myBookings = const [];
  int _selectedDayIndex = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final items = await _repo.listGymClasses();
    final bookings = await _repo.listMyBookings();

    if (!mounted) return;

    setState(() {
      _allClasses = items;
      _myBookings = bookings;
      _loading = false;
    });
  }

  Future<void> _cancelClass(GymClass item) async {
    try {
      await _repo.cancelBooking(item.id);
      await _load();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cancelled ${item.name}')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not cancel: $error')),
      );
    }
  }

  Future<void> _bookClass(GymClass item) async {
    try {
      await _repo.bookClass(item.id);
      await _load();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Booked ${item.name}')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not book class: $error')),
      );
    }
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }

  bool _isBooked(String classId) {
    return _myBookings.any((booking) =>
        booking.classId == classId && booking.status == 'booked');
  }

  ({String label, IconData icon, VoidCallback? action}) _primaryAction(
    GymClass item,
  ) {
    final role = AppSession.role;
    final booked = _isBooked(item.id);

    switch (role) {
      case AppRole.athlete:
        if (booked) {
          return (
            label: 'Cancel booking',
            icon: Icons.cancel_outlined,
            action: () => _cancelClass(item),
          );
        }

        if (item.isFull) {
          return (
            label: 'Class full',
            icon: Icons.block,
            action: null,
          );
        }

        return (
          label: 'Book class',
          icon: Icons.add_circle_outline,
          action: () => _bookClass(item),
        );

      case AppRole.coach:
        return (
          label: 'Open roster',
          icon: Icons.fact_check_outlined,
          action: () => _showMessage('Open roster for ${item.name}'),
        );

      case AppRole.admin:
        return (
          label: 'Manage class',
          icon: Icons.settings_outlined,
          action: () => _showMessage('Manage ${item.name}'),
        );

      case AppRole.owner:
        return (
          label: 'View gym usage',
          icon: Icons.bar_chart_outlined,
          action: () => _showMessage('Owner view for ${item.name}'),
        );

      case null:
        return (
          label: 'Unavailable',
          icon: Icons.info_outline,
          action: null,
        );
    }
  }

  List<DateTime> get _days {
    final unique = <String, DateTime>{};

    for (final item in _allClasses) {
      final day = DateTime(item.startsAt.year, item.startsAt.month, item.startsAt.day);
      unique['${day.year}-${day.month}-${day.day}'] = day;
    }

    final values = unique.values.toList()
      ..sort((a, b) => a.compareTo(b));

    return values;
  }

  String _formatDay(DateTime value) {
    const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return names[value.weekday - 1];
  }

  String _formatTime(DateTime value, int durationMinutes) {
    final end = value.add(Duration(minutes: durationMinutes));
    final startH = value.hour.toString().padLeft(2, '0');
    final startM = value.minute.toString().padLeft(2, '0');
    final endH = end.hour.toString().padLeft(2, '0');
    final endM = end.minute.toString().padLeft(2, '0');
    return '$startH:$startM - $endH:$endM';
  }

  List<GymClass> _classesForSelectedDay() {
    final days = _days;
    if (days.isEmpty) return const [];

    final selectedDay = days[_selectedDayIndex];
    return _allClasses.where((item) {
      return item.startsAt.year == selectedDay.year &&
          item.startsAt.month == selectedDay.month &&
          item.startsAt.day == selectedDay.day;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const AppScaffold(
        title: 'Booking',
        child: AppLoader(label: 'Loading classes...'),
      );
    }

    final days = _days;
    if (days.isEmpty) {
      return AppScaffold(
        title: 'Booking',
        child: ListView(
          children: const [
            AppCard(
              child: Text('No upcoming classes for this gym'),
            ),
          ],
        ),
      );
    }

    if (_selectedDayIndex >= days.length) {
      _selectedDayIndex = 0;
    }

    final items = _classesForSelectedDay();
    final roleLabel = AppSession.roleLabel;

    return AppScaffold(
      title: 'Booking',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppCard(
            child: Text('Current role: $roleLabel'),
          ),
          const SizedBox(height: AppSpacing.md),
          BookingDaySelector(
            days: days.map(_formatDay).toList(),
            selectedIndex: _selectedDayIndex,
            onSelected: (index) {
              setState(() => _selectedDayIndex = index);
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          Expanded(
            child: items.isEmpty
                ? const Center(
                    child: Text('No classes for this day'),
                  )
                : ListView.separated(
                    itemCount: items.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: AppSpacing.md),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final action = _primaryAction(item);

                      return ClassCard(
                        name: item.name,
                        coachName: item.coachName,
                        timeLabel: _formatTime(item.startsAt, item.durationMinutes),
                        spotsLeft: item.spotsLeft,
                        primaryLabel: action.label,
                        primaryIcon: action.icon,
                        onPrimaryPressed: action.action,
                        isBooked: _isBooked(item.id),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
