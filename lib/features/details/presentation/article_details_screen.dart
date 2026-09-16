import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../app/article_sync.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/models/models.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/error_view.dart';
import '../domain/details_repository.dart';
import 'bloc/details_bloc.dart';
import 'widgets/article_body.dart';
import 'widgets/details_app_bar.dart';
import 'widgets/details_header.dart';
import 'widgets/related_stories.dart';

class ArticleDetailsScreen extends StatelessWidget {
  final Article article;

  const ArticleDetailsScreen({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DetailsBloc(ServiceLocator.instance.get<DetailsRepository>(), article)
        ..add(const LoadArticle()),
      child: const _DetailsView(),
    );
  }
}

class _DetailsView extends StatelessWidget {
  const _DetailsView();

  void _openArticle(BuildContext context, Article article) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ArticleDetailsScreen(article: article)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<DetailsBloc>().state;
    final article = context.liveArticle(state.article);
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          DetailsAppBar(
            imageUrl: article.image,
            isBookmarked: article.isBookmarked,
            onBookmark: () => context.toggleBookmark(article),
          ),
          SliverToBoxAdapter(
            child: DetailsHeader(
              article: article,
              topicName: state.topicName,
              fromCache: state.fromCache && !state.isLoading,
              onLike: () => context.toggleLike(article),
            ),
          ),
          _buildBody(context, state),
          if (state.related.isNotEmpty)
            SliverToBoxAdapter(
              child: RelatedStories(
                articles: state.related,
                onTap: (article) => _openArticle(context, article),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxxl)),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, DetailsState state) {
    final body = state.article.body;
    if (body != null) return ArticleBody(blocks: body);
    if (state.errorMessage != null) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxxl),
          child: ErrorView(
            message: state.errorMessage!,
            onRetry: () => context.read<DetailsBloc>().add(const LoadArticle()),
          ),
        ),
      );
    }
    return const SliverToBoxAdapter(child: ArticleBodyShimmer());
  }
}
