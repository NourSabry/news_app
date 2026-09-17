import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../app/article_sync.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/models/models.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/halftone_painter.dart';
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

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DetailsBloc(ServiceLocator.instance.get<DetailsRepository>(), article)
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

  static const _heroHeight = 320.0;

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

  void _share() {}

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
            shape: HalftoneShape.radial,
            halftoneOpacity: 0.5,
            title: 'This story was pulled.',
            body: "The publisher removed it, so it's no longer available.",
            primaryActionLabel: 'Back to the feed',
            onPrimaryAction: () => Navigator.of(context).popUntil((route) => route.isFirst),
            secondaryActionLabel: isBookmarked ? 'Remove from saved' : null,
            onSecondaryAction: isBookmarked ? () => context.toggleBookmark(state.article) : null,
          ),
        ),
      );
    }

    final article = context.liveArticle(state.article);
    final brightness = Theme.of(context).brightness;
    final isLight = brightness == Brightness.light;
    final red = isLight ? AppColors.lightRed : AppColors.darkRed;

    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scrollController,
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
                  lastSyncedAt: null,
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
              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxxl)),
            ],
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
                valueColor: AlwaysStoppedAnimation(red),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: _showBottomBar
            ? DetailsBottomBar(
                key: const ValueKey('bottom-bar'),
                article: article,
                onLike: () => context.toggleLike(article),
                onBookmark: () => context.toggleBookmark(article),
                onShare: _share,
              )
            : const SizedBox(key: ValueKey('bottom-bar-hidden')),
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
            shape: HalftoneShape.diagonal,
            title: 'The presses are down.',
            body: "We couldn't reach the newsroom. Check your connection and try again.",
            primaryActionLabel: 'Try again',
            onPrimaryAction: () => context.read<DetailsBloc>().add(const LoadArticle()),
          ),
        ),
      );
    }
    return const SliverToBoxAdapter(child: ArticleBodyShimmer());
  }
}
