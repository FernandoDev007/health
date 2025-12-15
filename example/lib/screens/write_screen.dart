import 'dart:math';

import 'package:flutter/material.dart';
import 'package:health/health.dart';
import 'package:health_example/helpers/language_provider.dart';
import 'package:health_example/helpers/permission_helper.dart';
import 'package:provider/provider.dart';

class WriteScreen extends StatefulWidget {
  static const String route = '/write';

  const WriteScreen({super.key});

  @override
  State<WriteScreen> createState() => _WriteScreenState();
}

class _WriteScreenState extends State<WriteScreen> {
  final Health _health = Health();
  final Random _random = Random();

  bool _isWriting = false;

  static const Set<HealthDataType> _unsupportedTypes = {
    HealthDataType.GENDER,
    HealthDataType.BLOOD_TYPE,
    HealthDataType.BIRTH_DATE,
    HealthDataType.AUDIOGRAM,
    HealthDataType.ELECTROCARDIOGRAM,
    HealthDataType.HIGH_HEART_RATE_EVENT,
    HealthDataType.LOW_HEART_RATE_EVENT,
    HealthDataType.IRREGULAR_HEART_RATE_EVENT,
    HealthDataType.WALKING_HEART_RATE,
    HealthDataType.ATRIAL_FIBRILLATION_BURDEN,
  };

  Future<void> _writeForType(HealthDataType type) async {
    if (_unsupportedTypes.contains(type)) {
      _showSnack('${_pretty(type, Provider.of<LanguageProvider>(context, listen: false))} is read-only in this quick demo.');
      return;
    }

    setState(() {
      _isWriting = true;
    });

    final authorized = await _ensureWritePermission(type);
    if (!authorized) {
      setState(() {
        _isWriting = false;
      });
      _showSnack('${Provider.of<LanguageProvider>(context, listen: false).getString('write_permission_denied')} ${_pretty(type, Provider.of<LanguageProvider>(context, listen: false))}');
      return;
    }

    final now = DateTime.now();
    final start = now.subtract(const Duration(minutes: 10));

    bool success = false;
    try {
      final result = await _writeSample(type, start, now);
      success = result.success;
      if (success && mounted) {
        _showSnack(result.detail);
      }
    } catch (error) {
      success = false;
      _showSnack('${Provider.of<LanguageProvider>(context, listen: false).getString('write_sample_error')} ${_pretty(type, Provider.of<LanguageProvider>(context, listen: false))}: $error');
    }

    setState(() {
      _isWriting = false;
    });
  }

  Future<bool> _ensureWritePermission(HealthDataType type) async {
    final result = await _health.hasPermissions(
      [type],
      permissions: [HealthDataAccess.READ_WRITE],
    );
    if (result == true) return true;
    return _health.requestAuthorization(
      [type],
      permissions: [HealthDataAccess.READ_WRITE],
    );
  }

  Future<WriteResult> _writeSample(
    HealthDataType type,
    DateTime start,
    DateTime end,
  ) async {
    switch (type) {
      case HealthDataType.HEART_RATE:
        final bpm = _randomInt(100, 150).toDouble();
        final success = await _health.writeHealthData(
          value: bpm,
          type: type,
          startTime: start,
          endTime: end,
          recordingMethod: RecordingMethod.manual,
        );
        return WriteResult(
            success: success,
            detail: '${Provider.of<LanguageProvider>(context, listen: false).getString('heart_rate_detail')}: ${bpm.toStringAsFixed(0)} bpm');
      case HealthDataType.RESTING_HEART_RATE:
        final bpm = _randomInt(55, 75).toDouble();
        final success = await _health.writeHealthData(
          value: bpm,
          type: type,
          startTime: start,
          endTime: end,
          recordingMethod: RecordingMethod.manual,
        );
        return WriteResult(
            success: success,
            detail: '${Provider.of<LanguageProvider>(context, listen: false).getString('resting_heart_rate_detail')}: ${bpm.toStringAsFixed(0)} bpm');
      case HealthDataType.HEART_RATE_VARIABILITY_SDNN:
      case HealthDataType.HEART_RATE_VARIABILITY_RMSSD:
        final hrv = _randomInRange(20, 80);
        final success = await _health.writeHealthData(
          value: hrv,
          type: type,
          startTime: start,
          endTime: end,
          recordingMethod: RecordingMethod.manual,
        );
        return WriteResult(
            success: success,
            detail: '${Provider.of<LanguageProvider>(context, listen: false).getString('heart_rate_variability_detail')}: ${hrv.toStringAsFixed(1)} ms');
      case HealthDataType.BLOOD_OXYGEN:
        final spo2 = _randomInt(95, 100).toDouble();
        final success = await _health.writeBloodOxygen(
          saturation: spo2,
          startTime: start,
          endTime: end,
        );
        return WriteResult(
            success: success, detail: '${Provider.of<LanguageProvider>(context, listen: false).getString('blood_oxygen_detail')}: ${spo2.toStringAsFixed(1)} %');
      case HealthDataType.BLOOD_GLUCOSE:
        final glucose = _randomInRange(85, 130);
        final success = await _health.writeHealthData(
          value: glucose,
          type: type,
          startTime: start,
          endTime: end,
          recordingMethod: RecordingMethod.manual,
        );
        return WriteResult(
            success: success,
            detail: '${Provider.of<LanguageProvider>(context, listen: false).getString('blood_glucose_detail')}: ${glucose.toStringAsFixed(0)} mg/dL');
      case HealthDataType.BLOOD_PRESSURE_DIASTOLIC:
      case HealthDataType.BLOOD_PRESSURE_SYSTOLIC:
        final systolic = _randomInt(110, 130);
        final diastolic = _randomInt(70, 85);
        final success = await _health.writeBloodPressure(
          systolic: systolic,
          diastolic: diastolic,
          startTime: end,
        );
        return WriteResult(
            success: success,
            detail: '${Provider.of<LanguageProvider>(context, listen: false).getString('blood_pressure_detail')}: $systolic / $diastolic mmHg');
      case HealthDataType.WORKOUT:
        final distance = _randomInt(1500, 3500);
        final energy = _randomInt(150, 350);
        final success = await _health.writeWorkoutData(
          activityType: HealthWorkoutActivityType.RUNNING,
          title: 'Demo workout',
          start: start,
          end: end,
          totalDistance: distance,
          totalEnergyBurned: energy,
        );
        return WriteResult(
            success: success,
            detail: '${Provider.of<LanguageProvider>(context, listen: false).getString('workout_detail')}: Run ${(distance / 1000).toStringAsFixed(2)} km, $energy kcal');
      case HealthDataType.NUTRITION:
        final calories = _randomInt(80, 180).toDouble();
        final carbs = _randomInRange(10, 35);
        final protein = _randomInRange(5, 20);
        final fat = _randomInRange(2, 10);
        final success = await _health.writeMeal(
          mealType: MealType.SNACK,
          startTime: start,
          endTime: end,
          caloriesConsumed: calories,
          carbohydrates: carbs,
          protein: protein,
          fatTotal: fat,
          name: 'Demo meal',
          recordingMethod: RecordingMethod.manual,
        );
        return WriteResult(
            success: success,
            detail: '${Provider.of<LanguageProvider>(context, listen: false).getString('nutrition_detail')}: ${calories.toStringAsFixed(0)} kcal');
      case HealthDataType.MENSTRUATION_FLOW:
        final flow = MenstrualFlow.values[_randomInt(0, MenstrualFlow.values.length - 1)];
        final success = await _health.writeMenstruationFlow(
          flow: flow,
          isStartOfCycle: true,
          startTime: start,
          endTime: end,
        );
        return WriteResult(
            success: success,
            detail: '${Provider.of<LanguageProvider>(context, listen: false).getString('menstruation_flow_detail')}: ${flow.name}');
      default:
        final value = _defaultValueFor(type);
        final success = await _health.writeHealthData(
          value: value,
          type: type,
          startTime: start,
          endTime: end,
          recordingMethod: RecordingMethod.manual,
        );
        return WriteResult(
            success: success,
            detail: '${_pretty(type, Provider.of<LanguageProvider>(context, listen: false))}: ${value.toStringAsFixed(1)}');
    }
  }

