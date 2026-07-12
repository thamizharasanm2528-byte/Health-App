import '../data/sleep_record.dart';
import '../data/sleep_local_data_source.dart';
import '../domain/sleep_repository.dart';

/// Concrete repository implementing the [SleepRepository] operations.
class SleepRepositoryImpl implements SleepRepository {
  final SleepLocalDataSource _dataSource;

  SleepRepositoryImpl(this._dataSource);

  @override
  Future<void> saveSleepRecord(SleepRecord record) => _dataSource.saveSleepRecord(record);

  @override
  Future<void> deleteSleepRecord(String id) => _dataSource.deleteSleepRecord(id);

  @override
  List<SleepRecord> getAllRecords() => _dataSource.getAllRecords();
}
