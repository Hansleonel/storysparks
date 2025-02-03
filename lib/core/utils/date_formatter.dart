import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class DateFormatter {
  static String getFormattedDate(DateTime date, BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateToCompare = DateTime(date.year, date.month, date.day);
    final difference = today.difference(dateToCompare).inDays;
    final l10n = AppLocalizations.of(context)!;

    if (dateToCompare == today) {
      return l10n.today;
    } else if (dateToCompare == yesterday) {
      return l10n.yesterday;
    } else if (difference < 7) {
      // Si es dentro de la semana actual, mostrar el día
      switch (date.weekday) {
        case 1:
          return l10n.monday;
        case 2:
          return l10n.tuesday;
        case 3:
          return l10n.wednesday;
        case 4:
          return l10n.thursday;
        case 5:
          return l10n.friday;
        case 6:
          return l10n.saturday;
        case 7:
          return l10n.sunday;
        default:
          return '';
      }
    } else if (difference < 30) {
      // Si es dentro del mes, mostrar hace cuántas semanas
      final weeks = (difference / 7).floor();
      return l10n.weeksAgo(weeks);
    } else {
      // Si es más antiguo, mostrar la fecha completa
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
