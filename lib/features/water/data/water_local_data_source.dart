import 'package:hive/hive.dart';

import 'water_entry.dart';

/// Hive-backed local data source for [WaterEntry] records.
///
/// All entries live in a single box. Queries filter by date range.
class WaterLocalDataSource {
  static const String boxName = 'water_entries';

  Box<WaterEntry> get _box => Hive.box<WaterEntry>(boxName);

  /// Adds a new water entry.
  Future<void> addEntry(WaterEntry entry) async {
    await _box.put(entry.id, entry);
  }

  /// Updates an existing entry (matched by [entry.id]).
  Future<void> updateEntry(WaterEntry entry) async {
    await _box.put(entry.id, entry);
  }

  /// Deletes an entry by ID.
  Future<void> deleteEntry(String id) async {
    await _box.delete(id);
  }

  /// Returns all entries for a specific date (ignoring time).
  List<WaterEntry> getEntriesForDate(DateTime date) {
    return _box.values.where((e) {
      return e.timestamp.year == date.year &&
          e.timestamp.month == date.month &&
          e.timestamp.day == date.day;
    }).toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  /// Returns entries between [start] and [end] (inclusive).
  List<WaterEntry> getEntriesForRange(DateTime start, DateTime end) {
    final startDay = DateTime(start.year, start.month, start.day);
    final endDay = DateTime(end.year, end.month, end.day, 23, 59, 59);
    return _box.values.where((e) {
      return !e.timestamp.isBefore(startDay) && !e.timestamp.isAfter(endDay);
    }).toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }

  /// Returns every entry in the box.
  List<WaterEntry> getAllEntries() {
    return _box.values.toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  /// Total intake in ml for a specific date.
  int totalForDate(DateTime date) {
    return getEntriesForDate(date).fold(0, (sum, e) => sum + e.amountMl);
  }
}
