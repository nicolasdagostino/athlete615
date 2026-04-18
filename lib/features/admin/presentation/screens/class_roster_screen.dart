import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/cards/app_card.dart';
import '../../../../shared/widgets/feedback/app_loader.dart';
import '../../../../shared/widgets/layout/app_scaffold.dart';
import '../../data/admin_repository_impl.dart';
import '../../domain/models/class_roster_item.dart';

class ClassRosterScreen extends StatefulWidget {
  const ClassRosterScreen({
    super.key,
    required this.classId,
    required this.className,
  });

  final String classId;
  final String className;

  @override
  State<ClassRosterScreen> createState() => _ClassRosterScreenState();
}

class _ClassRosterScreenState extends State<ClassRosterScreen> {
  final _repo = AdminRepositoryImpl();

  bool _loading = true;
  List<ClassRosterItem> _items = const [];
  String? _updatingBookingId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final items = await _repo.listClassRoster(widget.classId);

    if (!mounted) return;

    setState(() {
      _items = items;
      _loading = false;
    });
  }

  Future<void> _refresh() async {
    await _load();
  }

  Future<void> _changeStatus(ClassRosterItem item, String status) async {
    setState(() => _updatingBookingId = item.bookingId);

    try {
      await _repo.updateBookingStatus(
        bookingId: item.bookingId,
        status: status,
      );
      await _load();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Status updated to $status')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not update status: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _updatingBookingId = null);
      }
    }
  }

  int _countByStatus(String status) {
    return _items.where((item) => item.status == status).length;
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'attended':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'booked':
      default:
        return Colors.orange;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'attended':
        return 'Attended';
      case 'cancelled':
        return 'Cancelled';
      case 'booked':
      default:
        return 'Booked';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return AppScaffold(
        title: widget.className,
        child: const AppLoader(label: 'Loading roster...'),
      );
    }

    final bookedCount = _countByStatus('booked');
    final attendedCount = _countByStatus('attended');
    final cancelledCount = _countByStatus('cancelled');

    return AppScaffold(
      title: widget.className,
      child: RefreshIndicator(
        onRefresh: _refresh,
        child: _items.isEmpty
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 120),
                  Center(
                    child: Text('No bookings yet for this class'),
                  ),
                ],
              )
            : ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  AppCard(
                    child: Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: [
                        _SummaryChip(
                          label: 'Booked',
                          value: bookedCount.toString(),
                          color: Colors.orange,
                          icon: Icons.event_available_outlined,
                        ),
                        _SummaryChip(
                          label: 'Attended',
                          value: attendedCount.toString(),
                          color: Colors.green,
                          icon: Icons.check_circle_outline,
                        ),
                        _SummaryChip(
                          label: 'Cancelled',
                          value: cancelledCount.toString(),
                          color: Colors.red,
                          icon: Icons.cancel_outlined,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ...List.generate(_items.length, (index) {
                    final item = _items[index];
                    final color = _statusColor(item.status);
                    final isUpdating = _updatingBookingId == item.bookingId;

                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: index == _items.length - 1 ? 0 : AppSpacing.md,
                      ),
                      child: AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(item.fullName, style: AppTextStyles.title),
                                      const SizedBox(height: AppSpacing.xs),
                                      Text(item.email, style: AppTextStyles.caption),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                _StatusBadge(
                                  label: _statusLabel(item.status),
                                  color: color,
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.md),
                            if (isUpdating)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8),
                                child: Center(
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                ),
                              )
                            else
                              Wrap(
                                spacing: AppSpacing.sm,
                                runSpacing: AppSpacing.sm,
                                children: [
                                  _StatusActionButton(
                                    label: 'Booked',
                                    icon: Icons.event_available_outlined,
                                    selected: item.status == 'booked',
                                    onPressed: item.status == 'booked'
                                        ? null
                                        : () => _changeStatus(item, 'booked'),
                                  ),
                                  _StatusActionButton(
                                    label: 'Attended',
                                    icon: Icons.check_circle_outline,
                                    selected: item.status == 'attended',
                                    onPressed: item.status == 'attended'
                                        ? null
                                        : () => _changeStatus(item, 'attended'),
                                  ),
                                  _StatusActionButton(
                                    label: 'Cancelled',
                                    icon: Icons.cancel_outlined,
                                    selected: item.status == 'cancelled',
                                    onPressed: item.status == 'cancelled'
                                        ? null
                                        : () => _changeStatus(item, 'cancelled'),
                                  ),
                                ],
                              ),
                          ],
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

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  final String label;
  final String value;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text(
            '$label: $value',
            style: AppTextStyles.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
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
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _StatusActionButton extends StatelessWidget {
  const _StatusActionButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        backgroundColor: selected ? Colors.black.withValues(alpha: 0.04) : null,
        side: BorderSide(
          color: selected
              ? Colors.black
              : Colors.black.withValues(alpha: 0.12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }
}
