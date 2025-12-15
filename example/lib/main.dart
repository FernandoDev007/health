import 'dart:io';

import 'package:flutter/material.dart';
import 'package:health/health.dart';
import 'package:health_example/helpers/language_provider.dart';
import 'package:health_example/helpers/permission_helper.dart';
import 'package:health_example/screens/read_screen.dart';
import 'package:health_example/screens/write_screen.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Health().configure();
  runApp(
    ChangeNotifierProvider(
      create: (_) => LanguageProvider(),
      child: const HealthApp(),
    ),
  );
}

class HealthApp extends StatelessWidget {
  const HealthApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: languageProvider.getString('app_title'),
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
            useMaterial3: true,
          ),
          home: const HomeScreen(),
          routes: {
            ReadScreen.route: (_) => const ReadScreen(),
            WriteScreen.route: (_) => const WriteScreen(),
          },
        );
      },
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isRequesting = false;
  Map<String, PermissionState>? _permissionSummary;
  Map<String, int>? _permissionCounts;

  @override
  void initState() {
    super.initState();
    _loadPermissionSummary();
    _loadPermissionCounts();
  }

  Future<void> _loadPermissionSummary() async {
    final summary = await PermissionHelper.permissionSummary();
    setState(() {
      _permissionSummary = summary;
    });
  }

  Future<void> _loadPermissionCounts() async {
    final counts = await PermissionHelper.getAllPermissionCounts();
    setState(() {
      _permissionCounts = counts;
    });
  }

  String _getPermissionStatusText() {
    if (_permissionCounts == null) {
      final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
      return languageProvider.getString('loading_permissions');
    }

    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    final readGranted = _permissionCounts!['readGranted'] ?? 0;
    final readTotal = _permissionCounts!['readTotal'] ?? 0;
    final writeGranted = _permissionCounts!['writeGranted'] ?? 0;
    final writeTotal = _permissionCounts!['writeTotal'] ?? 0;

    return '${languageProvider.getString('read_permissions_granted')}: $readGranted/$readTotal\n'
           '${languageProvider.getString('write_permissions_granted')}: $writeGranted/$writeTotal';
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(languageProvider.getString('app_title')),
        actions: [
          Row(
            children: [
              ChoiceChip(
                label: Text(languageProvider.getString('language_english')),
                selected: languageProvider.currentLanguage == Language.english,
                onSelected: (selected) {
                  if (selected) languageProvider.setLanguage(Language.english);
                },
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: Text(languageProvider.getString('language_spanish')),
                selected: languageProvider.currentLanguage == Language.spanish,
                onSelected: (selected) {
                  if (selected) languageProvider.setLanguage(Language.spanish);
                },
              ),
            ],
          ),
          const SizedBox(width: 16)
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: ListTile(
                leading: const Icon(Icons.upload),
                title: Text(languageProvider.getString('write_section')),
                subtitle: Text(languageProvider.getString('write_description') + (Platform.isAndroid ? ' Health Connect' : ' HealthKit')),
                trailing: FilledButton(
                  onPressed: () => Navigator.pushNamed(
                    context,
                    WriteScreen.route,
                  ),
                  child: Text(languageProvider.getString('write_section')),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: const Icon(Icons.download),
                title: Text(languageProvider.getString('read_section')),
                subtitle: Text(languageProvider.getString('read_description') + (Platform.isAndroid ? ' Health Connect' : ' HealthKit')),
                trailing: FilledButton(
                  onPressed: () => Navigator.pushNamed(
                    context,
                    ReadScreen.route,
                  ),
                  child: Text(languageProvider.getString('read_section')),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: const Icon(Icons.security),
                title: Text(languageProvider.getString('permissions_section') + (Platform.isAndroid ? ' (GHC)' : ' (HK)')),
                subtitle: Text(_getPermissionStatusText()),
                trailing: FilledButton(
                  onPressed: _isRequesting ? null : _requestAllPermissions,
                  child: _isRequesting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(languageProvider.getString('request_permissions')),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      languageProvider.getString('platform_awareness'),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      Platform.isAndroid
                          ? languageProvider.getString('platform_android')
                          : Platform.isIOS
                              ? languageProvider.getString('platform_ios')
                              : languageProvider.getString('platform_unknown'),
                    ),
                    const SizedBox(height: 8),
                    Text(languageProvider.getString('platform_note')),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text("By Fernando H.", textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400))
          ],
        ),
      ),
    );
  }

  Future<void> _requestAllPermissions() async {
    setState(() => _isRequesting = true);
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    try {
      final result = await PermissionHelper.requestAll();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result.success
                  ? languageProvider.getString('permissions_requested_success')
                  : languageProvider.getString('permissions_requested_partial'),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${languageProvider.getString('permissions_request_error')}: $e')),
        );
      }
    }
    setState(() => _isRequesting = false);
    await _loadPermissionSummary(); // Refresh permission status
    await _loadPermissionCounts(); // Refresh permission counts
  }
}