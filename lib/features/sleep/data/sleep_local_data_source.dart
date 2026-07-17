import 'package:hive_ce/hive_ce.dart';

import 'sleep_record.dart';

/// Local data source persisting [SleepRecord] logs using Hive.
class SleepLocalDataSource {
  static const String boxName = 'sleep_records';

  Box<SleepRecord> get _box => Hive.box<SleepRecord>(boxName);

  /// Saves a new sleep record.
  Future<void> saveSleepRecord(SleepRecord record) async {
    await _box.put(record.id, record);
  }

  /// Deletes a logged record by ID.
  Future<void> deleteSleepRecord(String id) async {
    await _box.delete(id);
  }

  /// Retrieves all records sorted by date (newest first).
  List<SleepRecord> getAllRecords() {
    final list = _box.values.toList();
    list.sort((a, b) => b.bedtime.compareTo(a.bedtime));
    return list;
  }
}
