import '../models/changelog_entry.dart';

final List<ChangelogEntry> changelog = [
  ChangelogEntry(
    version: 'v0.0.1',
    date: DateTime(2025, 4, 15),
    changes: [
      '初始版本发布(MacOS)',
      '支持仿生模式和普通模式',
      '支持暗黑模式',
      '支持自定义主题色',
    ],
  ),
];