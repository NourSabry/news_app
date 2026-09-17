import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import '../../features/bookmarks/data/bookmarks_repository_impl.dart';
import '../../features/bookmarks/domain/bookmarks_repository.dart';
import '../../features/details/data/details_repository_impl.dart';
import '../../features/details/domain/details_repository.dart';
import '../../features/devtools/data/dev_tools_repository_impl.dart';
import '../../features/devtools/domain/dev_tools_repository.dart';
import '../../features/feed/data/feed_repository_impl.dart';
import '../../features/feed/domain/feed_repository.dart';
import '../../features/outbox/data/outbox_repository_impl.dart';
import '../../features/outbox/domain/outbox_repository.dart';
import '../../features/reactions/data/reactions_repository_impl.dart';
import '../../features/reactions/domain/reactions_repository.dart';
import '../../features/search/data/search_repository_impl.dart';
import '../../features/search/domain/search_repository.dart';
import '../../features/settings/data/settings_repository_impl.dart';
import '../../features/settings/domain/settings_repository.dart';
import '../network/api_client.dart';
import '../network/mock_api_client.dart';
import '../storage/local_storage.dart';

class ServiceLocator {
  ServiceLocator._();
  static final ServiceLocator instance = ServiceLocator._();

  final Map<Type, Object> _services = {};
  final Map<Type, Object Function()> _factories = {};

  void register<T extends Object>(T service) {
    _services[T] = service;
  }

  void registerFactory<T extends Object>(T Function() factory) {
    _factories[T] = factory;
  }

  T get<T extends Object>() {
    if (_services.containsKey(T)) {
      return _services[T] as T;
    }
    if (_factories.containsKey(T)) {
      final service = _factories[T]!() as T;
      _services[T] = service;
      return service;
    }
    throw Exception('Service not registered: $T');
  }

  void reset() {
    _services.clear();
    _factories.clear();
  }

  Future<void> init({
    LocalStorage? storage,
    MockApiClient? apiClient,
    Connectivity? connectivity,
    BaseCacheManager? imageCache,
  }) async {
    final localStorage = storage ?? await LocalStorage.openHive();
    register<LocalStorage>(localStorage);
    register<Connectivity>(connectivity ?? Connectivity());
    register<BaseCacheManager>(imageCache ?? DefaultCacheManager());

    final api = apiClient ?? MockApiClient(store: localStorage.mockServerStore);
    register<ApiClient>(api);
    register<MockApiClient>(api);

    register<FeedRepository>(FeedRepositoryImpl(api, localStorage));
    register<DetailsRepository>(DetailsRepositoryImpl(api, localStorage));
    register<SearchRepository>(SearchRepositoryImpl(api, localStorage));
    register<SettingsRepository>(SettingsRepositoryImpl(api, localStorage));

    register<DevToolsRepository>(DevToolsRepositoryImpl(api));

    final outbox = OutboxRepositoryImpl(api, localStorage);
    register<OutboxRepository>(outbox);
    register<ReactionsRepository>(ReactionsRepositoryImpl(api, outbox, localStorage));
    register<BookmarksRepository>(BookmarksRepositoryImpl(api, localStorage, outbox));
  }
}
