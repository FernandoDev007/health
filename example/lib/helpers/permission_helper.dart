import 'dart:io';

import 'package:health/health.dart';
import 'package:health_example/util.dart';

enum PermissionState { granted, denied, unknown }

class PermissionHelper {
  static List<HealthDataType> get sleepTypes => switch (Health().platformType) {
        HealthPlatformType.appleHealth => <HealthDataType>[
            HealthDataType.SLEEP_IN_BED,
            HealthDataType.SLEEP_AWAKE,
            HealthDataType.SLEEP_ASLEEP,
            HealthDataType.SLEEP_DEEP,
            HealthDataType.SLEEP_REM,
          ],
        HealthPlatformType.googleHealthConnect => <HealthDataType>[
            HealthDataType.SLEEP_AWAKE,
            HealthDataType.SLEEP_AWAKE_IN_BED,
            HealthDataType.SLEEP_ASLEEP,
            HealthDataType.SLEEP_DEEP,
            HealthDataType.SLEEP_LIGHT,
            HealthDataType.SLEEP_REM,
            HealthDataType.SLEEP_OUT_OF_BED,
            HealthDataType.SLEEP_UNKNOWN,
            HealthDataType.SLEEP_SESSION,
          ],
      };

  static List<HealthDataType> get heartRateVariabilityTypes =>
      Platform.isIOS
          ? <HealthDataType>[HealthDataType.HEART_RATE_VARIABILITY_SDNN]
          : <HealthDataType>[HealthDataType.HEART_RATE_VARIABILITY_RMSSD];

  static List<HealthDataType> get bloodPressureTypes => <HealthDataType>[
        HealthDataType.BLOOD_PRESSURE_SYSTOLIC,
        HealthDataType.BLOOD_PRESSURE_DIASTOLIC,
      ];

  static List<HealthDataType> get orderedTypes => switch (Health().platformType) {
        HealthPlatformType.appleHealth => [
            // Primero los especificados
            ...sleepTypes,
            HealthDataType.WORKOUT,
            HealthDataType.HEART_RATE,
            HealthDataType.RESTING_HEART_RATE,
            ...heartRateVariabilityTypes,
            HealthDataType.BLOOD_GLUCOSE,
            HealthDataType.BLOOD_OXYGEN,
            ...bloodPressureTypes,
            // Luego el resto de iOS
            ...dataTypesIOS.where((type) => ![
              ...sleepTypes,
              HealthDataType.WORKOUT,
              HealthDataType.HEART_RATE,
              HealthDataType.RESTING_HEART_RATE,
              ...heartRateVariabilityTypes,
              HealthDataType.BLOOD_GLUCOSE,
              HealthDataType.BLOOD_OXYGEN,
              ...bloodPressureTypes,
            ].contains(type)),
          ],
        HealthPlatformType.googleHealthConnect => [
            // Primero los especificados
            HealthDataType.STEPS,
            ...sleepTypes,
            HealthDataType.WORKOUT,
            HealthDataType.HEART_RATE,
            HealthDataType.RESTING_HEART_RATE,
            ...heartRateVariabilityTypes,
            HealthDataType.BLOOD_GLUCOSE,
            HealthDataType.BLOOD_OXYGEN,
            ...bloodPressureTypes,
            // Luego el resto de Android
            ...dataTypesAndroid.where((type) => ![
              HealthDataType.STEPS,
              ...sleepTypes,
              HealthDataType.WORKOUT,
              HealthDataType.HEART_RATE,
              HealthDataType.RESTING_HEART_RATE,
              ...heartRateVariabilityTypes,
              HealthDataType.BLOOD_GLUCOSE,
              HealthDataType.BLOOD_OXYGEN,
              ...bloodPressureTypes,
            ].contains(type)),
          ],
      };

  static Future<PermissionState> check(List<HealthDataType> types,
      {List<HealthDataAccess>? permissions}) async {
    try {
      final result = await Health().hasPermissions(
        types,
        permissions: permissions,
      );
      if (result == null) return PermissionState.unknown;
      return result ? PermissionState.granted : PermissionState.denied;
    } catch (_) {
      return PermissionState.denied;
    }
  }

