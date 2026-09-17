import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/network/api_client.dart';
import '../../../feed/domain/feed_repository.dart';
import 'onboarding_state.dart';

export 'onboarding_state.dart';

/// Fetches the real headlines onboarding needs: 3 for the masthead teaser
/// (screen 1) and a preview of the actual feed for the chosen sections
/// (screen 3) — the same [FeedRepository] call the real Home feed makes,
/// so its cache is already warm by "Start reading" (Part 6.5).
class OnboardingCubit extends Cubit<OnboardingState> {
  final FeedRepository _repository;
  final ApiClient _api;

  OnboardingCubit(this._repository, this._api) : super(const OnboardingState());

  /// Article counts per topic for the section tiles (screen 2). Reads
  /// straight from [ApiClient] (not through the repository) so a cosmetic
  /// count never writes to the offline feed cache.
  Future<void> loadTopicCounts(List<String> topicIds) async {
    final counts = <String, int>{};
    await Future.wait(topicIds.map((id) async {
      try {
        final page = await _api.getFeed(topics: [id], pageSize: 1);
        counts[id] = page.total;
      } catch (_) {
        // Leave the count out — the tile just omits the caption.
      }
    }));
    emit(state.copyWith(topicCounts: counts));
  }

  Future<void> loadHeadlines() async {
    try {
      final page = await _repository.fetchPage();
      emit(state.copyWith(headlines: page.data.take(3).toList()));
    } catch (_) {
      // No connectivity yet at first launch — the masthead just skips the teaser.
    }
  }

  Future<void> loadPreview() async {
    emit(state.copyWith(isLoadingPreview: true));
    try {
      final page = await _repository.fetchPage();
      emit(state.copyWith(preview: page.data.take(3).toList(), isLoadingPreview: false));
    } catch (_) {
      emit(state.copyWith(isLoadingPreview: false));
    }
  }
}
