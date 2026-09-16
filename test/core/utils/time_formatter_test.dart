import 'package:flutter_test/flutter_test.dart';
import 'package:news_app/core/utils/time_formatter.dart';

void main() {
  final now = DateTime(2026, 9, 16, 12, 0);

  String format(DateTime time) => TimeFormatter.relative(time, now: now);

  test('formats recent times relatively', () {
    expect(format(now.subtract(const Duration(seconds: 30))), 'Just now');
    expect(format(now.subtract(const Duration(minutes: 5))), '5m ago');
    expect(format(now.subtract(const Duration(hours: 2))), '2h ago');
  });

  test('formats yesterday and older dates', () {
    expect(format(DateTime(2026, 9, 15, 8)), 'Yesterday');
    expect(format(DateTime(2026, 9, 12)), 'Sep 12');
    expect(format(DateTime(2025, 12, 25)), 'Dec 25, 2025');
  });

  test('treats future timestamps as just now', () {
    expect(format(now.add(const Duration(minutes: 3))), 'Just now');
  });
}
