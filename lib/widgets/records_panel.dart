import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/clicker_state.dart';
import '../l10n/app_localizations.dart';

class RecordsPanel extends StatelessWidget {
  const RecordsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<ClickerState>(context);
    final l10n = AppLocalizations.of(context);

    return Column(
      children: [
        if (state.taskRecords.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () => state.clearAllRecords(),
                  child: Text(l10n.get('clearRecords')),
                ),
              ],
            ),
          ),
        Expanded(
          child: state.taskRecords.isEmpty
              ? Center(child: Text(l10n.get('noRecords')))
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                  itemCount: state.taskRecords.length,
                  itemBuilder: (context, index) {
                    final record =
                        state.taskRecords[state.taskRecords.length - 1 - index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${record.timestamp.hour}:${record.timestamp.minute.toString().padLeft(2, '0')}:${record.timestamp.second.toString().padLeft(2, '0')}',
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                                Chip(
                                  label: Text(
                                    record.completed
                                        ? l10n.get('completed')
                                        : l10n.get('failed'),
                                    style: TextStyle(
                                      color: Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.white
                                          : Colors.black87,
                                    ),
                                  ),
                                  backgroundColor: record.completed
                                      ? Colors.green.withOpacity(0.2)
                                      : Colors.red.withOpacity(0.2),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text('${l10n.get('clickMode')}: ${record.mode}'),
                            const SizedBox(height: 4),
                            Text('${l10n.get('targetClicks')}: ${record.targetClicks}'),
                            const SizedBox(height: 4),
                            Text('${l10n.get('actualClicks')}: ${record.actualClicks}'),
                            if (record.duration != null) ...[
                              const SizedBox(height: 4),
                              Text('${l10n.get('duration')}: ${record.duration!.inSeconds}${l10n.get('seconds')}'),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
