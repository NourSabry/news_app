import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../app/widgets/live_article_card.dart';
import '../../../core/models/models.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/snack_bar.dart';
import '../../../core/widgets/pagination_footer.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../../../core/widgets/state_view.dart';
import '../../details/presentation/article_details_screen.dart';
import '../../outbox/presentation/cubit/outbox_cubit.dart';
import '../../settings/presentation/settings_screen.dart';
import 'bloc/feed_bloc.dart';
import 'widgets/article_cards.dart';
import 'widgets/feed_header.dart';
import 'widgets/new_stories_banner.dart';
import 'widgets/sections_footer.dart';

class FeedScreen extends StatefulWidget {
  final VoidCallback onSearchTap;

  /// Slot above the list for the freshness/sync banner.
  final Widget? banner;

  const FeedScreen({super.key, required this.onSearchTap, this.banner});

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

  void _showPending() {
    context.read<FeedBloc>().add(const ShowPendingArticles());
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    }
  }

  static String? _snackMessageFor(FeedState state) {
    return state.notice ?? (state.isEmpty ? null : state.errorMessage);
  }

  /// Where the new-stories pill sits: just under the header, following it
  /// as it collapses.
  double _pillTop(FeedHeader header) {
    final offset = _scrollController.hasClients
        ? _scrollController.offset
        : 0.0;
    final visible = (header.maxExtent - offset).clamp(
      header.minExtent,
      header.maxExtent,
    );
    return visible + AppSpacing.sm;
  }

  FeedHeader _header(BuildContext context, FeedState state, double topPadding) {
    return FeedHeader(
      trending: state.trending,
      scope: state.scope,
      onTopicTap: (label) =>
          context.read<FeedBloc>().add(FeedScopeChanged(label)),
      onClearScope: () =>
          context.read<FeedBloc>().add(const FeedScopeChanged(null)),
      onSearchTap: widget.onSearchTap,
      onSettingsTap: _openSettings,
      topPadding: topPadding,
      textScale: MediaQuery.textScalerOf(context).scale(14) / 14,
    );
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top;
    return MultiBlocListener(
      listeners: [
        BlocListener<FeedBloc, FeedState>(
          listenWhen: (previous, current) =>
              _snackMessageFor(current) != null &&
              _snackMessageFor(previous) != _snackMessageFor(current),
          listener: (context, state) =>
              showSnackBarMessage(context, _snackMessageFor(state)!),
        ),
        BlocListener<FeedBloc, FeedState>(
          listenWhen: (previous, current) => previous.scope != current.scope,
          listener: (_, _) {
            if (_scrollController.hasClients) _scrollController.jumpTo(0);
          },
        ),
      ],
      child: BlocBuilder<FeedBloc, FeedState>(
        builder: (context, state) {
          final header = _header(context, state, topPadding);
          return Stack(
            alignment: Alignment.topCenter,
            children: [
              _buildBody(context, state, header),
              AnimatedBuilder(
                animation: _scrollController,
                builder: (context, child) =>
                    Positioned(top: _pillTop(header), child: child!),
                child: NewStoriesBanner(
                  count: state.pendingArticles.length,
                  firstHeadline: state.pendingArticles.isEmpty
                      ? null
                      : state.pendingArticles.first.title,
                  onTap: _showPending,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    FeedState state,
    FeedHeader delegate,
  ) {
    final p = context.palette;
    final header = SliverPersistentHeader(pinned: true, delegate: delegate);

    if (state.isEmpty) {
      final content = switch (state.status) {
        FeedStatus.failure => StateView(
          icon: Icons.wifi_off_rounded,
          title: "We couldn't reach the newsroom.",
          body: 'Check your connection and try again.',
          primaryActionLabel: 'Try again',
          onPrimaryAction: () => context.read<FeedBloc>().add(const LoadFeed()),
        ),
        FeedStatus.success => StateView(
          icon: Icons.auto_stories_outlined,
          title: 'Nothing here yet.',
          body: 'No stories match your sections. Try adding a few more.',
          primaryActionLabel: 'Edit sections',
          onPrimaryAction: _openSettings,
        ),
        _ => const HomeFeedSkeleton(),
      };
      return CustomScrollView(
        physics: const NeverScrollableScrollPhysics(),
        slivers: [
          header,
          if (widget.banner != null) PinnedHeaderSliver(child: widget.banner),
          SliverFillRemaining(hasScrollBody: false, child: content),
        ],
      );
    }

    return RefreshIndicator.adaptive(
      onRefresh: _onRefresh,
      color: p.ink,
      backgroundColor: p.surface,
      edgeOffset: delegate.minExtent,
      child: CustomScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        slivers: [
          header,
          if (widget.banner != null) PinnedHeaderSliver(child: widget.banner),
          _buildArticles(state),
          SliverToBoxAdapter(
            child: PaginationFooter(
              isLoadingMore: state.isLoadingMore,
              hasMore: state.hasMore,
            ),
          ),
          if (!state.hasMore)
            SliverToBoxAdapter(
              child: SectionsFooter(
                count: state.selectedTopicIds.length,
                onEdit: _openSettings,
              ),
            ),
          const SliverToBoxAdapter(
            child: SizedBox(height: AppSpacing.dockClearance),
          ),
        ],
      ),
    );
  }

  /// Lead, then one standard, then compact cards — with a standard card
  /// every fourth item so the list keeps a visual rhythm.
  static ArticleCardVariant _variantFor(int index) {
    if (index == 0) return ArticleCardVariant.lead;
    if (index == 1 || index % 4 == 1) return ArticleCardVariant.standard;
    return ArticleCardVariant.compact;
  }

  Widget _buildArticles(FeedState state) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.gutter,
        AppSpacing.sm,
        AppSpacing.gutter,
        0,
      ),
      sliver: SliverList.separated(
        itemCount: state.articles.length,
        separatorBuilder: (_, index) => SizedBox(
          height:
              _variantFor(index + 1) == ArticleCardVariant.compact &&
                  _variantFor(index) == ArticleCardVariant.compact
              ? AppSpacing.xl
              : AppSpacing.xxxl,
        ),
        itemBuilder: (context, index) {
          final article = state.articles[index];
          return LiveArticleCard(
            key: ValueKey(article.id),
            article: article,
            topicName: state.topicNameFor(article.topicId),
            variant: _variantFor(index),
            onTap: () => _openArticle(article),
          );
        },
      ),
    );
  }
}
