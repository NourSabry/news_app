import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

EventTransformer<E> debounceRestartable<E>(Duration duration) {
  return (events, mapper) => _switchMap(_debounce(events, duration), mapper);
}

Stream<E> _debounce<E>(Stream<E> events, Duration duration) {
  Timer? timer;
  return events.transform(
    StreamTransformer<E, E>.fromHandlers(
      handleData: (event, sink) {
        timer?.cancel();
        timer = Timer(duration, () => sink.add(event));
      },
      handleDone: (sink) {
        timer?.cancel();
        sink.close();
      },
    ),
  );
}

Stream<T> _switchMap<S, T>(Stream<S> source, Stream<T> Function(S) mapper) {
  StreamSubscription<S>? outer;
  StreamSubscription<T>? inner;
  late final StreamController<T> controller;
  controller = StreamController<T>(
    onListen: () {
      outer = source.listen(
        (event) {
          inner?.cancel();
          inner = mapper(event).listen(controller.add, onError: controller.addError);
        },
        onError: controller.addError,
        onDone: controller.close,
      );
    },
    onCancel: () async {
      await inner?.cancel();
      await outer?.cancel();
    },
  );
  return controller.stream;
}
