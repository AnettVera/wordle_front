// lib/utils/timezone_helper.dart
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class TimezoneHelper {
  static late tz.Location mexicoCity;
  static bool _initialized = false;
  
  static void initialize() {
    if (!_initialized) {
      tz.initializeTimeZones();
      mexicoCity = tz.getLocation('America/Mexico_City');
      _initialized = true;
    }
  }
  
  /// Convierte una fecha UTC a la zona horaria de México
  static DateTime convertToMexicoCity(DateTime utcDate) {
    initialize();
    final utcTZ = tz.TZDateTime.from(utcDate, tz.UTC);
    final mexicoTZ = tz.TZDateTime.from(utcTZ, mexicoCity);
    return DateTime(
      mexicoTZ.year,
      mexicoTZ.month,
      mexicoTZ.day,
      mexicoTZ.hour,
      mexicoTZ.minute,
      mexicoTZ.second,
      mexicoTZ.millisecond,
    );
  }
  
  /// Obtiene el día del mes en zona horaria de México
  static int getDayInMexicoTimezone(DateTime utcDate) {
    return convertToMexicoCity(utcDate).day;
  }
  
  /// Verifica si una fecha está en horario de verano en México
  static bool isDaylightSaving(DateTime date) {
    initialize();
    final mexicoTZ = tz.TZDateTime.from(date, mexicoCity);
    return mexicoTZ.timeZoneOffset != const Duration(hours: -6);
  }
}
