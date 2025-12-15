import 'package:flutter/material.dart';
import 'package:health_example/helpers/permission_helper.dart';

class PermissionStatusPanel extends StatelessWidget {
  final Future<Map<String, PermissionState>> permissionFuture;
  final VoidCallback onRefresh;

  const PermissionStatusPanel({
    super.key,
    required this.permissionFuture,
    required this.onRefresh,
  });

  Color _colorFor(PermissionState state) => switch (state) {
        PermissionState.granted => Colors.green.shade400,
        PermissionState.denied => Colors.red.shade400,
        PermissionState.unknown => Colors.grey.shade400,
      };

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, PermissionState>>(
      future: permissionFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: LinearProgressIndicator(),
          );
        }

        final data = snapshot.data;
        if (data == null) {
          return Row(
            children: [
              const Text('Permissions unavailable'),
              const SizedBox(width: 8),
              IconButton(
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh),
              ),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Permission snapshot',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: onRefresh,
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Refresh permissions',
                ),
              ],
            ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: data.entries
                  .map(
                    (entry) => Chip(
                      backgroundColor: _colorFor(entry.value),
                      label: Text(
                        '${entry.key}: ${PermissionHelper.stateLabel(entry.value)}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        );
      },
    );
  }
}
