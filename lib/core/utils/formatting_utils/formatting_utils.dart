// lib/core/utils/formatting_utils/formatting_utils.dart

import 'package:intl/intl.dart';

class AppFormatUtils {
  // Format DateTime to standard string format (e.g., 11-Aug-2026)
  static String formatDate(DateTime? date) {
    return DateFormat('dd-MMM-yyyy').format(date ?? DateTime.now());
  }

  // Format currency values with locale rules
  static String formatCurrency(double amount) {
    return NumberFormat.currency(locale: 'en_US', symbol: '\$').format(amount);
  }

  // Formats US phone numbers cleanly based on length
  static String formatPhoneNumber(String phoneNumber) {
    if (phoneNumber.length == 10) {
      return '(${phoneNumber.substring(0, 3)}) ${phoneNumber.substring(3, 6)}-${phoneNumber.substring(6)}';
    } else if (phoneNumber.length == 11) {
      return '(${phoneNumber.substring(0, 4)}) ${phoneNumber.substring(4, 7)}-${phoneNumber.substring(7)}';
    }
    return phoneNumber;
  }

  // Formats international phone numbers dynamically
  static String internationalFormatPhoneNumber(String phoneNumber) {
    var digitsOnly = phoneNumber.replaceAll(RegExp(r'\D'), '');
    if (digitsOnly.length < 3) return phoneNumber;

    String countryCode = '+${digitsOnly.substring(0, 2)}';
    digitsOnly = digitsOnly.substring(2);

    final formattedNumber = StringBuffer()..write('($countryCode) ');

    int i = 0;
    while (i < digitsOnly.length) {
      int groupLength = (i == 0 && countryCode == '+1') ? 3 : 2;
      int end = i + groupLength;

      if (end > digitsOnly.length) end = digitsOnly.length;

      formattedNumber.write(digitsOnly.substring(i, end));
      if (end < digitsOnly.length) {
        formattedNumber.write(' ');
      }
      i = end;
    }
    return formattedNumber.toString();
  }

  // Formats active duration into human-readable shorthand
  static String formatDuration(int totalSeconds) {
    if (totalSeconds < 60) {
      return '$totalSeconds sec';
    } else if (totalSeconds < 3600) {
      int minutes = totalSeconds ~/ 60;
      int seconds = totalSeconds % 60;
      return seconds == 0
          ? '$minutes min'
          : '$minutes:${seconds.toString().padLeft(2, '0')} min';
    } else {
      int hours = totalSeconds ~/ 3600;
      int remainingMinutes = (totalSeconds % 3600) ~/ 60;
      return '$hours hr ${remainingMinutes.toString().padLeft(2, '0')} min';
    }
  }

  // Generates current social feed baseline date (e.g., Tue, 11, Aug)
  static String formatSocialFeedTime() {
    return DateFormat('EEE, dd, MMM', 'en_US').format(DateTime.now());
  }

  // Relative calculation for DateTime sources
  static String timeAgoSinceDate(DateTime date, {bool numericDates = true}) {
    final difference = DateTime.now().difference(date);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks week${weeks == 1 ? '' : 's'} ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months month${months == 1 ? '' : 's'} ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years year${years == 1 ? '' : 's'} ago';
    }
  }

  // Post entry method wrapper
  static String getFormattedPostTimestamp(DateTime postTimestamp) {
    return timeAgoSinceDate(postTimestamp);
  }

  // Formats full extended layout for comment dates
  static String formatCommentTime(DateTime date) {
    return DateFormat('EEEE, dd, MMMM', 'en_US').format(date);
  }

  // Relative calculation for comments using native DateTime
  static String commentTimeAgoSinceDate(
    DateTime date, {
    bool numericDates = true,
  }) {
    return timeAgoSinceDate(date, numericDates: numericDates);
  }

  // Comment entry method wrapper
  static String getCommentFormattedPostTimestamp(DateTime postTimestamp) {
    return commentTimeAgoSinceDate(postTimestamp);
  }

  // Detailed chat message relative time engine
  static String formatMessageTimestamp(DateTime date) {
    final difference = DateTime.now().difference(date);

    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes} minutes ago';
    if (difference.inHours < 24) return '${difference.inHours} hours ago';
    if (difference.inDays == 1) return 'Yesterday';
    if (difference.inDays < 7) return '${difference.inDays} days ago';

    if (difference.inDays < 30) {
      int weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks > 1 ? 'weeks' : 'week'} ago';
    }
    if (difference.inDays < 365) {
      int months = (difference.inDays / 30).floor();
      return '$months ${months > 1 ? 'months' : 'month'} ago';
    }
    int years = (difference.inDays / 365).floor();
    return '$years ${years > 1 ? 'years' : 'year'} ago';
  }

  // Counts down live duration variables cleanly
  static String formatRemainingTime(Duration duration) {
    if (duration.isNegative) return "Challenge Ended";

    final days = duration.inDays;
    final hours = duration.inHours % 24;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;

    if (days > 0) {
      return "$days Day : $hours Hr : $minutes min : $seconds sec";
    } else if (hours > 0) {
      return "$hours Hr : $minutes min : $seconds sec";
    } else if (minutes > 0) {
      return "$minutes min : $seconds sec";
    } else {
      return "$seconds second";
    }
  }
}
