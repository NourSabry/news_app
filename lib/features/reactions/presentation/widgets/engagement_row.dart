import 'package:flutter/material.dart';
import '../../../../core/models/models.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/stat_item.dart';

class EngagementRow extends StatelessWidget {
  final Article article;
  final VoidCallback? onLike;

  const EngagementRow({super.key, required this.article, this.onLike});

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        StatItem(
          icon: article.isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
          color: article.isLiked ? AppColors.liked : muted,
          count: article.likes,
          onTap: onLike,
          tooltip: article.isLiked ? 'Unlike' : 'Like',
        ),
        const SizedBox(width: AppSpacing.lg),
        StatItem(icon: Icons.chat_bubble_outline_rounded, color: muted, count: article.comments),
      ],
    );
  }
}
