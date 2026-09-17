import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../app/widgets/live_article_card.dart';
import '../../../core/models/models.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/snack_bar.dart';
import '../../../core/widgets/halftone_painter.dart';
import '../../../core/widgets/pagination_footer.dart';
import '../../../core/widgets/pull_rule_indicator.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../../../core/widgets/state_view.dart';
import '../../details/presentation/article_details_screen.dart';
import '../../outbox/presentation/cubit/outbox_cubit.dart';
import '../../settings/presentation/settings_screen.dart';
import 'bloc/feed_bloc.dart';
import 'widgets/article_cards.dart';
import 'widgets/edition_masthead.dart';
import 'widgets/new_stories_banner.dart';
import 'widgets/section_divider.dart';
import 'widgets/sections_footer.dart';

class FeedScreen extends StatefulWidget {
  final VoidCallback onSearchTap;

  const FeedScreen({super.key, required this.onSearchTap});

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
                top: EditionMastheadHeader.collapsedHeight + AppSpacing.sm,
                child: NewStoriesBanner(
                  count: state.pendingArticles.length,
                  firstHeadline: state.pendingArticles.isEmpty ? null : state.pendingArticles.first.title,
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
        FeedStatus.failure => StateView(
            shape: HalftoneShape.diagonal,
            title: 'The presses are down.',
            body: "We couldn't reach the newsroom. Check your connection and try again.",
            primaryActionLabel: 'Try again',
            onPrimaryAction: () => context.read<FeedBloc>().add(const LoadFeed()),
          ),
        FeedStatus.success => StateView(
            shape: HalftoneShape.wave,
            title: 'Nothing on the wire.',
            body: 'No stories match your sections yet.',
            primaryActionLabel: 'Edit sections',
            onPrimaryAction: _openSettings,
          ),
        _ => const HomeFeedSkeleton(),
      };
    }
    return PullRuleIndicator(
      onRefresh: _onRefresh,
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: EditionMastheadHeader(
              trending: state.trending,
              scope: state.scope,
              onTopicTap: (label) => context.read<FeedBloc>().add(FeedScopeChanged(label)),
              onClearScope: () => context.read<FeedBloc>().add(const FeedScopeChanged(null)),
              onSearchTap: widget.onSearchTap,
              onSettingsTap: _openSettings,
            ),
          ),
          _buildArticles(state),
          SliverToBoxAdapter(
            child: PaginationFooter(isLoadingMore: state.isLoadingMore, hasMore: state.hasMore),
          ),
          if (!state.hasMore)
            SliverToBoxAdapter(
              child: SectionsFooter(count: state.selectedTopicIds.length, onEdit: _openSettings),
            ),
        ],
      ),
    );
  }

  Widget _buildArticles(FeedState state) {
    final items = <Widget>[];
    String? lastTopic;
    for (var index = 0; index < state.articles.length; index++) {
      final article = state.articles[index];
      final topicName = state.topicNameFor(article.topicId);
      if (index > 0 && topicName.isNotEmpty && topicName != lastTopic) {
        items.add(SectionDivider(topicName: topicName));
      } else if (index > 0) {
        items.add(const SizedBox(height: AppSpacing.lg));
      }
      lastTopic = topicName;
      items.add(LiveArticleCard(
        key: ValueKey(article.id),
        article: article,
        topicName: topicName,
        variant: index == 0 ? ArticleCardVariant.lead : ArticleCardVariant.standard,
        onTap: () => _openArticle(article),
      ));
    }
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.gutter, AppSpacing.sm, AppSpacing.gutter, 0),
      sliver: SliverList.list(children: items),
    );
  }
}
