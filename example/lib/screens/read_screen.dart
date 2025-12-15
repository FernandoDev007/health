import 'package:flutter/material.dart';
import 'package:health/health.dart';
import 'package:health_example/helpers/language_provider.dart';
import 'package:health_example/helpers/permission_helper.dart';
import 'package:provider/provider.dart';

class ReadScreen extends StatefulWidget {
  static const String route = '/read';

  const ReadScreen({super.key});

  @override
  State<ReadScreen> createState() => _ReadScreenState();
}

class _ReadScreenState extends State<ReadScreen> {
  final Health _health = Health();

  Future<List<HealthDataPoint>>? _dataFuture;
  HealthDataType? _selectedType;

  Future<void> _loadType(HealthDataType type) async {
    setState(() {
      _selectedType = type;
      _dataFuture = _fetchData(type);
    });
  }

  Future<List<HealthDataPoint>> _fetchData(HealthDataType type) async {
    final authorized = await _ensureReadPermission(type);
    if (!authorized) {
      throw Exception('Permission denied for ${type.name}');
    }

    final now = DateTime.now();
    final start = now.subtract(const Duration(hours: 24));
    final points = await _health.getHealthDataFromTypes(
      types: [type],
      startTime: start,
      endTime: now,
    );

    points.sort((a, b) => b.dateTo.compareTo(a.dateTo));
    return _health.removeDuplicates(points);
  }

  Future<bool> _ensureReadPermission(HealthDataType type) async {
    final result = await _health.hasPermissions([type]);
    if (result == true) return true;
    return _health.requestAuthorization([type]);
  }

  String _pretty(HealthDataType type, LanguageProvider languageProvider) =>
      languageProvider.getTypeName(type.name.toLowerCase());

  Widget _buildData() {
    if (_dataFuture == null) {
      return const Center(
        child: Text('Pick a data type to read the last 24 hours.'),
      );
    }

    return FutureBuilder<List<HealthDataPoint>>(
      future: _dataFuture,
      builder: (context, snapshot) {
        final languageProvider = Provider.of<LanguageProvider>(context);

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final data = snapshot.data;
        if (data == null || data.isEmpty) {
          return Center(child: Text(languageProvider.getString('no_data')));
        }

        return ListView.separated(
          itemCount: data.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final point = data[index];
            final value = point.value;

            // Format SpO₂ as percentage if it's blood oxygen
            final formattedValue = (point.type == HealthDataType.BLOOD_OXYGEN &&
                    value is NumericHealthValue)
                ? '${(value.numericValue.clamp(0, 100)).toStringAsFixed(1)} %'
                : '$value';

            return Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _pretty(point.type, languageProvider),
                      style: const TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      formattedValue,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(languageProvider.getString('read_title')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _selectedType == null
                  ? languageProvider.getString('select_type')
                  : '${languageProvider.getString('reading_for')} ${_pretty(_selectedType!, languageProvider)}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                itemCount: PermissionHelper.orderedTypes.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final type = PermissionHelper.orderedTypes[index];
                  final color = Colors.primaries[index % Colors.primaries.length]
                      .shade400;
                  return Card(
                    child: ListTile(
                      title: Text(_pretty(type, languageProvider)),
                      trailing: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: color,
                        ),
                        onPressed: () => _loadType(type),
                        child: Text(languageProvider.getString('read_button')),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Expanded(child: _buildData()),
          ],
        ),
      ),
    );
  }
}