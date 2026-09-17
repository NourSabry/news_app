import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/hairline.dart';

/// Typing suggestions (Part 6.7): the matched substring in `ink` 600, the
/// rest `inkMuted`.
class SuggestionList extends StatelessWidget {
  final List<String> suggestions;
  final String query;
  final ValueChanged<String> onTap;

  const SuggestionList({super.key, required this.suggestions, required this.query, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      itemCount: suggestions.length,
      separatorBuilder: (_, _) => const Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
        child: Hairline(),
      ),
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

  const _SuggestionRow({required this.suggestion, required this.query, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isLight = brightness == Brightness.light;
    final ink = isLight ? AppColors.lightInk : AppColors.darkInk;
    final inkMuted = isLight ? AppColors.lightInkMuted : AppColors.darkInkMuted;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter, vertical: AppSpacing.md),
        child: Row(
          children: [
            Icon(Icons.search_rounded, size: 18, color: inkMuted),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: _highlighted(inkMuted, ink)),
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
      return Text(suggestion, style: AppTextStyles.body.copyWith(color: muted), maxLines: 1, overflow: TextOverflow.ellipsis);
    }
    final end = start + query.length;
    return Text.rich(
      TextSpan(
        style: AppTextStyles.body.copyWith(color: muted),
        children: [
          TextSpan(text: suggestion.substring(0, start)),
          TextSpan(
            text: suggestion.substring(start, end),
            style: AppTextStyles.body.copyWith(color: ink, fontWeight: FontWeight.w600),
          ),
          TextSpan(text: suggestion.substring(end)),
        ],
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}
