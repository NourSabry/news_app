import 'dart:async';

abstract class KeyValueStore {
  String? get(String key);

  Iterable<String> get values;

  int get length;

  Future<void> put(String key, String value);

  Future<void> delete(String key);

  Future<void> clear();

  Stream<int> watchLength();
}

class MemoryStore implements KeyValueStore {
  final Map<String, String> _data = {};
  final StreamController<int> _changes = StreamController<int>.broadcast();

  @override
  String? get(String key) => _data[key];

  @override
  Iterable<String> get values => _data.values;

  @override
  int get length => _data.length;

  @override
  Future<void> put(String key, String value) async {
    _data[key] = value;
    _notify();
  }

  @override
  Future<void> delete(String key) async {
    _data.remove(key);
    _notify();
  }

  @override
  Future<void> clear() async {
    _data.clear();
    _notify();
  }

  @override
  Stream<int> watchLength() => _changes.stream;

  void _notify() => _changes.add(_data.length);
}
