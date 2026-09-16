import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/models/models.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/empty_view.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../../details/presentation/article_details_screen.dart';
import 'bloc/feed_bloc.dart';
import 'widgets/article_card.dart';
import 'widgets/feed_footer.dart';
import 'widgets/feed_header.dart';
import 'widgets/new_stories_banner.dart';
import 'widgets/trending_topics.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  static const _loadMoreThreshold = 400.0;

  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.extentAfter < _loadMoreThreshold) {
      context.read<FeedBloc>().add(const LoadMoreFeed());
    }
  }

  Future<void> _onRefresh() {
    final bloc = context.read<FeedBloc>();
    bloc.add(const RefreshFeed());
    return bloc.stream.firstWhere(
      (state) => !state.isRefreshing && state.status != FeedStatus.loading,
    );
  }

  void _openArticle(Article article) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ArticleDetailsScreen(article: article)),
    );
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: BlocConsumer<FeedBloc, FeedState>(
        listenWhen: (previous, current) =>
            current.errorMessage != null &&
            previous.errorMessage != current.errorMessage &&
            !current.isEmpty,
        listener: (context, state) => _showError(context, state.errorMessage!),
        builder: (context, state) => Stack(
          alignment: Alignment.topCenter,
          children: [
            _buildBody(context, state),
            Positioned(
              top: AppSpacing.md,
              child: NewStoriesBanner(
                count: state.pendingArticles.length,
                onTap: () => context.read<FeedBloc>().add(const ShowPendingArticles()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, FeedState state) {
    if (state.isEmpty) {
      return switch (state.status) {
        FeedStatus.failure => ErrorView(
            message: state.errorMessage ?? FeedBloc.loadErrorMessage,
            onRetry: () => context.read<FeedBloc>().add(const LoadFeed()),
          ),
        FeedStatus.success => const EmptyView(message: 'No stories yet'),
        _ => const _FeedSkeleton(),
      };
    }
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: CustomScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          const SliverToBoxAdapter(child: FeedHeader()),
          SliverToBoxAdapter(child: TrendingTopics(topics: state.trending)),
          _buildArticles(state),
          SliverToBoxAdapter(
            child: FeedFooter(isLoadingMore: state.isLoadingMore, hasMore: state.hasMore),
          ),
        ],
      ),
    );
  }

  Widget _buildArticles(FeedState state) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, 0),
      sliver: SliverList.separated(
        itemCount: state.articles.length,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.lg),
        itemBuilder: (_, index) {
          final article = state.articles[index];
          return ArticleCard(
            key: ValueKey(article.id),
            article: article,
            topicName: state.topicNameFor(article.topicId),
            onTap: () => _openArticle(article),
          );
        },
      ),
    );
  }
}

class _FeedSkeleton extends StatelessWidget {
  const _FeedSkeleton();

  @override
  Widget build(BuildContext context) {
    return const CustomScrollView(
      physics: NeverScrollableScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(child: FeedHeader()),
        SliverToBoxAdapter(child: TrendingTopicsShimmer()),
        SliverToBoxAdapter(child: FeedShimmer()),
      ],
    );
  }
}
