import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/network/mock_api_client.dart';
import '../cubit/outbox_cubit.dart';

class NetworkDebugMenu extends StatelessWidget {
  const NetworkDebugMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final api = ServiceLocator.instance.get<MockApiClient>();
    return PopupMenuButton<bool>(
      tooltip: 'Network simulation',
      icon: const Icon(Icons.bug_report_outlined),
      onSelected: (offline) {
        offline ? api.simulateOffline = !api.simulateOffline : api.simulateConflict = !api.simulateConflict;
        if (!api.simulateOffline) context.read<OutboxCubit>().sync();
      },
      itemBuilder: (_) => [
        CheckedPopupMenuItem(value: true, checked: api.simulateOffline, child: const Text('Simulate offline')),
        CheckedPopupMenuItem(value: false, checked: api.simulateConflict, child: const Text('Simulate conflict')),
      ],
    );
  }
}
