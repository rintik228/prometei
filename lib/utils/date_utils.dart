class DateUtils {
  static String formatTime(DateTime date) {
    final hours = date.hour.toString().padLeft(2, '0');
    final minutes = date.minute.toString().padLeft(2, '0');
    return '$hours:$minutes';
  }

  static String formatTimeForInput(DateTime date) {
    final hours = date.hour.toString().padLeft(2, '0');
    final minutes = date.minute.toString().padLeft(2, '0');
    return '$hours:$minutes';
  }

  static DateTime calculateNextProductionTime(DateTime currentTime, double cycleTime) {
    return currentTime.add(Duration(minutes: cycleTime.toInt()));
  }
}
