import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../app/widgets/live_article_card.dart';
import '../../../core/models/models.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/snack_bar.dart';
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
      action: SnackBarAction(
        label: 'Undo',
        onPressed: () => bloc.add(ToggleBookmark(article)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return BlocBuilder<BookmarksBloc, BookmarksState>(
      builder: (context, state) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.gutter,
              AppSpacing.md,
              AppSpacing.gutter,
              0,
            ),
            child: Text(
              'Saved',
              style: AppTextStyles.displayXL.copyWith(color: p.ink),
            ),
          ),
          if (!state.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.gutter,
                AppSpacing.sm,
                AppSpacing.gutter,
                0,
              ),
              child: Text(
                _countLabel(state.articles),
                style: AppTextStyles.bodyS.copyWith(color: p.inkMuted),
              ),
            ),
          Expanded(child: _buildBody(context, state)),
        ],
      ),
    );
  }

  String _countLabel(List<Article> articles) {
    final offline = articles.where((a) => a.body != null).length;
    final total = articles.length;
    return '$total ${total == 1 ? 'story' : 'stories'} · $offline ready offline';
  }

  Widget _buildBody(BuildContext context, BookmarksState state) {
    if (state.isEmpty) {
      if (state.isLoading) return const HomeFeedSkeleton(compactCount: 2);
      return const StateView(
        icon: Icons.bookmark_outline_rounded,
        title: 'Your saved stories live here.',
        body:
            'Tap the bookmark on any story to keep it for later — they stay readable offline.',
      );
    }

    final grouped = _groupBySection(state);
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.gutter,
        AppSpacing.lg,
        AppSpacing.gutter,
        AppSpacing.dockClearance,
      ),
      children: [
        for (final (groupIndex, entry) in grouped.entries.indexed) ...[
          Padding(
            padding: EdgeInsets.only(
              top: groupIndex == 0 ? 0 : AppSpacing.xxl,
              bottom: AppSpacing.lg,
            ),
            child: Text(
              entry.key.toUpperCase(),
              style: AppTextStyles.overline.copyWith(
                color: context.palette.sectionTint(entry.key),
              ),
            ),
          ),
          for (final (index, article) in entry.value.indexed)
            Padding(
              padding: EdgeInsets.only(top: index == 0 ? 0 : AppSpacing.xl),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                child: Dismissible(
                  key: ValueKey(article.id),
                  direction: DismissDirection.endToStart,
                  background: const _RemoveBackground(),
                  onDismissed: (_) => _remove(context, article),
                  child: ColoredBox(
                    color: context.palette.background,
                    child: LiveArticleCard(
                      article: article,
                      topicName: entry.key,
                      variant: ArticleCardVariant.compact,
                      onTap: () => _openArticle(context, article),
                    ),
                  ),
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
    final p = context.palette;
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
      color: p.accentSoft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.bookmark_remove_outlined, size: 18, color: p.accent),
          const SizedBox(width: AppSpacing.sm),
          Text('Remove', style: AppTextStyles.label.copyWith(color: p.accent)),
        ],
      ),
    );
  }
}
