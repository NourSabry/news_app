import 'package:flutter/material.dart';
import '../../../core/models/models.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/local_storage.dart';
import '../domain/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final ApiClient _api;
  final LocalStorage _storage;

  SettingsRepositoryImpl(this._api, this._storage);

  @override
  ThemeMode getThemeMode() {
    return ThemeMode.values.asNameMap()[_storage.getThemeMode()] ?? ThemeMode.system;
  }

  @override
  Future<void> setThemeMode(ThemeMode mode) => _storage.setThemeMode(mode.name);

  @override
  List<String> getSelectedTopicIds() => _storage.getSelectedTopicIds();

  @override
  Future<void> setSelectedTopicIds(List<String> ids) => _storage.setSelectedTopicIds(ids);

  @override
  bool getOnboardingCompleted() => _storage.getOnboardingCompleted();

  @override
  Future<void> setOnboardingCompleted(bool completed) =>
      _storage.setOnboardingCompleted(completed);

  @override
  Future<List<Topic>> getTopics() => _api.getTopics();

  @override
  Future<void> clearCache() async {
    await _storage.clearFeedCache();
    await _storage.clearArticleCache();
  }
}
