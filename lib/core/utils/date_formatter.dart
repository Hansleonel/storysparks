class DateFormatter {
  static String getFormattedDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateToCompare = DateTime(date.year, date.month, date.day);
    final difference = today.difference(dateToCompare).inDays;

    if (dateToCompare == today) {
      return 'Hoy';
    } else if (dateToCompare == yesterday) {
      return 'Ayer';
    } else if (difference < 7) {
      // Si es dentro de la semana actual, mostrar el día
      switch (date.weekday) {
        case 1:
          return 'Lunes';
        case 2:
          return 'Martes';
        case 3:
          return 'Miércoles';
        case 4:
          return 'Jueves';
        case 5:
          return 'Viernes';
        case 6:
          return 'Sábado';
        case 7:
          return 'Domingo';
        default:
          return '';
      }
    } else if (difference < 30) {
      // Si es dentro del mes, mostrar hace cuántas semanas
      final weeks = (difference / 7).floor();
      return 'Hace $weeks ${weeks == 1 ? 'semana' : 'semanas'}';
    } else {
      // Si es más antiguo, mostrar la fecha completa
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
