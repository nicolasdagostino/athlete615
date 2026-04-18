import 'package:flutter/material.dart';
import '../features/booking/presentation/screens/booking_screen.dart';
import '../features/profile/presentation/screens/profile_screen.dart';
import '../features/workouts/presentation/screens/workouts_screen.dart';
import '../features/workouts/presentation/screens/explore_screen.dart';

class AthleteShell extends StatefulWidget {
  const AthleteShell({super.key});

  @override
  State<AthleteShell> createState() => _AthleteShellState();
}

class _AthleteShellState extends State<AthleteShell> {
  int _index = 0;

  final _pages = const [
    BookingScreen(),
    WorkoutsScreen(),
    ExploreScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (index) {
          setState(() => _index = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.calendar_today_outlined),
            label: 'Booking',
          ),
          NavigationDestination(
            icon: Icon(Icons.fitness_center_outlined),
            label: 'Workouts',
          ),
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            label: 'Explore',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
