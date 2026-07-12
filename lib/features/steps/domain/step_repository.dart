import '../data/step_entry.dart';

/// Repository interface defining step count persistence operations.
abstract class StepRepository {
  /// Saves or updates a step entry.
  Future<void> saveStepEntry(StepEntry entry);

  /// Gets a step entry for a specific date key ('yyyy-MM-dd').
  StepEntry? getStepEntry(String id);

  /// Deletes a step entry by ID.
  Future<void> deleteStepEntry(String id);

  /// Retrieves step entries within a specific date range.
  List<StepEntry> getEntriesForRange(DateTime start, DateTime end);

  /// Retrieves all step entries, sorted newest to oldest.
  List<StepEntry> getAllEntries();
}
