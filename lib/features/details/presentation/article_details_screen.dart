import 'package:flutter/material.dart';
import '../../../core/models/models.dart';
import '../../../core/theme/app_spacing.dart';

class ArticleDetailsScreen extends StatelessWidget {
  final Article article;

  const ArticleDetailsScreen({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(article.source)),
      body: Padding(
        padding: AppSpacing.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(article.title, style: theme.textTheme.headlineMedium),
            const SizedBox(height: AppSpacing.md),
            Text(article.summary, style: theme.textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }
}
