import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app/core/network/api_client.dart';
import 'package:news_app/core/storage/local_storage.dart';
import 'package:news_app/features/search/data/search_repository_impl.dart';

class MockApiClient extends Mock implements ApiClient {}

void main() {
  late MockApiClient api;
  late SearchRepositoryImpl repository;

  setUp(() {
    api = MockApiClient();
    repository = SearchRepositoryImpl(api, LocalStorage.inMemory());
  });

  test(
    'getSources(topicIds:) returns only the chosen topics\' sources',
    () async {
      when(() => api.getSources()).thenAnswer(
        (_) async => {
          't_technology': ['Mobile Daily', 'TechWire'],
          't_business': ['Market Brief'],
        },
      );

      final sources = await repository.getSources(topicIds: {'t_technology'});

      expect(sources, ['Mobile Daily', 'TechWire']);
    },
  );

  test(
    'getSources() with no topic flattens and dedupes every topic\'s sources',
    () async {
      when(() => api.getSources()).thenAnswer(
        (_) async => {
          't_technology': ['TechWire', 'Mobile Daily'],
          't_business': ['Market Brief', 'TechWire'],
        },
      );

      final sources = await repository.getSources();

      expect(sources.toSet(), {'TechWire', 'Mobile Daily', 'Market Brief'});
    },
  );
}
