import 'package:intl/intl.dart';

sealed class TimeFormatter {
  static String relative(DateTime time, {DateTime? now}) {
    final current = now ?? DateTime.now();
    final difference = current.difference(time);

    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inHours < 1) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';

    final local = time.toLocal();
    if (_isYesterday(local, current)) return 'Yesterday';
    if (local.year == current.year) return DateFormat.MMMd().format(local);
    return DateFormat.yMMMd().format(local);
  }

  static bool _isYesterday(DateTime local, DateTime now) {
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    return local.year == yesterday.year &&
        local.month == yesterday.month &&
        local.day == yesterday.day;
  }
}
