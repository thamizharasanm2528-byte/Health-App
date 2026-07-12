import '../data/bmi_entry.dart';

/// Repository interface for storing and retrieving BMI calculation entries.
abstract class BmiRepository {
  Future<void> saveBMIEntry(BMIEntry entry);
  Future<void> deleteBMIEntry(String id);
  List<BMIEntry> getAllEntries();
}
