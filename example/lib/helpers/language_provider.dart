import 'package:flutter/material.dart';

enum Language { english, spanish }

class LanguageProvider extends ChangeNotifier {
  Language _currentLanguage = Language.english;

  Language get currentLanguage => _currentLanguage;

  void setLanguage(Language language) {
    _currentLanguage = language;
    notifyListeners();
  }

  String getString(String key) {
    switch (_currentLanguage) {
      case Language.english:
        return _englishStrings[key] ?? key;
      case Language.spanish:
        return _spanishStrings[key] ?? key;
    }
  }

  String getTypeName(String typeKey) {
    switch (_currentLanguage) {
      case Language.english:
        return _typeNamesEnglish[typeKey] ?? typeKey.replaceAll('_', ' ').toLowerCase();
      case Language.spanish:
        return _typeNamesSpanish[typeKey] ?? typeKey.replaceAll('_', ' ').toLowerCase();
    }
  }

  String getActionDescription(String typeKey) {
    switch (_currentLanguage) {
      case Language.english:
        return _actionDescriptionsEnglish[typeKey] ?? 'Write sample value';
      case Language.spanish:
        return _actionDescriptionsSpanish[typeKey] ?? 'Escribir valor de muestra';
    }
  }

  static const Map<String, String> _englishStrings = {
    'app_title': 'GHC/AH tester',
    'write_section': 'Write',
    'write_description': 'Write realistic samples per data type using',
    'read_section': 'Read',
    'read_description': 'Fetch the latest 24h of data by type using',
    'platform_android': 'Running on Android with Health Connect.',
    'platform_ios': 'Running on iOS with Apple Health.',
    'platform_unknown': 'Unsupported platform.',
    'platform_note': 'Use the two sections above to validate write/read flows per data type.',
    'platform_awareness': 'Platform awareness',
    'permissions_section': 'Permissions',
    'permissions_description': 'Request all read/write permissions.',
    'request_permissions': 'Request All',
    'language_english': 'English',
    'language_spanish': 'Español',
    'write_title': 'Write samples',
    'read_title': 'Read samples',
    'select_type': 'Select a type to fetch the last 24 hours.',
    'reading_for': 'Reading last 24h for',
    'no_data': 'No data in the last 24 hours.',
    'write_button': 'Write',
    'read_button': 'Read',
    'permission_granted': 'Granted',
    'permission_denied': 'Denied',
    'permission_unknown': 'Unknown',
    'permission_summary': 'Permission snapshot',
    'refresh': 'Refresh',
    'permissions_requested_success': 'Permissions requested successfully',
    'permissions_requested_partial': 'Some permissions failed to grant',
    'permissions_request_error': 'Error requesting permissions',
    'loading_permissions': 'Loading permissions...',
    'all_permissions_granted': 'All permissions granted',
    'all_permissions_denied': 'All permissions denied',
    'permissions_status': 'Permissions',
    'read_permissions_granted': 'Read permissions granted',
    'write_permissions_granted': 'Write permissions granted',
    'write_permission_denied': 'Write permission denied for',
    'read_permission_denied': 'Read permission denied for',
    'write_sample_error': 'Error writing',
    'read_sample_error': 'Error reading',
    'heart_rate_detail': 'Heart rate',
    'resting_heart_rate_detail': 'Resting heart rate',
    'heart_rate_variability_detail': 'Heart rate variability',
    'blood_oxygen_detail': 'SpO₂',
    'blood_glucose_detail': 'Blood glucose',
    'blood_pressure_detail': 'Blood pressure',
    'workout_detail': 'Workout',
    'nutrition_detail': 'Nutrition',
    'menstruation_flow_detail': 'Menstruation flow',
  };

  static const Map<String, String> _spanishStrings = {
    'app_title': 'GHC/AH tester',
    'write_section': 'Escribir',
    'write_description': 'Escribe muestras realistas por tipo de dato usando',
    'read_section': 'Leer',
    'read_description': 'Obtén las últimas 24h de datos por tipo usando',
    'platform_android': 'Ejecutándose en Android con Health Connect.',
    'platform_ios': 'Ejecutándose en iOS con Apple Health.',
    'platform_unknown': 'Plataforma no soportada.',
    'platform_note': 'Usa las dos secciones de arriba para validar flujos de escritura/lectura por tipo de dato.',
    'platform_awareness': 'Reconocimiento de plataforma',
    'permissions_section': 'Permisos',
    'permissions_description': 'Solicita todos los permisos de lectura/escritura.',
    'request_permissions': 'Solicitar Todos',
    'language_english': 'English',
    'language_spanish': 'Español',
    'write_title': 'Escribir muestras',
    'read_title': 'Leer muestras',
    'select_type': 'Selecciona un tipo para obtener las últimas 24 horas.',
    'reading_for': 'Leyendo últimas 24h para',
    'no_data': 'No hay datos en las últimas 24 horas.',
    'write_button': 'Escribir',
    'read_button': 'Leer',
    'permission_granted': 'Concedido',
    'permission_denied': 'Denegado',
    'permission_unknown': 'Desconocido',
    'permission_summary': 'Resumen de permisos',
    'refresh': 'Actualizar',
    'permissions_requested_success': 'Permisos solicitados exitosamente',
    'permissions_requested_partial': 'Algunos permisos fallaron al concederse',
    'permissions_request_error': 'Error solicitando permisos',
    'loading_permissions': 'Cargando permisos...',
    'all_permissions_granted': 'Todos los permisos concedidos',
    'all_permissions_denied': 'Todos los permisos denegados',
    'permissions_status': 'Permisos',
    'read_permissions_granted': 'Permisos de lectura concedidos',
    'write_permissions_granted': 'Permisos de escritura concedidos',
    'write_permission_denied': 'Permiso de escritura denegado para',
    'read_permission_denied': 'Permiso de lectura denegado para',
    'write_sample_error': 'Error escribiendo',
    'read_sample_error': 'Error leyendo',
    'heart_rate_detail': 'Ritmo cardíaco',
    'resting_heart_rate_detail': 'Ritmo cardíaco en reposo',
    'heart_rate_variability_detail': 'Variabilidad del ritmo cardíaco',
    'blood_oxygen_detail': 'SpO₂',
    'blood_glucose_detail': 'Glucosa en sangre',
    'blood_pressure_detail': 'Presión arterial',
    'workout_detail': 'Entrenamiento',
    'nutrition_detail': 'Nutrición',
    'menstruation_flow_detail': 'Flujo menstrual',
  };

