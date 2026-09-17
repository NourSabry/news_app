import 'package:flutter/material.dart';
import '../../../core/models/models.dart';

abstract class SettingsRepository {
  ThemeMode getThemeMode();

  Future<void> setThemeMode(ThemeMode mode);

  List<String> getSelectedTopicIds();

  Future<void> setSelectedTopicIds(List<String> ids);

  bool getOnboardingCompleted();

  Future<void> setOnboardingCompleted(bool completed);

  Future<List<Topic>> getTopics();

  Future<void> clearCache();
}
