import '../domain/step_repository.dart';
import 'step_entry.dart';
import 'step_local_data_source.dart';

/// Repository implementation delegating persistence tasks to [StepLocalDataSource].
class StepRepositoryImpl implements StepRepository {
  final StepLocalDataSource _dataSource;

  StepRepositoryImpl(this._dataSource);

  @override
  Future<void> saveStepEntry(StepEntry entry) => _dataSource.saveStepEntry(entry);

  @override
  StepEntry? getStepEntry(String id) => _dataSource.getStepEntry(id);

  @override
  Future<void> deleteStepEntry(String id) => _dataSource.deleteStepEntry(id);

  @override
  List<StepEntry> getEntriesForRange(DateTime start, DateTime end) =>
      _dataSource.getEntriesForRange(start, end);

  @override
  List<StepEntry> getAllEntries() => _dataSource.getAllEntries();
}
