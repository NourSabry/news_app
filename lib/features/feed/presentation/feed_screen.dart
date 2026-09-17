import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../app/widgets/live_article_card.dart';
import '../../../core/models/models.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/empty_view.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/utils/snack_bar.dart';
import '../../../core/widgets/pagination_footer.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../../details/presentation/article_details_screen.dart';
import '../../outbox/presentation/cubit/outbox_cubit.dart';
import '../../settings/presentation/settings_screen.dart';
import 'bloc/feed_bloc.dart';
import 'widgets/feed_header.dart';
import 'widgets/new_stories_banner.dart';
import 'widgets/topic_filter_hint.dart';
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
    final refreshed = bloc.stream.firstWhere(
      (state) => !state.isRefreshing && state.status != FeedStatus.loading,
    );
    return Future.wait([refreshed, context.read<OutboxCubit>().sync()]);
  }

  void _openArticle(Article article) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ArticleDetailsScreen(article: article)),
    );
  }

  void _openSettings() => SettingsScreen.open(context);

  static String? _snackMessageFor(FeedState state) {
    return state.notice ?? (state.isEmpty ? null : state.errorMessage);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: MultiBlocListener(
        listeners: [
          BlocListener<FeedBloc, FeedState>(
            listenWhen: (previous, current) =>
                _snackMessageFor(current) != null &&
                _snackMessageFor(previous) != _snackMessageFor(current),
            listener: (context, state) => showSnackBarMessage(context, _snackMessageFor(state)!),
          ),
          BlocListener<FeedBloc, FeedState>(
            listenWhen: (previous, current) => previous.scope != current.scope,
            listener: (_, _) {
              if (_scrollController.hasClients) _scrollController.jumpTo(0);
            },
          ),
        ],
        child: BlocBuilder<FeedBloc, FeedState>(
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
          SliverToBoxAdapter(
            child: FeedHeader(lastSyncedAt: state.lastSyncedAt, onSettingsTap: _openSettings),
          ),
          SliverToBoxAdapter(
            child: TopicFilterHint(count: state.selectedTopicIds.length, onEdit: _openSettings),
          ),
          SliverToBoxAdapter(
            child: TrendingTopics(
              topics: state.trending,
              onTopicTap: (topic) =>
                  context.read<FeedBloc>().add(FeedScopeChanged(topic.label)),
            ),
          ),
          if (state.scope != null)
            SliverToBoxAdapter(child: _ScopeBanner(label: state.scope!)),
          _buildArticles(state),
          SliverToBoxAdapter(
            child: PaginationFooter(isLoadingMore: state.isLoadingMore, hasMore: state.hasMore),
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
          return LiveArticleCard(
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

/// A minimal "Trending: {label} ✕" scope indicator (B2). Restyled to the
/// full ticker/scope-bar look in Part 6.6.
class _ScopeBanner extends StatelessWidget {
  final String label;

  const _ScopeBanner({required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.sm),
      child: Row(
        children: [
          Expanded(
            child: Text('Trending · $label', style: theme.textTheme.titleMedium),
          ),
          Semantics(
            button: true,
            label: 'Clear trending filter',
            child: InkWell(
              onTap: () => context.read<FeedBloc>().add(const FeedScopeChanged(null)),
              child: const Padding(
                padding: EdgeInsets.all(AppSpacing.xs),
                child: Icon(Icons.close_rounded, size: 18),
              ),
            ),
          ),
        ],
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
