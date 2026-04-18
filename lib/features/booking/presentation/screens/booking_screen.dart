import 'package:flutter/material.dart';
import '../../../../core/config/app_session.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/enums/app_role.dart';
import '../../../../shared/widgets/cards/app_card.dart';
import '../../../../shared/widgets/feedback/app_loader.dart';
import '../../../../shared/widgets/layout/app_scaffold.dart';
import '../../../admin/presentation/screens/class_roster_screen.dart';
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

  Future<void> _refresh() async {
    await _load();
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

  Future<void> _openRoster(GymClass item) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ClassRosterScreen(
          classId: item.id,
          className: item.name,
        ),
      ),
    );

    await _load();
  }

  

  bool _canCheckIn(GymClass item) {
    final now = DateTime.now();
    final start = item.startsAt;
    final end = start.add(Duration(minutes: item.durationMinutes));
    final checkInStart = start.subtract(const Duration(minutes: 10));

    return (now.isAfter(checkInStart) || now.isAtSameMomentAs(checkInStart)) &&
        now.isBefore(end);
  }

  bool _isBooked(String classId) {
    return _myBookings.any(
      (booking) => booking.classId == classId && booking.status == 'booked',
    );
  }

  ({String label, IconData icon, VoidCallback? action}) _primaryAction(
    GymClass item,
  ) {
    final role = AppSession.role;
    final booked = _isBooked(item.id);

    switch (role) {
      case AppRole.athlete:
        if (booked) {
          final attended = _myBookings.any(
            (b) => b.classId == item.id && b.status == 'attended',
          );

          if (attended) {
            return (
              label: 'Checked in',
              icon: Icons.verified,
              action: null,
            );
          }

          if (_canCheckIn(item)) {
            return (
              label: 'Check in',
              icon: Icons.login,
              action: () async {
                await _repo.checkInToClass(item.id);
                await _load();
              },
            );
          }

          final now = DateTime.now();
          final hasStarted = now.isAfter(item.startsAt);

          if (!hasStarted) {
            return (
              label: 'Cancel booking',
              icon: Icons.cancel_outlined,
              action: () => _cancelClass(item),
            );
          }

          return (
            label: 'Class in progress',
            icon: Icons.timer,
            action: null,
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
          action: () => _openRoster(item),
        );

      case AppRole.admin:
        return (
          label: 'Manage roster',
          icon: Icons.fact_check_outlined,
          action: () => _openRoster(item),
        );

      case AppRole.owner:
        return (
          label: 'View roster',
          icon: Icons.fact_check_outlined,
          action: () => _openRoster(item),
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

  String _formatDate(DateTime value) {
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    return '$day/$month';
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
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: const [
              AppCard(
                child: Text('No upcoming classes for this gym'),
              ),
            ],
          ),
        ),
      );
    }

    if (_selectedDayIndex >= days.length) {
      _selectedDayIndex = 0;
    }

    final selectedDay = days[_selectedDayIndex];
    final items = _classesForSelectedDay();

    return AppScaffold(
      title: 'Booking',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${_formatDay(selectedDay)} • ${_formatDate(selectedDay)}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: AppSpacing.md),
          BookingDaySelector(
            days: days.map((day) => '${_formatDay(day)} ${_formatDate(day)}').toList(),
            selectedIndex: _selectedDayIndex,
            onSelected: (index) {
              setState(() => _selectedDayIndex = index);
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: items.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [
                        SizedBox(height: 120),
                        Center(
                          child: Text('No classes for this day'),
                        ),
                      ],
                    )
                  : ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
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
                          bookedCount: item.bookedCount,
                          capacity: item.capacity,
                          primaryLabel: action.label,
                          primaryIcon: action.icon,
                          onPrimaryPressed: action.action,
                          isBooked: _isBooked(item.id),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
