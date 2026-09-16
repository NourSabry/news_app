extension FutureFallback<T> on Future<T> {
  Future<T> orFallback(T fallback) => catchError((Object _) => fallback);
}
