import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../app/widgets/live_article_card.dart';
import '../../../core/models/models.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/snack_bar.dart';
import '../../../core/widgets/empty_view.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../../details/presentation/article_details_screen.dart';
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
    return SafeArea(
      bottom: false,
      child: BlocBuilder<BookmarksBloc, BookmarksState>(
        builder: (context, state) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.sm),
              child: Text('Saved', style: Theme.of(context).textTheme.headlineLarge),
            ),
            Expanded(child: _buildBody(context, state)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, BookmarksState state) {
    if (state.isEmpty) {
      return state.isLoading
          ? const FeedShimmer()
          : const EmptyView(
              message: 'Stories you save will show up here',
              icon: Icons.bookmark_outline_rounded,
            );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.xxl),
      itemCount: state.articles.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.lg),
      itemBuilder: (_, index) {
        final article = state.articles[index];
        return Dismissible(
          key: ValueKey(article.id),
          direction: DismissDirection.endToStart,
          background: const _RemoveBackground(),
          onDismissed: (_) => _remove(context, article),
          child: LiveArticleCard(
            article: article,
            topicName: state.topicNameFor(article.topicId),
            onTap: () => _openArticle(context, article),
          ),
        );
      },
    );
  }
}

class _RemoveBackground extends StatelessWidget {
  const _RemoveBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
      decoration: BoxDecoration(
        color: AppColors.error,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: const Icon(Icons.delete_outline_rounded, color: AppColors.white),
    );
  }
}
