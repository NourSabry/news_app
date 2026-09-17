import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app/core/models/models.dart';
import 'package:news_app/features/settings/domain/settings_repository.dart';
import 'package:news_app/features/settings/presentation/cubit/settings_cubit.dart';

class MockSettingsRepository extends Mock implements SettingsRepository {}

const topics = [
  Topic(id: 't_technology', name: 'Technology', icon: 'devices'),
  Topic(id: 't_science', name: 'Science', icon: 'science'),
];

void main() {
  late MockSettingsRepository repository;

  setUpAll(() => registerFallbackValue(ThemeMode.system));

  setUp(() {
    repository = MockSettingsRepository();
    when(() => repository.getThemeMode()).thenReturn(ThemeMode.system);
    when(() => repository.getSelectedTopicIds()).thenReturn(const ['t_technology']);
    when(() => repository.getOnboardingCompleted()).thenReturn(true);
    when(() => repository.getTopics()).thenAnswer((_) async => topics);
    when(() => repository.setThemeMode(any())).thenAnswer((_) async {});
    when(() => repository.setSelectedTopicIds(any())).thenAnswer((_) async {});
    when(() => repository.setOnboardingCompleted(any())).thenAnswer((_) async {});
    when(() => repository.clearCache()).thenAnswer((_) async {});
  });

  SettingsCubit build() => SettingsCubit(repository);

  const initial = SettingsState(
    selectedTopicIds: ['t_technology'],
    onboardingCompleted: true,
  );

  test('starts from the persisted theme, topics and onboarding flag', () {
    expect(build().state, initial);
  });

  blocTest<SettingsCubit, SettingsState>(
    'loads topics once',
    build: build,
    act: (cubit) async {
      await cubit.loadTopics();
      await cubit.loadTopics();
    },
    expect: () => [
      initial.copyWith(isLoadingTopics: true),
      initial.copyWith(topics: topics),
    ],
    verify: (_) => verify(() => repository.getTopics()).called(1),
  );

  blocTest<SettingsCubit, SettingsState>(
    'leaves topics empty when they fail to load',
    setUp: () => when(() => repository.getTopics()).thenAnswer((_) => Future<List<Topic>>.error(Exception('offline'))),
    build: build,
    act: (cubit) => cubit.loadTopics(),
    expect: () => [initial.copyWith(isLoadingTopics: true), initial],
  );

  blocTest<SettingsCubit, SettingsState>(
    'persists the theme mode',
    build: build,
    act: (cubit) => cubit.setThemeMode(ThemeMode.dark),
    expect: () => [initial.copyWith(themeMode: ThemeMode.dark)],
    verify: (_) => verify(() => repository.setThemeMode(ThemeMode.dark)).called(1),
  );

  blocTest<SettingsCubit, SettingsState>(
    'toggling adds and removes topics and persists the selection',
    build: build,
    act: (cubit) async {
      await cubit.toggleTopic('t_science');
      await cubit.toggleTopic('t_technology');
    },
    expect: () => [
      initial.copyWith(selectedTopicIds: const ['t_technology', 't_science']),
      initial.copyWith(selectedTopicIds: const ['t_science']),
    ],
    verify: (_) {
      verify(() => repository.setSelectedTopicIds(const ['t_technology', 't_science'])).called(1);
      verify(() => repository.setSelectedTopicIds(const ['t_science'])).called(1);
    },
  );

  blocTest<SettingsCubit, SettingsState>(
    'resetting and completing onboarding flips the flag after persisting it',
    build: build,
    act: (cubit) async {
      await cubit.resetOnboarding();
      await cubit.completeOnboarding();
    },
    expect: () => [
      initial.copyWith(onboardingCompleted: false),
      initial.copyWith(onboardingCompleted: true),
    ],
    verify: (_) {
      verifyInOrder([
        () => repository.setOnboardingCompleted(false),
        () => repository.setOnboardingCompleted(true),
      ]);
    },
  );

  blocTest<SettingsCubit, SettingsState>(
    'clearing the cache delegates to the repository without changing state',
    build: build,
    act: (cubit) => cubit.clearCache(),
    expect: () => const <SettingsState>[],
    verify: (_) => verify(() => repository.clearCache()).called(1),
  );
}
