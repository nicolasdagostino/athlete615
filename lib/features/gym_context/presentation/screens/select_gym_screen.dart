import 'package:flutter/material.dart';
import '../../../../app/routes/route_names.dart';
import '../../../../core/config/app_session.dart';
import '../../../../core/config/env.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/enums/app_role.dart';
import '../../../../shared/widgets/cards/app_card.dart';
import '../../../../shared/widgets/feedback/app_loader.dart';
import '../../../../shared/widgets/layout/app_scaffold.dart';
import '../../data/gym_context_repository_impl.dart';
import '../../domain/models/user_gym_role.dart';
import 'create_gym_screen.dart';

class SelectGymScreen extends StatefulWidget {
  const SelectGymScreen({super.key});

  @override
  State<SelectGymScreen> createState() => _SelectGymScreenState();
}

class _SelectGymScreenState extends State<SelectGymScreen> {
  final _repository = GymContextRepositoryImpl();
  bool _isLoading = true;
  List<UserGymRole> _items = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (Env.isSupabaseConfigured) {
      final profile = await _repository.getMyProfile();
      if (profile != null) {
        final email = profile['email'] as String?;
        final fullName = profile['full_name'] as String?;

        if (email != null && email.isNotEmpty) {
          AppSession.overrideEmail(email);
        }
        if (fullName != null && fullName.isNotEmpty) {
          AppSession.overrideFullName(fullName);
        }
      }

      final items = await _repository.listMyGyms();
      if (!mounted) return;
      setState(() {
        _items = items;
        _isLoading = false;
      });
      return;
    }

    final role = AppSession.role ?? AppRole.athlete;

    setState(() {
      _items = [
        UserGymRole(
          gymId: 'mock-1',
          gymName: 'Athlete Lab Central',
          role: role,
        ),
        UserGymRole(
          gymId: 'mock-2',
          gymName: 'Athlete Lab Norte',
          role: role,
        ),
        UserGymRole(
          gymId: 'mock-3',
          gymName: 'Athlete Lab Beach',
          role: role,
        ),
      ];
      _isLoading = false;
    });
  }

  void _openGym(UserGymRole item, BuildContext context) {
    AppSession.overrideRole(item.role);
    AppSession.setGymContext(
      id: item.gymId,
      name: item.gymName,
    );

    final nextRoute = switch (item.role) {
      AppRole.owner => RouteNames.ownerShell,
      AppRole.admin => RouteNames.adminShell,
      AppRole.coach => RouteNames.coachShell,
      AppRole.athlete => RouteNames.athleteShell,
    };

    Navigator.pushReplacementNamed(context, nextRoute);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(

      floatingActionButton: _items.any((item) => item.role == AppRole.owner)
          ? FloatingActionButton(
              onPressed: () async {
                final created = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CreateGymScreen(),
                  ),
                );
                if (created == true) {
                  _load();
                }
              },
              child: const Icon(Icons.add),
            )
          : null,

      title: 'Select gym',
      child: _isLoading
          ? const AppLoader(label: 'Loading gyms...')
          : _items.isEmpty
              ? const Center(
                  child: Text('No gyms available for this user'),
                )
              : ListView.separated(
                  itemCount: _items.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: AppSpacing.md),
                  itemBuilder: (context, index) {
                    final item = _items[index];
                    return AppCard(
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(item.gymName),
                        subtitle: Text('Role: ${item.role.name}'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _openGym(item, context),
                      ),
                    );
                  },
                ),
    );
  }
}
