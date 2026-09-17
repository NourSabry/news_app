import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/future_extensions.dart';
import '../../domain/settings_repository.dart';
import 'settings_state.dart';

export 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final SettingsRepository _repository;

  SettingsCubit(SettingsRepository repository)
      : _repository = repository,
        super(SettingsState(
          themeMode: repository.getThemeMode(),
          selectedTopicIds: repository.getSelectedTopicIds(),
          onboardingCompleted: repository.getOnboardingCompleted(),
        ));

  Future<void> loadTopics() async {
    if (state.topics.isNotEmpty || state.isLoadingTopics) return;
    emit(state.copyWith(isLoadingTopics: true));
    final topics = await _repository.getTopics().orFallback(const []);
    emit(state.copyWith(topics: topics, isLoadingTopics: false));
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    emit(state.copyWith(themeMode: mode));
    await _repository.setThemeMode(mode);
  }

  Future<void> toggleTopic(String topicId) async {
    final ids = state.isSelected(topicId)
        ? state.selectedTopicIds.where((id) => id != topicId).toList()
        : [...state.selectedTopicIds, topicId];
    emit(state.copyWith(selectedTopicIds: ids));
    await _repository.setSelectedTopicIds(ids);
  }

  Future<void> completeOnboarding() => _setOnboardingCompleted(true);

  Future<void> resetOnboarding() => _setOnboardingCompleted(false);

  Future<void> _setOnboardingCompleted(bool completed) async {
    await _repository.setOnboardingCompleted(completed);
    emit(state.copyWith(onboardingCompleted: completed));
  }

  Future<void> clearCache() => _repository.clearCache();

  int get cachedArticleCount => _repository.getCachedArticleCount();
}
