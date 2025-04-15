class ChangelogEntry {
  final String version;
  final DateTime date;
  final List<String> changes;

  const ChangelogEntry({
    required this.version,
    required this.date,
    required this.changes,
  });
}