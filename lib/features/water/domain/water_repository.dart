import '../data/water_entry.dart';

/// Abstract contract for water tracking persistence.
abstract class WaterRepository {
  Future<void> addEntry(WaterEntry entry);
  Future<void> updateEntry(WaterEntry entry);
  Future<void> deleteEntry(String id);
  List<WaterEntry> getEntriesForDate(DateTime date);
  List<WaterEntry> getEntriesForRange(DateTime start, DateTime end);
  List<WaterEntry> getAllEntries();
  int totalForDate(DateTime date);
}
