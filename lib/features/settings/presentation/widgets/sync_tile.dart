import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../outbox/presentation/cubit/outbox_cubit.dart';

class SyncTile extends StatelessWidget {
  const SyncTile({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OutboxCubit, OutboxState>(
      builder: (context, state) => ListTile(
        leading: const Icon(Icons.sync_rounded),
        title: const Text('Sync now'),
        subtitle: Text(_subtitle(state)),
        trailing: state.isSyncing
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : null,
        enabled: state.hasPending && !state.isSyncing,
        onTap: context.read<OutboxCubit>().sync,
      ),
    );
  }

  String _subtitle(OutboxState state) {
    if (state.isSyncing) return 'Syncing…';
    if (!state.hasPending) return 'Everything is up to date';
    final count = state.pendingCount;
    return '$count pending ${count == 1 ? 'change' : 'changes'}';
  }
}
