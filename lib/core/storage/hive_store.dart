import 'package:hive_flutter/hive_flutter.dart';
import 'key_value_store.dart';

class HiveStore implements KeyValueStore {
  final Box<String> _box;

  HiveStore(this._box);

  static Future<HiveStore> open(String name) async => HiveStore(await Hive.openBox<String>(name));

  @override
  String? get(String key) => _box.get(key);

  @override
  Iterable<String> get values => _box.values;

  @override
  int get length => _box.length;

  @override
  Future<void> put(String key, String value) => _box.put(key, value);

  @override
  Future<void> delete(String key) => _box.delete(key);

  @override
  Future<void> clear() => _box.clear();

  @override
  Stream<int> watchLength() => _box.watch().map((_) => _box.length);
}
