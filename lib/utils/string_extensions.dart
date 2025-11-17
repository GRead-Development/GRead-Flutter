import 'package:html/parser.dart';
import 'package:intl/intl.dart';

extension StringExtensions on String {
  /// Decode HTML entities like &amp;, &lt;, etc.
  String get decodingHTMLEntities {
    return this
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&nbsp;', ' ');
  }

  /// Strip HTML tags from a string
  String stripHTML() {
    final document = parse(this);
    return document.body?.text ?? this;
  }

  /// Convert date string to relative time (e.g., "2 hours ago")
  String toRelativeTime() {
    try {
      final dateTime = DateTime.parse(this);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inDays > 365) {
        final years = (difference.inDays / 365).floor();
        return years == 1 ? '1 year ago' : '$years years ago';
      } else if (difference.inDays > 30) {
        final months = (difference.inDays / 30).floor();
        return months == 1 ? '1 month ago' : '$months months ago';
      } else if (difference.inDays > 0) {
        return difference.inDays == 1 ? '1 day ago' : '${difference.inDays} days ago';
      } else if (difference.inHours > 0) {
        return difference.inHours == 1 ? '1 hour ago' : '${difference.inHours} hours ago';
      } else if (difference.inMinutes > 0) {
        return difference.inMinutes == 1 ? '1 minute ago' : '${difference.inMinutes} minutes ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return this;
    }
  }

  /// Format date string to readable format
  String toReadableDate() {
    try {
      final dateTime = DateTime.parse(this);
      return DateFormat('MMM d, y').format(dateTime);
    } catch (e) {
      return this;
    }
  }

  /// Convert hex color string to int (for Color constructor)
  int hexToInt() {
    final hex = replaceAll('#', '');
    return int.parse('FF$hex', radix: 16);
  }
}

extension DateTimeExtensions on DateTime {
  /// Convert DateTime to relative time string
  String toRelativeTime() {
    return toIso8601String().toRelativeTime();
  }

  /// Convert DateTime to readable date string
  String toReadableDate() {
    return DateFormat('MMM d, y').format(this);
  }
}
