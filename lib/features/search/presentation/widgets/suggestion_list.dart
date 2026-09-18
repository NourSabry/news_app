import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Typing suggestions: the matched part of each suggestion in bold ink.
class SuggestionList extends StatelessWidget {
  final List<String> suggestions;
  final String query;
  final ValueChanged<String> onTap;

  const SuggestionList({
    super.key,
    required this.suggestions,
    required this.query,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.gutter,
        AppSpacing.sm,
        AppSpacing.gutter,
        AppSpacing.dockClearance,
      ),
      itemCount: suggestions.length,
      itemBuilder: (_, index) => _SuggestionRow(
        suggestion: suggestions[index],
        query: query,
        onTap: () => onTap(suggestions[index]),
      ),
    );
  }
}

class _SuggestionRow extends StatelessWidget {
  final String suggestion;
  final String query;
  final VoidCallback onTap;

  const _SuggestionRow({
    required this.suggestion,
    required this.query,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: p.surface,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.north_west_rounded,
                size: 16,
                color: p.inkMuted,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: _highlighted(p.inkMuted, p.ink)),
          ],
        ),
      ),
    );
  }

  Widget _highlighted(Color muted, Color ink) {
    final lowerSuggestion = suggestion.toLowerCase();
    final lowerQuery = query.toLowerCase();
    final start = lowerQuery.isEmpty ? -1 : lowerSuggestion.indexOf(lowerQuery);
    if (start < 0) {
      return Text(
        suggestion,
        style: AppTextStyles.body.copyWith(color: muted),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }
    final end = start + query.length;
    return Text.rich(
      TextSpan(
        style: AppTextStyles.body.copyWith(color: muted),
        children: [
          TextSpan(text: suggestion.substring(0, start)),
          TextSpan(
            text: suggestion.substring(start, end),
            style: AppTextStyles.body.copyWith(
              color: ink,
              fontWeight: FontWeight.w600,
            ),
          ),
          TextSpan(text: suggestion.substring(end)),
        ],
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}
