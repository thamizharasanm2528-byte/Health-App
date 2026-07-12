import 'package:hive/hive.dart';

import 'step_entry.dart';

/// Local data source persisting [StepEntry] records using Hive.
class StepLocalDataSource {
  static const String boxName = 'step_entries';

  Box<StepEntry> get _box => Hive.box<StepEntry>(boxName);

  /// Saves or updates a step entry.
  Future<void> saveStepEntry(StepEntry entry) async {
    await _box.put(entry.id, entry);
  }

  /// Gets step entry for a specific ID (formatted as yyyy-MM-dd).
  StepEntry? getStepEntry(String id) {
    return _box.get(id);
  }

  /// Deletes a step entry by ID.
  Future<void> deleteStepEntry(String id) async {
    await _box.delete(id);
  }

  /// Returns entries within the given date range.
  List<StepEntry> getEntriesForRange(DateTime start, DateTime end) {
    final startDay = DateTime(start.year, start.month, start.day);
    final endDay = DateTime(end.year, end.month, end.day, 23, 59, 59);

    return _box.values.where((e) {
      return !e.date.isBefore(startDay) && !e.date.isAfter(endDay);
    }).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  /// Returns all tracked step entries.
  List<StepEntry> getAllEntries() {
    return _box.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }
}
