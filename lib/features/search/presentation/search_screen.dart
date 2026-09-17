import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/models/models.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/snack_bar.dart';
import '../../../core/widgets/edition_pill.dart';
import '../../../core/widgets/halftone_painter.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../../../core/widgets/state_view.dart';
import '../../details/presentation/article_details_screen.dart';
import '../domain/search_filters.dart';
import 'bloc/search_bloc.dart';
import 'widgets/explore_landing.dart';
import 'widgets/filter_chips_row.dart';
import 'widgets/filter_sheet.dart';
import 'widgets/search_field.dart';
import 'widgets/search_results.dart';
import 'widgets/suggestion_list.dart';

class SearchScreen extends StatefulWidget {
  final FocusNode? focusNode;

  const SearchScreen({super.key, this.focusNode});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  static const _loadMoreThreshold = 400.0;

  final _textController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  SearchBloc get _bloc => context.read<SearchBloc>();

  void _onScroll() {
    if (_scrollController.position.extentAfter < _loadMoreThreshold) {
      _bloc.add(const LoadMoreResults());
    }
  }

  void _onTextChanged(String text) {
    _bloc.add(text.trim().isEmpty ? const ClearSearch() : QueryChanged(text));
  }

  void _onClear() {
    _textController.clear();
    _bloc.add(const ClearSearch());
  }

  void _syncQuery(String query) {
    if (_textController.text.trim() == query) return;
    _textController.value = TextEditingValue(
      text: query,
      selection: TextSelection.collapsed(offset: query.length),
    );
  }

  void _openArticle(Article article) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ArticleDetailsScreen(article: article)),
    );
  }

  Future<void> _openFilterSheet(SearchState state) async {
    final applied = await FilterSheet.show(context, initial: state.filters, topics: state.topics);
    if (applied != null) _bloc.add(FiltersChanged(applied));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: MultiBlocListener(
        listeners: [
          BlocListener<SearchBloc, SearchState>(
            listenWhen: (previous, current) => previous.query != current.query,
            listener: (_, state) => _syncQuery(state.query),
          ),
          BlocListener<SearchBloc, SearchState>(
            listenWhen: (previous, current) =>
                current.errorMessage != null &&
                previous.errorMessage != current.errorMessage &&
                current.results.isNotEmpty,
            listener: (context, state) => showSnackBarMessage(context, state.errorMessage!),
          ),
        ],
        child: BlocBuilder<SearchBloc, SearchState>(
          builder: (context, state) => Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.gutter, AppSpacing.lg, AppSpacing.gutter, AppSpacing.md),
                child: SearchField(
                  controller: _textController,
                  focusNode: widget.focusNode,
                  onChanged: _onTextChanged,
                  onSubmitted: (text) => _bloc.add(SubmitSearch(text)),
                  onClear: _onClear,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.gutter, 0, AppSpacing.gutter, AppSpacing.sm),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: EditionPill(
                    label: state.filters.isEmpty ? 'Filters' : 'Filters (${state.filters.activeCount})',
                    onTap: () => _openFilterSheet(state),
                  ),
                ),
              ),
              FilterChipsRow(
                filters: state.filters,
                topicName: state.filters.topicId == null ? '' : state.topicNameFor(state.filters.topicId!),
                onChanged: (filters) => _bloc.add(FiltersChanged(filters)),
              ),
              Expanded(child: _buildBody(state)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(SearchState state) {
    if (state.query.isEmpty) {
      return ExploreLanding(
        queries: state.recentSearches,
        topics: state.topics,
        onQueryTap: (query) => _bloc.add(SubmitSearch(query)),
        onClear: () => _bloc.add(const ClearRecentSearches()),
        onTopicTap: (topic) => _bloc.add(SubmitSearch('', filters: SearchFilters(topicId: topic.id))),
      );
    }
    if (!state.hasSearched) {
      return SuggestionList(
        suggestions: state.suggestions,
        query: state.query,
        onTap: (suggestion) => _bloc.add(SubmitSearch(suggestion)),
      );
    }
    if (state.isLoading) return const FeedShimmer();
    if (state.results.isEmpty) return _buildEmptyResults(state);
    return SearchResults(state: state, controller: _scrollController, onTap: _openArticle);
  }

  Widget _buildEmptyResults(SearchState state) {
    final error = state.errorMessage;
    if (error != null) {
      return StateView(
        shape: HalftoneShape.diagonal,
        title: 'Search is offline.',
        body: "We'll try again when you're back online.",
        primaryActionLabel: 'Retry',
        onPrimaryAction: () => _bloc.add(SubmitSearch(state.query)),
      );
    }
    return StateView(
      shape: HalftoneShape.wave,
      title: 'Nothing on the wire for "${state.query}".',
      body: 'No stories match your search.',
      secondaryActionLabel: state.filters.isEmpty ? null : 'Try fewer filters',
      onSecondaryAction: state.filters.isEmpty
          ? null
          : () => _bloc.add(SubmitSearch(state.query, filters: SearchFilters.none)),
    );
  }
}
