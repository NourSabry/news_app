import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/models/models.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/snack_bar.dart';
import '../../../core/widgets/empty_view.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../../details/presentation/article_details_screen.dart';
import 'bloc/search_bloc.dart';
import 'widgets/recent_searches.dart';
import 'widgets/search_field.dart';
import 'widgets/search_results.dart';
import 'widgets/suggestion_list.dart';
import 'widgets/topic_filter_chips.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

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
                padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.md),
                child: SearchField(
                  controller: _textController,
                  onChanged: _onTextChanged,
                  onSubmitted: (text) => _bloc.add(SubmitSearch(text)),
                  onClear: _onClear,
                ),
              ),
              TopicFilterChips(
                topics: state.topics,
                selectedId: state.selectedTopicId,
                onSelected: (id) => _bloc.add(TopicFilterChanged(id)),
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
      return RecentSearches(
        queries: state.recentSearches,
        onTap: (query) => _bloc.add(SubmitSearch(query)),
        onClear: () => _bloc.add(const ClearRecentSearches()),
      );
    }
    if (!state.hasSearched) {
      return SuggestionList(
        suggestions: state.suggestions,
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
      return ErrorView(message: error, onRetry: () => _bloc.add(SubmitSearch(state.query)));
    }
    return EmptyView(
      message: 'No results for "${state.query}"',
      icon: Icons.search_off_rounded,
    );
  }
}
