import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../../../../core/models/models.dart';

class SettingsState extends Equatable {
  final ThemeMode themeMode;
  final List<String> selectedTopicIds;
  final List<Topic> topics;
  final bool isLoadingTopics;
  final bool onboardingCompleted;

  const SettingsState({
    this.themeMode = ThemeMode.system,
    this.selectedTopicIds = const [],
    this.topics = const [],
    this.isLoadingTopics = false,
    this.onboardingCompleted = false,
  });

  bool isSelected(String topicId) => selectedTopicIds.contains(topicId);

  SettingsState copyWith({
    ThemeMode? themeMode,
    List<String>? selectedTopicIds,
    List<Topic>? topics,
    bool? isLoadingTopics,
    bool? onboardingCompleted,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      selectedTopicIds: selectedTopicIds ?? this.selectedTopicIds,
      topics: topics ?? this.topics,
      isLoadingTopics: isLoadingTopics ?? this.isLoadingTopics,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
    );
  }

  @override
  List<Object?> get props => [
    themeMode,
    selectedTopicIds,
    topics,
    isLoadingTopics,
    onboardingCompleted,
  ];
}
