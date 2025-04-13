import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/clicker_state.dart';

class RecordsPanel extends StatelessWidget {
  const RecordsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<ClickerState>(context);

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
                  child: const Text('清空记录'),
                ),
              ],
            ),
          ),
        Expanded(
          child:
              state.taskRecords.isEmpty
                  ? const Center(child: Text('暂无任务记录'))
                  : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                    itemCount: state.taskRecords.length,
                    itemBuilder: (context, index) {
                      final record =
                          state.taskRecords[state.taskRecords.length -
                              1 -
                              index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${record.timestamp.hour}:${record.timestamp.minute.toString().padLeft(2, '0')}:${record.timestamp.second.toString().padLeft(2, '0')}',
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                  ),
                                  Chip(
                                    label: Text(record.status),
                                    backgroundColor:
                                        record.completed
                                            ? Colors.green[100]
                                            : Colors.red[100],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text('模式: ${record.mode}'),
                              const SizedBox(height: 4),
                              Text('目标次数: ${record.targetClicks}'),
                              const SizedBox(height: 4),
                              Text('实际次数: ${record.actualClicks}'),
                              if (record.duration != null) ...[
                                const SizedBox(height: 4),
                                Text('耗时: ${record.duration!.inSeconds}秒'),
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
