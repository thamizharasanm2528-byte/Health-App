import '../data/sleep_record.dart';

/// Repository interface for storing and retrieving sleep records.
abstract class SleepRepository {
  Future<void> saveSleepRecord(SleepRecord record);
  Future<void> deleteSleepRecord(String id);
  List<SleepRecord> getAllRecords();
}
