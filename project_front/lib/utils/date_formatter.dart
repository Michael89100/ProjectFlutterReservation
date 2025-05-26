import 'package:intl/intl.dart';

class DateFormatter {
  static const List<String> _frenchMonths = [
    'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
    'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre'
  ];

  static const List<String> _frenchDays = [
    'lundi', 'mardi', 'mercredi', 'jeudi', 'vendredi', 'samedi', 'dimanche'
  ];

  /// Formate une date en français (ex: "lundi 15 janvier 2024")
  static String formatDateFrench(DateTime date) {
    final dayName = _frenchDays[date.weekday - 1];
    final monthName = _frenchMonths[date.month - 1];
    return '$dayName ${date.day} $monthName ${date.year}';
  }

  /// Formate une heure en français (ex: "14h30")
  static String formatTimeFrench(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}h${time.minute.toString().padLeft(2, '0')}';
  }

  /// Formate une date et heure complète en français
  static String formatDateTimeFrench(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final reservationDate = DateTime(dateTime.year, dateTime.month, dateTime.day);
    
    String dateStr;
    if (reservationDate == today) {
      dateStr = "Aujourd'hui";
    } else if (reservationDate == today.add(const Duration(days: 1))) {
      dateStr = "Demain";
    } else if (reservationDate == today.subtract(const Duration(days: 1))) {
      dateStr = "Hier";
    } else {
      dateStr = formatDateFrench(dateTime);
    }
    
    final timeStr = formatTimeFrench(dateTime);
    return "$dateStr à $timeStr";
  }

  /// Formate une date courte (ex: "15/01/2024")
  static String formatDateShort(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  /// Formate une date relative (ex: "Il y a 2 heures")
  static String formatRelativeDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'À l\'instant';
        }
        return 'Il y a ${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''}';
      }
      return 'Il y a ${difference.inHours} heure${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inDays == 1) {
      return 'Hier';
    } else if (difference.inDays < 7) {
      return 'Il y a ${difference.inDays} jour${difference.inDays > 1 ? 's' : ''}';
    } else {
      return formatDateShort(date);
    }
  }
} 