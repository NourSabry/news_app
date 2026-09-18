import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import '../../../app/app_router.dart';
import '../../../app/article_sync.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/models/models.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/state_view.dart';
import '../../bookmarks/presentation/bloc/bookmarks_bloc.dart';
import '../domain/details_repository.dart';
import 'bloc/details_bloc.dart';
import 'widgets/article_body.dart';
import 'widgets/details_bottom_bar.dart';
import 'widgets/details_header.dart';
import 'widgets/details_hero.dart';
import 'widgets/related_stories.dart';

class ArticleDetailsScreen extends StatelessWidget {
  final Article article;

  const ArticleDetailsScreen({super.key, required this.article});

  /// Pushed by id alone (deep links). A placeholder seeds [DetailsBloc] the
  /// same way a card tap's real [Article] does, and `LoadArticle` fetches the
  /// rest — including the unavailable path for an unknown or removed id.
  factory ArticleDetailsScreen.byId(String id, {Key? key}) {
    return ArticleDetailsScreen(
      key: key,
      article: Article(
        id: id,
        title: '',
        summary: '',
        source: '',
        author: const Author(id: '', name: ''),
        topicId: '',
        publishedAt: DateTime.now(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          DetailsBloc(ServiceLocator.instance.get<DetailsRepository>(), article)
            ..add(const LoadArticle()),
      child: _DetailsView(heroTag: 'article-${article.id}'),
    );
  }
}

class _DetailsView extends StatefulWidget {
  final String heroTag;

  const _DetailsView({required this.heroTag});

  @override
  State<_DetailsView> createState() => _DetailsViewState();
}

class _DetailsViewState extends State<_DetailsView> {
  final _scrollController = ScrollController();
  double _progress = 0;
  bool _showBottomBar = false;

  static const _heroHeight = DetailsHero.height;

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
    final position = _scrollController.position;
    final total = position.maxScrollExtent;
    setState(() {
      _progress = total <= 0 ? 0 : (position.pixels / total).clamp(0.0, 1.0);
      _showBottomBar = position.pixels > _heroHeight;
    });
  }

  void _openArticle(Article article) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ArticleDetailsScreen(article: article)),
    );
  }

  void _share() {
    final article = context.read<DetailsBloc>().state.article;
    // iPad presents the share sheet as a popover anchored to this rect, and
    // the platform rejects an empty one.
    final box = context.findRenderObject() as RenderBox?;
    final origin = box == null
        ? null
        : (box.localToGlobal(Offset.zero) & box.size).deflate(
            box.size.shortestSide / 4,
          );
    SharePlus.instance.share(
      ShareParams(
        uri: AppRouter.articleShareLink(article.id),
        subject: article.title,
        sharePositionOrigin: origin,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<DetailsBloc>().state;

    if (state.isUnavailable) {
      final isBookmarked = context.select<BookmarksBloc, bool>(
        (bloc) => bloc.state.contains(state.article.id),
      );
      return Scaffold(
        body: SafeArea(
          child: StateView(
            icon: Icons.unpublished_outlined,
            accent: true,
            title: 'This story was pulled.',
            body: "The publisher removed it, so it's no longer available.",
            primaryActionLabel: 'Back to the feed',
            onPrimaryAction: () =>
                Navigator.of(context).popUntil((route) => route.isFirst),
            secondaryActionLabel: isBookmarked ? 'Remove from saved' : null,
            onSecondaryAction: isBookmarked
                ? () => context.toggleBookmark(state.article)
                : null,
          ),
        ),
      );
    }

    final article = context.liveArticle(state.article);
    final p = context.palette;

    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: DetailsHero(
                  imageUrl: article.image,
                  heroTag: widget.heroTag,
                  onBack: () => Navigator.of(context).maybePop(),
                  onShare: _share,
                ),
              ),
              SliverToBoxAdapter(
                child: DetailsHeader(
                  article: article,
                  topicName: state.topicName,
                  fromCache: state.fromCache && !state.isLoading,
                  lastSyncedAt: state.lastSyncedAt,
                  onLike: () => context.toggleLike(article),
                  onBookmark: () => context.toggleBookmark(article),
                ),
              ),
              _buildBody(context, state),
              if (state.related.isNotEmpty)
                SliverToBoxAdapter(
                  child: RelatedStories(
                    topicName: state.topicName,
                    articles: state.related,
                    onTap: _openArticle,
                  ),
                ),
              const SliverToBoxAdapter(
                child: SizedBox(height: AppSpacing.dockClearance),
              ),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AnimatedSlide(
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOutCubic,
              offset: _showBottomBar ? Offset.zero : const Offset(0, 1.5),
              child: DetailsBottomBar(
                article: article,
                onLike: () => context.toggleLike(article),
                onBookmark: () => context.toggleBookmark(article),
                onShare: _share,
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 2,
              child: LinearProgressIndicator(
                value: _progress,
                minHeight: 2,
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation(p.accent),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, DetailsState state) {
    final body = state.article.body;
    if (body != null) return ArticleBody(blocks: body);
    if (state.errorMessage != null) {
      return SliverToBoxAdapter(
        child: SizedBox(
          height: 420,
          child: StateView(
            icon: Icons.wifi_off_rounded,
            title: "We couldn't load this story.",
            body: 'Check your connection and try again.',
            primaryActionLabel: 'Try again',
            onPrimaryAction: () =>
                context.read<DetailsBloc>().add(const LoadArticle()),
          ),
        ),
      );
    }
    return const SliverToBoxAdapter(child: ArticleBodyShimmer());
  }
}
