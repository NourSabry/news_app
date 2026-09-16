import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';

class NewStoriesBanner extends StatelessWidget {
  final int count;
  final VoidCallback onTap;

  const NewStoriesBanner({super.key, required this.count, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isVisible = count > 0;
    return IgnorePointer(
      ignoring: !isVisible,
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        offset: isVisible ? Offset.zero : const Offset(0, -2),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 250),
          opacity: isVisible ? 1 : 0,
          child: Material(
            color: theme.colorScheme.primary,
            elevation: 4,
            shadowColor: theme.colorScheme.shadow,
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.sm,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.arrow_upward_rounded, size: 16, color: theme.colorScheme.onPrimary),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      _label,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String get _label => count == 1 ? '1 new story' : '$count new stories';
}
