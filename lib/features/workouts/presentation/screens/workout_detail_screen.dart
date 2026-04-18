import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/cards/app_card.dart';
import '../../../../shared/widgets/feedback/app_loader.dart';
import '../../../../shared/widgets/layout/app_scaffold.dart';
import '../../data/workouts_repository_impl.dart';
import '../../domain/models/workout_comment_item.dart';
import '../../domain/models/workout_summary.dart';

class WorkoutDetailScreen extends StatefulWidget {
  const WorkoutDetailScreen({
    super.key,
    required this.workoutId,
    required this.title,
    required this.description,
    required this.dateLabel,
    required this.likesCount,
    required this.commentsCount,
  });

  final String workoutId;
  final String title;
  final String description;
  final String dateLabel;
  final int likesCount;
  final int commentsCount;

  @override
  State<WorkoutDetailScreen> createState() => _WorkoutDetailScreenState();
}

class _WorkoutDetailScreenState extends State<WorkoutDetailScreen> {
  final _repo = WorkoutsRepositoryImpl();
  final _commentController = TextEditingController();
  final _scrollController = ScrollController();

  bool _loading = true;
  bool _submittingComment = false;
  bool _togglingLike = false;
  WorkoutSummary? _detail;
  List<WorkoutCommentItem> _comments = const [];

  bool get _canSubmitComment =>
      !_submittingComment && _commentController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _commentController.addListener(_onCommentChanged);
    _load();
  }

  @override
  void dispose() {
    _commentController.removeListener(_onCommentChanged);
    _commentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onCommentChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _load() async {
    final detail = await _repo.getWorkoutDetail(widget.workoutId);
    final comments = await _repo.listWorkoutComments(widget.workoutId);

    if (!mounted) return;

    setState(() {
      _detail = detail;
      _comments = comments;
      _loading = false;
    });
  }

  Future<void> _refresh() async {
    await _load();
  }

  Future<void> _toggleLike() async {
    if (_togglingLike) return;

    setState(() => _togglingLike = true);

    try {
      await _repo.toggleLike(widget.workoutId);
      await _load();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not update like: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _togglingLike = false);
      }
    }
  }

  Future<void> _submitComment() async {
    final content = _commentController.text.trim();
    if (content.isEmpty || _submittingComment) return;

    FocusScope.of(context).unfocus();
    setState(() => _submittingComment = true);

    try {
      await _repo.addComment(
        workoutId: widget.workoutId,
        content: content,
      );
      _commentController.clear();
      await _load();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Comment posted')),
      );

      await Future.delayed(const Duration(milliseconds: 120));
      if (!mounted || !_scrollController.hasClients) return;
      await _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not add comment: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _submittingComment = false);
      }
    }
  }

  String _formatCommentDate(DateTime value) {
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$day/$month · $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const AppScaffold(
        title: 'Workout',
        child: AppLoader(label: 'Loading workout...'),
      );
    }

    final detail = _detail;

    return AppScaffold(
      title: 'Workout',
      child: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    detail?.title ?? widget.title,
                    style: AppTextStyles.title,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      _InfoChip(
                        icon: Icons.fitness_center_outlined,
                        label: detail?.programLabel ?? widget.dateLabel,
                      ),
                      _InfoChip(
                        icon: Icons.favorite_border,
                        label: '${detail?.likesCount ?? widget.likesCount} likes',
                      ),
                      _InfoChip(
                        icon: Icons.mode_comment_outlined,
                        label: '${detail?.commentsCount ?? widget.commentsCount} comments',
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    detail?.description ?? widget.description,
                    style: AppTextStyles.body,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _togglingLike ? null : _toggleLike,
                      icon: Icon(
                        detail?.likedByMe == true
                            ? Icons.favorite
                            : Icons.favorite_border,
                      ),
                      label: Text(
                        detail?.likedByMe == true ? 'Unlike workout' : 'Like workout',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Add comment', style: AppTextStyles.title),
                  const SizedBox(height: AppSpacing.md),
                  TextField(
                    controller: _commentController,
                    minLines: 2,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText: 'Write your comment',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _canSubmitComment ? _submitComment : null,
                      icon: _submittingComment
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.send),
                      label: Text(
                        _submittingComment ? 'Posting...' : 'Post comment',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Comments', style: AppTextStyles.title),
                  const SizedBox(height: AppSpacing.md),
                  if (_comments.isEmpty)
                    const Text(
                      'No comments yet for this workout.',
                      style: AppTextStyles.body,
                    )
                  else
                    ...List.generate(_comments.length, (index) {
                      final item = _comments[index];

                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: index == _comments.length - 1 ? 0 : AppSpacing.md,
                        ),
                        child: _CommentCard(
                          name: item.fullName,
                          content: item.content,
                          dateLabel: _formatCommentDate(item.createdAt),
                        ),
                      );
                    }),
                ],
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

class _CommentCard extends StatelessWidget {
  const _CommentCard({
    required this.name,
    required this.content,
    required this.dateLabel,
  });

  final String name;
  final String content;
  final String dateLabel;

  @override
  Widget build(BuildContext context) {
    final initial = name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : '?';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            child: Text(
              initial,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(dateLabel, style: AppTextStyles.caption),
                const SizedBox(height: AppSpacing.sm),
                Text(content, style: AppTextStyles.body),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