  static const Map<String, String> _typeNamesEnglish = {
    'steps': 'Steps',
    'sleep_in_bed': 'Sleep in bed',
    'sleep_awake': 'Sleep awake',
    'sleep_awake_in_bed': 'Sleep awake in bed',
    'sleep_asleep': 'Sleep asleep',
    'sleep_deep': 'Sleep deep',
    'sleep_rem': 'Sleep REM',
    'sleep_light': 'Sleep light',
    'sleep_out_of_bed': 'Sleep out of bed',
    'sleep_unknown': 'Sleep unknown',
    'sleep_session': 'Sleep session',
    'workout': 'Workout',
    'heart_rate': 'Heart rate',
    'resting_heart_rate': 'Resting heart rate',
    'heart_rate_variability_sdnn': 'Heart rate variability SDNN',
    'heart_rate_variability_rmssd': 'Heart rate variability RMSSD',
    'blood_glucose': 'Blood glucose',
    'blood_oxygen': 'Blood oxygen',
    'blood_pressure_systolic': 'Blood pressure systolic',
    'blood_pressure_diastolic': 'Blood pressure diastolic',
    'weight': 'Weight',
    'height': 'Height',
    'body_temperature': 'Body temperature',
    'active_energy_burned': 'Active energy burned',
    'basal_energy_burned': 'Basal energy burned',
    'total_calories_burned': 'Total calories burned',
    'water': 'Water',
    'respiratory_rate': 'Respiratory rate',
    'distance_delta': 'Distance delta',
    'distance_walking_running': 'Distance walking/running',
    'body_fat_percentage': 'Body fat percentage',
    'flights_climbed': 'Flights climbed',
    'nutrition': 'Nutrition',
    'menstruation_flow': 'Menstruation flow',
  };

  static const Map<String, String> _typeNamesSpanish = {
    'steps': 'Pasos',
    'sleep_in_bed': 'Sueño en cama',
    'sleep_awake': 'Sueño despierto',
    'sleep_awake_in_bed': 'Sueño despierto en cama',
    'sleep_asleep': 'Sueño dormido',
    'sleep_deep': 'Sueño profundo',
    'sleep_rem': 'Sueño REM',
    'sleep_light': 'Sueño ligero',
    'sleep_out_of_bed': 'Sueño fuera de cama',
    'sleep_unknown': 'Sueño desconocido',
    'sleep_session': 'Sesión de sueño',
    'workout': 'Entrenamiento',
    'heart_rate': 'Ritmo cardíaco',
    'resting_heart_rate': 'Ritmo cardíaco en reposo',
    'heart_rate_variability_sdnn': 'Variabilidad ritmo cardíaco SDNN',
    'heart_rate_variability_rmssd': 'Variabilidad ritmo cardíaco RMSSD',
    'blood_glucose': 'Glucosa en sangre',
    'blood_oxygen': 'Oxígeno en sangre',
    'blood_pressure_systolic': 'Presión arterial sistólica',
    'blood_pressure_diastolic': 'Presión arterial diastólica',
    'weight': 'Peso',
    'height': 'Altura',
    'body_temperature': 'Temperatura corporal',
    'active_energy_burned': 'Energía activa quemada',
    'basal_energy_burned': 'Energía basal quemada',
    'total_calories_burned': 'Calorías totales quemadas',
    'water': 'Agua',
    'respiratory_rate': 'Ritmo respiratorio',
    'distance_delta': 'Distancia delta',
    'distance_walking_running': 'Distancia caminando/corriendo',
    'body_fat_percentage': 'Porcentaje de grasa corporal',
    'flights_climbed': 'Pisos subidos',
    'nutrition': 'Nutrición',
    'menstruation_flow': 'Flujo menstrual',
  };

  static const Map<String, String> _actionDescriptionsEnglish = {
    'heart_rate': 'Write random 100-150 bpm',
    'resting_heart_rate': 'Write random 55-75 bpm',
    'blood_pressure_systolic': 'Write random 110/70 mmHg',
    'blood_pressure_diastolic': 'Write random 110/70 mmHg',
    'blood_oxygen': 'Write random 95-100% SpO2',
    'blood_glucose': 'Write random 85-130 mg/dL',
    'workout': 'Write running workout sample',
    'nutrition': 'Write snack nutrition sample',
  };

  static const Map<String, String> _actionDescriptionsSpanish = {
    'heart_rate': 'Escribir aleatorio 100-150 bpm',
    'resting_heart_rate': 'Escribir aleatorio 55-75 bpm',
    'blood_pressure_systolic': 'Escribir aleatorio 110/70 mmHg',
    'blood_pressure_diastolic': 'Escribir aleatorio 110/70 mmHg',
    'blood_oxygen': 'Escribir aleatorio 95-100% SpO2',
    'blood_glucose': 'Escribir aleatorio 85-130 mg/dL',
    'workout': 'Escribir muestra de entrenamiento corriendo',
    'nutrition': 'Escribir muestra de nutrición de snack',
  };
}