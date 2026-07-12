import '../data/water_entry.dart';
import '../data/water_local_data_source.dart';
import '../domain/water_repository.dart';

/// Concrete [WaterRepository] backed by [WaterLocalDataSource].
class WaterRepositoryImpl implements WaterRepository {
  final WaterLocalDataSource _dataSource;
  WaterRepositoryImpl(this._dataSource);

  @override
  Future<void> addEntry(WaterEntry entry) => _dataSource.addEntry(entry);

  @override
  Future<void> updateEntry(WaterEntry entry) => _dataSource.updateEntry(entry);

  @override
  Future<void> deleteEntry(String id) => _dataSource.deleteEntry(id);

  @override
  List<WaterEntry> getEntriesForDate(DateTime date) =>
      _dataSource.getEntriesForDate(date);

  @override
  List<WaterEntry> getEntriesForRange(DateTime start, DateTime end) =>
      _dataSource.getEntriesForRange(start, end);

  @override
  List<WaterEntry> getAllEntries() => _dataSource.getAllEntries();

  @override
  int totalForDate(DateTime date) => _dataSource.totalForDate(date);
}
