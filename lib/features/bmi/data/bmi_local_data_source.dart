import 'package:hive/hive.dart';

import 'bmi_entry.dart';

/// Local data source persisting [BMIEntry] calculation history logs.
class BmiLocalDataSource {
  static const String boxName = 'bmi_entries';

  Box<BMIEntry> get _box => Hive.box<BMIEntry>(boxName);

  /// Saves a new BMI calculation entry.
  Future<void> saveBMIEntry(BMIEntry entry) async {
    final now = entry.timestamp;
    String? targetId;
    for (final existing in _box.values) {
      if (existing.timestamp.year == now.year &&
          existing.timestamp.month == now.month &&
          existing.timestamp.day == now.day) {
        targetId = existing.id;
        break;
      }
    }

    if (targetId != null) {
      final updated = BMIEntry(
        id: targetId,
        heightCm: entry.heightCm,
        weightKg: entry.weightKg,
        bmiValue: entry.bmiValue,
        category: entry.category,
        timestamp: entry.timestamp,
      );
      await _box.put(targetId, updated);
    } else {
      await _box.put(entry.id, entry);
    }
  }

  /// Deletes a historical entry by ID.
  Future<void> deleteBMIEntry(String id) async {
    await _box.delete(id);
  }

  /// Retrieves all entries sorted by date (newest first).
  List<BMIEntry> getAllEntries() {
    final list = _box.values.toList();
    list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return list;
  }
}