  double _defaultValueFor(HealthDataType type) {
    switch (type) {
      case HealthDataType.STEPS:
        return _randomInt(200, 1200).toDouble();
      case HealthDataType.WEIGHT:
        return _randomInRange(60, 95);
      case HealthDataType.HEIGHT:
        return _randomInRange(1.6, 1.9);
      case HealthDataType.BODY_TEMPERATURE:
        return _randomInRange(36.2, 37.8);
      case HealthDataType.ACTIVE_ENERGY_BURNED:
      case HealthDataType.BASAL_ENERGY_BURNED:
      case HealthDataType.TOTAL_CALORIES_BURNED:
        return _randomInRange(120, 480);
      case HealthDataType.WATER:
        return _randomInRange(0.2, 0.6);
      case HealthDataType.RESPIRATORY_RATE:
        return _randomInRange(12, 20);
      case HealthDataType.DISTANCE_DELTA:
      case HealthDataType.DISTANCE_WALKING_RUNNING:
        return _randomInRange(500, 2500);
      case HealthDataType.BODY_FAT_PERCENTAGE:
        return _randomInRange(12, 28);
      case HealthDataType.FLIGHTS_CLIMBED:
        return _randomInt(2, 20).toDouble();
      case HealthDataType.SLEEP_DEEP:
      case HealthDataType.SLEEP_REM:
      case HealthDataType.SLEEP_LIGHT:
      case HealthDataType.SLEEP_ASLEEP:
      case HealthDataType.SLEEP_AWAKE:
      case HealthDataType.SLEEP_AWAKE_IN_BED:
      case HealthDataType.SLEEP_UNKNOWN:
      case HealthDataType.SLEEP_OUT_OF_BED:
      case HealthDataType.SLEEP_SESSION:
      case HealthDataType.SLEEP_IN_BED:
        return 0.0;
      default:
        return _randomInRange(1, 100);
    }
  }

  int _randomInt(int min, int max) => min + _random.nextInt(max - min + 1);

  double _randomInRange(double min, double max) =>
      min + _random.nextDouble() * (max - min);

  String _pretty(HealthDataType type, LanguageProvider languageProvider) {
    final key = type.name.toLowerCase();
    return languageProvider.getTypeName(key);
  }

  String _actionLabel(HealthDataType type, LanguageProvider languageProvider) {
    final key = type.name.toLowerCase();
    return languageProvider.getActionDescription(key);
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(languageProvider.getString('write_title')),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: PermissionHelper.orderedTypes.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final type = PermissionHelper.orderedTypes[index];
          final color = Colors.primaries[index % Colors.primaries.length]
              .shade400;
          return Card(
            child: ListTile(
              title: Text(_pretty(type, languageProvider)),
              subtitle: Text(_actionLabel(type, languageProvider)),
              trailing: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: color,
                ),
                onPressed: _isWriting ? null : () => _writeForType(type),
                child: Text(languageProvider.getString('write_button')),
              ),
            ),
          );
        },
      ),
    );
  }
}

class WriteResult {
  final bool success;
  final String detail;

  WriteResult({required this.success, required this.detail});
}