import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/network/api_client.dart';
import '../../../feed/domain/feed_repository.dart';
import 'onboarding_state.dart';

export 'onboarding_state.dart';

/// Fetches the real content onboarding shows: a few headlines for the
/// welcome collage, a cover and count per topic for the section tiles, and
/// a preview of the actual feed for the chosen sections. The preview goes
/// through [FeedRepository], so the Home cache is warm by "Start reading".
class OnboardingCubit extends Cubit<OnboardingState> {
  final FeedRepository _repository;
  final ApiClient _api;

  OnboardingCubit(this._repository, this._api) : super(const OnboardingState());

  /// Per-topic story count and cover image for the section tiles. Reads
  /// straight from [ApiClient] so a cosmetic lookup never writes to the
  /// offline feed cache.
  Future<void> loadTopicCounts(List<String> topicIds) async {
    final counts = <String, int>{};
    final covers = <String, String>{};
    await Future.wait(
      topicIds.map((id) async {
        try {
          final page = await _api.getFeed(topics: [id], pageSize: 1);
          counts[id] = page.total;
          final image = page.data.isEmpty ? null : page.data.first.image;
          if (image != null && image.isNotEmpty) covers[id] = image;
        } catch (_) {
          // Leave it out — the tile just omits the caption and cover.
        }
      }),
    );
    emit(state.copyWith(topicCounts: counts, topicCovers: covers));
  }

  Future<void> loadHeadlines() async {
    try {
      final page = await _repository.fetchPage();
      emit(state.copyWith(headlines: page.data.take(3).toList()));
    } catch (_) {
      // No connectivity at first launch — the welcome page skips the collage.
    }
  }

  Future<void> loadPreview() async {
    emit(state.copyWith(isLoadingPreview: true));
    try {
      final page = await _repository.fetchPage();
      emit(
        state.copyWith(
          preview: page.data.take(3).toList(),
          isLoadingPreview: false,
        ),
      );
    } catch (_) {
      emit(state.copyWith(isLoadingPreview: false));
    }
  }
}
