import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../app/widgets/live_article_card.dart';
import '../../../core/models/models.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/snack_bar.dart';
import '../../../core/widgets/halftone_painter.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../../../core/widgets/state_view.dart';
import '../../details/presentation/article_details_screen.dart';
import '../../feed/presentation/widgets/article_cards.dart';
import 'bloc/bookmarks_bloc.dart';

class SavedScreen extends StatelessWidget {
  const SavedScreen({super.key});

  void _openArticle(BuildContext context, Article article) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ArticleDetailsScreen(article: article)),
    );
  }

  void _remove(BuildContext context, Article article) {
    final bloc = context.read<BookmarksBloc>();
    bloc.add(ToggleBookmark(article));
    showSnackBarMessage(
      context,
      'Removed from saved',
      action: SnackBarAction(label: 'Undo', onPressed: () => bloc.add(ToggleBookmark(article))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final ink = brightness == Brightness.light ? AppColors.lightInk : AppColors.darkInk;
    final inkMuted = brightness == Brightness.light ? AppColors.lightInkMuted : AppColors.darkInkMuted;

    return SafeArea(
      bottom: false,
      child: BlocBuilder<BookmarksBloc, BookmarksState>(
        builder: (context, state) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.gutter, AppSpacing.lg, AppSpacing.gutter, AppSpacing.xs),
              child: Text('Saved', style: AppTextStyles.displayL.copyWith(color: ink)),
            ),
            if (!state.isEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.gutter, 0, AppSpacing.gutter, AppSpacing.sm),
                child: Text(_countLabel(state.articles), style: AppTextStyles.caption.copyWith(color: inkMuted)),
              ),
            Expanded(child: _buildBody(context, state)),
          ],
        ),
      ),
    );
  }

  String _countLabel(List<Article> articles) {
    final offline = articles.where((a) => a.body != null).length;
    final total = articles.length;
    return '$total ${total == 1 ? 'story' : 'stories'} · $offline available offline';
  }

  Widget _buildBody(BuildContext context, BookmarksState state) {
    if (state.isEmpty) {
      if (state.isLoading) return const HomeFeedSkeleton(standardCount: 2);
      return const StateView(
        shape: HalftoneShape.radial,
        title: 'Your clippings live here.',
        body: 'Save a story with the bookmark on any card.',
      );
    }

    final grouped = _groupBySection(state);
    return ListView(
      padding: const EdgeInsets.fromLTRB(AppSpacing.gutter, AppSpacing.sm, AppSpacing.gutter, AppSpacing.xxl),
      children: [
        for (final entry in grouped.entries) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Text(entry.key.toUpperCase(), style: AppTextStyles.overline.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ),
          for (final article in entry.value)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.lg),
              child: Dismissible(
                key: ValueKey(article.id),
                direction: DismissDirection.endToStart,
                background: const _RemoveBackground(),
                onDismissed: (_) => _remove(context, article),
                child: LiveArticleCard(
                  article: article,
                  topicName: entry.key,
                  variant: ArticleCardVariant.standard,
                  onTap: () => _openArticle(context, article),
                ),
              ),
            ),
        ],
      ],
    );
  }

  Map<String, List<Article>> _groupBySection(BookmarksState state) {
    final grouped = <String, List<Article>>{};
    for (final article in state.articles) {
      final name = state.topicNameFor(article.topicId);
      grouped.putIfAbsent(name, () => []).add(article);
    }
    return grouped;
  }
}

class _RemoveBackground extends StatelessWidget {
  const _RemoveBackground();

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isLight = brightness == Brightness.light;
    final red = isLight ? AppColors.lightRed : AppColors.darkRed;
    final paper = isLight ? AppColors.lightPaper : AppColors.darkPaper;
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
      color: red,
      child: Text('Remove', style: AppTextStyles.label.copyWith(color: paper, fontWeight: FontWeight.w600)),
    );
  }
}
