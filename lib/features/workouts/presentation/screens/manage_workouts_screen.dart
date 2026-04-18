import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/cards/app_card.dart';
import '../../../../shared/widgets/feedback/app_loader.dart';
import '../../../../shared/widgets/layout/app_scaffold.dart';
import '../../data/workouts_repository_impl.dart';
import '../../domain/models/workout_summary.dart';

class ManageWorkoutsScreen extends StatefulWidget {
  const ManageWorkoutsScreen({super.key});

  @override
  State<ManageWorkoutsScreen> createState() => _ManageWorkoutsScreenState();
}

class _ManageWorkoutsScreenState extends State<ManageWorkoutsScreen> {
  final _repo = WorkoutsRepositoryImpl();
  final _searchController = TextEditingController();

  static const _filters = <String>[
    'all',
    'published',
    'hidden',
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
    final items = await _repo.listManageWorkouts();

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
      final isPublished = item.publishedAt != null;

      final filterMatches = switch (_selectedFilter) {
        'published' => isPublished,
        'hidden' => !isPublished,
        _ => true,
      };

      if (!filterMatches) return false;
      if (query.isEmpty) return true;

      return item.title.toLowerCase().contains(query) ||
          item.description.toLowerCase().contains(query) ||
          item.programLabel.toLowerCase().contains(query);
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
      case 'published':
        return 'Published';
      case 'hidden':
        return 'Hidden';
      case 'all':
      default:
        return 'All';
    }
  }

  Future<void> _openEdit(WorkoutSummary item) async {
    final changed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _EditWorkoutSheet(item: item, repo: _repo),
    );

    if (changed == true) {
      await _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const AppScaffold(
        title: 'Manage workouts',
        child: AppLoader(label: 'Loading workouts...'),
      );
    }

    final filteredItems = _filteredItems;

    return AppScaffold(
      title: 'Manage workouts',
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
                final published = item.publishedAt != null;

                return Padding(
                  padding: EdgeInsets.only(
                    bottom: index == filteredItems.length - 1 ? 0 : AppSpacing.md,
                  ),
                  child: AppCard(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => _openEdit(item),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(item.title, style: AppTextStyles.title),
                              ),
                              _StatusBadge(
                                label: published ? 'Published' : 'Hidden',
                                color: published ? Colors.green : Colors.orange,
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Wrap(
                            spacing: AppSpacing.sm,
                            runSpacing: AppSpacing.sm,
                            children: [
                              _InfoChip(
                                icon: Icons.event_outlined,
                                label: _formatDate(item),
                              ),
                              _InfoChip(
                                icon: Icons.favorite_border,
                                label: '${item.likesCount} likes',
                              ),
                              _InfoChip(
                                icon: Icons.mode_comment_outlined,
                                label: '${item.commentsCount} comments',
                              ),
                            ],
                          ),
                          if (item.description.isNotEmpty) ...[
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              item.description,
                              style: AppTextStyles.body,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}

class _EditWorkoutSheet extends StatefulWidget {
  const _EditWorkoutSheet({
    required this.item,
    required this.repo,
  });

  final WorkoutSummary item;
  final WorkoutsRepositoryImpl repo;

  @override
  State<_EditWorkoutSheet> createState() => _EditWorkoutSheetState();
}

class _EditWorkoutSheetState extends State<_EditWorkoutSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late DateTime _selectedDate;
  late String _programKey;
  late bool _isPublished;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.item.title);
    _descriptionController = TextEditingController(text: widget.item.description);
    _selectedDate = widget.item.scheduledDate;
    _programKey = widget.item.programKey;
    _isPublished = widget.item.publishedAt != null;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final value = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime(DateTime.now().year + 2),
    );

    if (value != null) {
      setState(() => _selectedDate = value);
    }
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title is required')),
      );
      return;
    }

    setState(() => _saving = true);

    try {
      await widget.repo.updateWorkout(
        workoutId: widget.item.id,
        title: title,
        description: description,
        programKey: _programKey,
        scheduledDate: _selectedDate,
        isPublished: _isPublished,
      );

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not update workout: $error')),
      );
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateLabel =
        '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Edit workout', style: AppTextStyles.title),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Workout title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _descriptionController,
              minLines: 4,
              maxLines: 6,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            DropdownButtonFormField<String>(
              initialValue: _programKey,
              decoration: const InputDecoration(
                labelText: 'Program',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'crossfit', child: Text('CrossFit')),
                DropdownMenuItem(value: 'hyrox', child: Text('Hyrox')),
                DropdownMenuItem(value: 'functional', child: Text('Functional')),
                DropdownMenuItem(value: 'kids', child: Text('Kids')),
                DropdownMenuItem(value: 'general', child: Text('General')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _programKey = value);
                }
              },
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _pickDate,
                child: Text(dateLabel),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Published'),
              subtitle: const Text('Visible to athletes in Workouts / Explore'),
              value: _isPublished,
              onChanged: (value) => setState(() => _isPublished = value),
            ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _saving ? null : _save,
                child: Text(_saving ? 'Saving...' : 'Save changes'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.black87),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
