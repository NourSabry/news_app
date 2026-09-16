import '../../features/feed/data/feed_repository_impl.dart';
import '../../features/feed/domain/feed_repository.dart';
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

  Future<void> init() async {
    final localStorage = LocalStorage();
    await localStorage.init();
    register<LocalStorage>(localStorage);

    final apiClient = MockApiClient();
    register<ApiClient>(apiClient);
    register<MockApiClient>(apiClient);

    register<FeedRepository>(FeedRepositoryImpl(apiClient, localStorage));
  }
}
