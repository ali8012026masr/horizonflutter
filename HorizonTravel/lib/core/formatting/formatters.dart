import 'package:intl/intl.dart';

class Formatters {
  static String formatCurrency(double? amount) {
    if (amount == null) return '\$0.00';
    return NumberFormat.currency(locale: 'en_US', symbol: '\$', decimalDigits: 2).format(amount);
  }

  static String capitalizeWords(String? text) {
    if (text == null || text.trim().isEmpty) return '';
    final parts = text.replaceAll('_', ' ').split(' ');
    return parts.where((p) => p.isNotEmpty).map((p) => p[0].toUpperCase() + p.substring(1).toLowerCase()).join(' ');
  }

  static String capitalizeEnum(String? enumValue) {
    if (enumValue == null || enumValue.trim().isEmpty) {
      return '';
    }
    final parts = enumValue.toLowerCase().split('_');
    final buffer = StringBuffer();
    for (final part in parts) {
      if (part.isNotEmpty) {
        if (buffer.isNotEmpty) {
          buffer.write(' ');
        }
        buffer.write(part[0].toUpperCase() + part.substring(1));
      }
    }
    return buffer.toString();
  }

  static String formatDate(String? dateStr) {
    if (dateStr == null || dateStr.trim().isEmpty) {
      return '';
    }
    var cleaned = dateStr.trim();
    if (cleaned.contains('T')) {
      cleaned = cleaned.substring(0, cleaned.indexOf('T'));
    }
    try {
      final parsed = DateFormat('yyyy-MM-dd').parse(cleaned);
      return DateFormat('MMM dd, yyyy').format(parsed);
    } catch (_) {
      return dateStr;
    }
  }

  static String formatDateTime(String? dateTimeStr) {
    if (dateTimeStr == null || dateTimeStr.trim().isEmpty) {
      return '';
    }
    final normalized = dateTimeStr.trim();
    final patterns = [
      "yyyy-MM-dd'T'HH:mm:ss",
      "yyyy-MM-dd'T'HH:mm",
      "yyyy-MM-dd HH:mm:ss",
      "yyyy-MM-dd HH:mm",
    ];
    for (final pattern in patterns) {
      try {
        final parsed = DateFormat(pattern).parse(normalized);
        return DateFormat('MMM dd, yyyy hh:mm a').format(parsed);
      } catch (_) {}
    }
    return dateTimeStr;
  }

  static String formatTime(String? timeStr) {
    if (timeStr == null || timeStr.trim().isEmpty) {
      return '';
    }
    final normalized = timeStr.trim();
    final patterns = ['HH:mm:ss', 'HH:mm'];
    for (final pattern in patterns) {
      try {
        final parsed = DateFormat(pattern).parse(normalized);
        return DateFormat('hh:mm a').format(parsed);
      } catch (_) {}
    }
    return timeStr;
  }
}
