import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/snack_bar.dart';
import '../../../devtools/presentation/cubit/dev_tools_cubit.dart';
import '../../../outbox/presentation/cubit/outbox_cubit.dart';

/// Debug-only demo controls (B3), visible only in `kDebugMode`. Never
/// reaches into `MockApiClient` directly — everything goes through
/// [DevToolsCubit].
class DeveloperSection extends StatelessWidget {
  const DeveloperSection({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<DevToolsCubit>();
    final state = cubit.state;

    return Column(
      children: [
        SwitchListTile(
          secondary: const Icon(Icons.wifi_off_rounded),
          title: const Text('Simulate offline'),
          subtitle: const Text('Feed and search behave as if disconnected'),
          value: state.simulateOffline,
          onChanged: (value) {
            context.read<DevToolsCubit>().setSimulateOffline(value);
            if (!value) context.read<OutboxCubit>().sync();
          },
        ),
        SwitchListTile(
          secondary: const Icon(Icons.error_outline_rounded),
          title: const Text('Simulate server error'),
          subtitle: const Text('Network calls fail with a server error'),
          value: state.simulateServerError,
          onChanged: (value) => context.read<DevToolsCubit>().setSimulateServerError(value),
        ),
        SwitchListTile(
          secondary: const Icon(Icons.sync_problem_rounded),
          title: const Text('Simulate reaction conflict'),
          subtitle: const Text('Likes come back with a newer server state'),
          value: state.simulateConflict,
          onChanged: (value) => context.read<DevToolsCubit>().setSimulateConflict(value),
        ),
        ListTile(
          leading: const Icon(Icons.speed_rounded),
          title: const Text('Network latency'),
          trailing: DropdownButton<int>(
            value: state.latencyMs,
            items: const [
              DropdownMenuItem(value: 0, child: Text('0 ms')),
              DropdownMenuItem(value: 400, child: Text('400 ms')),
              DropdownMenuItem(value: 2000, child: Text('2000 ms')),
            ],
            onChanged: (value) {
              if (value != null) context.read<DevToolsCubit>().setLatencyMs(value);
            },
          ),
        ),
        ListTile(
          leading: const Icon(Icons.restore_rounded),
          title: const Text('Reset mock server'),
          subtitle: const Text('Clears server-side bookmarks and likes'),
          onTap: () async {
            await context.read<DevToolsCubit>().resetMockServer();
            if (context.mounted) showSnackBarMessage(context, 'Mock server reset');
          },
        ),
      ],
    );
  }
}
