import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/cards/app_card.dart';
import '../../../../shared/widgets/feedback/app_loader.dart';
import '../../../../shared/widgets/layout/app_scaffold.dart';
import '../../data/admin_repository_impl.dart';
import '../../domain/models/admin_class_summary.dart';
import 'class_roster_screen.dart';
import 'create_class_screen.dart';

class ClassesScreen extends StatefulWidget {
  const ClassesScreen({super.key});

  @override
  State<ClassesScreen> createState() => _ClassesScreenState();
}

class _ClassesScreenState extends State<ClassesScreen> {
  Future<void> _openCreateClass() async {
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => const CreateClassScreen(),
      ),
    );

    if (created == true) {
      await _load();
    }
  }
  final _repo = AdminRepositoryImpl();

  bool _loading = true;
  List<AdminClassSummary> _classes = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final items = await _repo.listGymClasses();

    if (!mounted) return;

    setState(() {
      _classes = items;
      _loading = false;
    });
  }

  String _formatDate(DateTime value) {
    final y = value.year.toString().padLeft(4, '0');
    final m = value.month.toString().padLeft(2, '0');
    final d = value.day.toString().padLeft(2, '0');
    final hh = value.hour.toString().padLeft(2, '0');
    final mm = value.minute.toString().padLeft(2, '0');
    return '$y-$m-$d · $hh:$mm';
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const AppScaffold(
        title: 'Classes',
        child: AppLoader(label: 'Loading classes...'),
      );
    }

    return AppScaffold(
      title: 'Classes',
      floatingActionButton: FloatingActionButton(
        onPressed: _openCreateClass,
        child: const Icon(Icons.add),
      ),
      child: _classes.isEmpty
          ? const Center(
              child: Text('No classes found for this gym'),
            )
          : ListView.separated(
              itemCount: _classes.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(height: AppSpacing.md),
              itemBuilder: (context, index) {
                final item = _classes[index];
                return AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.name, style: AppTextStyles.title),
                      const SizedBox(height: AppSpacing.sm),
                      Text(_formatDate(item.startsAt), style: AppTextStyles.body),
                      const SizedBox(height: AppSpacing.xs),
                      Text('Coach: ${item.coachName}', style: AppTextStyles.caption),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Duration: ${item.durationMinutes} min · Capacity: ${item.capacity}',
                        style: AppTextStyles.caption,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Booked: ${item.bookedCount} · Spots left: ${item.spotsLeft}',
                        style: AppTextStyles.caption,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.fact_check_outlined),
                        title: const Text('Open roster'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ClassRosterScreen(
                                classId: item.id,
                                className: item.name,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
