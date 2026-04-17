import 'package:flutter/material.dart';
import '../admin_shell.dart';
import '../athlete_shell.dart';
import '../coach_shell.dart';
import '../owner_shell.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/sign_up_screen.dart';
import '../../features/gym_context/presentation/screens/select_gym_screen.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import 'route_names.dart';

class AppRouter {
  static const initial = RouteNames.splash;

  static Route<dynamic> generate(RouteSettings settings) {
    switch (settings.name) {
      case RouteNames.splash:
        return _page(const SplashScreen());
      case RouteNames.login:
        return _page(const LoginScreen());
      case RouteNames.signUp:
        return _page(const SignUpScreen());
      case RouteNames.selectGym:
        return _page(const SelectGymScreen());
      case RouteNames.ownerShell:
        return _page(const OwnerShell());
      case RouteNames.athleteShell:
        return _page(const AthleteShell());
      case RouteNames.adminShell:
        return _page(const AdminShell());
      case RouteNames.coachShell:
        return _page(const CoachShell());
      default:
        return _page(
          const Scaffold(
            body: Center(child: Text('Route not found')),
          ),
        );
    }
  }

  static MaterialPageRoute<dynamic> _page(Widget child) {
    return MaterialPageRoute(builder: (_) => child);
  }
}