  static Future<Map<String, PermissionState>> permissionSummary() async {
    return {
      'Steps': await check([HealthDataType.STEPS]),
      'Sleep': await check(sleepTypes),
      'Workout': await check([HealthDataType.WORKOUT]),
      'Heart rate': await check([HealthDataType.HEART_RATE]),
      'Resting heart rate':
          await check([HealthDataType.RESTING_HEART_RATE]),
      'Heart rate variability': await check(heartRateVariabilityTypes),
      'Blood glucose': await check([HealthDataType.BLOOD_GLUCOSE]),
      'Blood oxygen': await check([HealthDataType.BLOOD_OXYGEN]),
      'Blood pressure': await check(bloodPressureTypes),
    };
  }

  /// Returns a map with read and write permission counts for all available types
  static Future<Map<String, int>> getAllPermissionCounts() async {
    final allTypes = Platform.isAndroid ? dataTypesAndroid : dataTypesIOS;
    
    // Types that are read-only on iOS
    final readOnlyTypes = Platform.isIOS
        ? {
            HealthDataType.WALKING_HEART_RATE,
            HealthDataType.ELECTROCARDIOGRAM,
            HealthDataType.HIGH_HEART_RATE_EVENT,
            HealthDataType.LOW_HEART_RATE_EVENT,
            HealthDataType.IRREGULAR_HEART_RATE_EVENT,
            HealthDataType.EXERCISE_TIME,
          }
        : <HealthDataType>{};

    int readGranted = 0;
    int writeGranted = 0;
    int readTotal = allTypes.length;
    int writeTotal = allTypes.length - readOnlyTypes.length;

    for (final type in allTypes) {
      // Check read permission
      final readState = await check([type], permissions: [HealthDataAccess.READ]);
      if (readState == PermissionState.granted) {
        readGranted++;
      }

      // Check write permission (skip read-only types)
      if (!readOnlyTypes.contains(type)) {
        final writeState = await check([type], permissions: [HealthDataAccess.READ_WRITE]);
        if (writeState == PermissionState.granted) {
          writeGranted++;
        }
      }
    }

    return {
      'readGranted': readGranted,
      'readTotal': readTotal,
      'writeGranted': writeGranted,
      'writeTotal': writeTotal,
    };
  }

  static Future<PermissionRequestResult> requestAll() async {
    final allTypes = Platform.isAndroid ? dataTypesAndroid : dataTypesIOS;
    try {
      final authorized = await Health().requestAuthorization(
        allTypes,
        permissions: allTypes
            .map((type) =>
                // can only request READ permissions to the following list of types on iOS
                [
                  HealthDataType.WALKING_HEART_RATE,
                  HealthDataType.ELECTROCARDIOGRAM,
                  HealthDataType.HIGH_HEART_RATE_EVENT,
                  HealthDataType.LOW_HEART_RATE_EVENT,
                  HealthDataType.IRREGULAR_HEART_RATE_EVENT,
                  HealthDataType.EXERCISE_TIME,
                ].contains(type)
                    ? HealthDataAccess.READ
                    : HealthDataAccess.READ_WRITE)
            .toList(),
      );
      return PermissionRequestResult(
        success: authorized,
        summary: await permissionSummary(),
      );
    } catch (e) {
      return PermissionRequestResult(
        success: false,
        summary: {},
        error: e.toString(),
      );
    }
  }

  static String stateLabel(PermissionState state) => switch (state) {
        PermissionState.granted => 'Granted',
        PermissionState.denied => 'Denied',
        PermissionState.unknown => 'Unknown',
      };
}

class PermissionRequestResult {
  final bool success;
  final Map<String, PermissionState> summary;
  final String? error;

  PermissionRequestResult({
    required this.success,
    required this.summary,
    this.error,
  });
}