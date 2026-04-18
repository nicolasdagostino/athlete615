import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/cards/app_card.dart';
import '../../../../shared/widgets/feedback/app_loader.dart';
import '../../../../shared/widgets/layout/app_scaffold.dart';
import '../../data/workouts_repository_impl.dart';
import '../../domain/models/workout_summary.dart';
import '../widgets/workout_card.dart';
import 'workout_detail_screen.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final _repo = WorkoutsRepositoryImpl();
  final _searchController = TextEditingController();

  static const _filters = <String>[
    'all',
    'crossfit',
    'hyrox',
    'functional',
    'kids',
    'general',
  ];

  bool _loading = true;
  List<WorkoutSummary> _items = const [];
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _load();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _load() async {
    final items = await _repo.listWorkoutHistory();

    if (!mounted) return;

    setState(() {
      _items = items;
      _loading = false;
    });
  }

  Future<void> _refresh() async {
    await _load();
  }

  List<WorkoutSummary> get _filteredItems {
    final query = _searchController.text.trim().toLowerCase();

    return _items.where((item) {
      final programMatches =
          _selectedFilter == 'all' || item.programKey == _selectedFilter;

      if (!programMatches) return false;
      if (query.isEmpty) return true;

      final title = item.title.toLowerCase();
      final description = item.description.toLowerCase();
      final program = item.programLabel.toLowerCase();

      return title.contains(query) ||
          description.contains(query) ||
          program.contains(query);
    }).toList();
  }

  String _formatDate(WorkoutSummary item) {
    final d = item.scheduledDate;
    final day = d.day.toString().padLeft(2, '0');
    final month = d.month.toString().padLeft(2, '0');
    return '$day/$month · ${item.programLabel}';
  }

  String _filterLabel(String value) {
    switch (value) {
      case 'all':
        return 'All';
      case 'crossfit':
        return 'CrossFit';
      case 'hyrox':
        return 'Hyrox';
      case 'functional':
        return 'Functional';
      case 'kids':
        return 'Kids';
      case 'general':
      default:
        return 'General';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const AppScaffold(
        title: 'Explore',
        child: AppLoader(label: 'Loading workouts...'),
      );
    }

    final filteredItems = _filteredItems;

    return AppScaffold(
      title: 'Explore',
      child: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            AppCard(
              child: Column(
                children: [
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search workouts',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.trim().isEmpty
                          ? null
                          : IconButton(
                              onPressed: () => _searchController.clear(),
                              icon: const Icon(Icons.close),
                            ),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  SizedBox(
                    height: 44,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _filters.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: AppSpacing.sm),
                      itemBuilder: (context, index) {
                        final filter = _filters[index];
                        final selected = filter == _selectedFilter;

                        return ChoiceChip(
                          label: Text(_filterLabel(filter)),
                          selected: selected,
                          onSelected: (_) {
                            setState(() => _selectedFilter = filter);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            if (filteredItems.isEmpty)
              const AppCard(
                child: Text('No workouts found'),
              )
            else
              ...List.generate(filteredItems.length, (index) {
                final item = filteredItems[index];

                return Padding(
                  padding: EdgeInsets.only(
                    bottom: index == filteredItems.length - 1 ? 0 : AppSpacing.md,
                  ),
                  child: WorkoutCard(
                    title: item.title,
                    description: item.description,
                    dateLabel: _formatDate(item),
                    likesCount: item.likesCount,
                    commentsCount: item.commentsCount,
                    onOpen: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => WorkoutDetailScreen(
                            workoutId: item.id,
                            title: item.title,
                            description: item.description,
                            dateLabel: _formatDate(item),
                            likesCount: item.likesCount,
                            commentsCount: item.commentsCount,
                          ),
                        ),
                      );
                    },
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}
