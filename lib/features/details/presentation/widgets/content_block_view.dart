import 'package:flutter/material.dart';
import '../../../../core/models/models.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/cached_image.dart';

class ContentBlockView extends StatelessWidget {
  final ContentBlock block;

  const ContentBlockView({super.key, required this.block});

  @override
  Widget build(BuildContext context) {
    final text = block.text ?? '';
    return switch (block.type) {
      'heading' => _Heading(text: text),
      'image' => CachedImage(imageUrl: block.url, height: 220),
      'quote' => _Quote(text: text),
      _ => _Paragraph(text: text),
    };
  }
}

class _Paragraph extends StatelessWidget {
  final String text;

  const _Paragraph({required this.text});

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyLarge;
    return Text(text, style: style?.copyWith(height: 1.6));
  }
}

class _Heading extends StatelessWidget {
  final String text;

  const _Heading({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: Text(text, style: Theme.of(context).textTheme.headlineSmall),
    );
  }
}

class _Quote extends StatelessWidget {
  final String text;

  const _Quote({required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        decoration: BoxDecoration(
          border: Border(left: BorderSide(color: theme.colorScheme.primary, width: 3)),
        ),
        child: Text(
          text,
          style: theme.textTheme.titleLarge?.copyWith(
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.w500,
            height: 1.5,
          ),
        ),
      ),
    );
  }
}
