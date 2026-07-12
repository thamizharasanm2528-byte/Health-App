import '../data/bmi_entry.dart';
import '../data/bmi_local_data_source.dart';
import '../domain/bmi_repository.dart';

/// Concrete repository implementing the [BmiRepository] operations.
class BmiRepositoryImpl implements BmiRepository {
  final BmiLocalDataSource _dataSource;

  BmiRepositoryImpl(this._dataSource);

  @override
  Future<void> saveBMIEntry(BMIEntry entry) => _dataSource.saveBMIEntry(entry);

  @override
  Future<void> deleteBMIEntry(String id) => _dataSource.deleteBMIEntry(id);

  @override
  List<BMIEntry> getAllEntries() => _dataSource.getAllEntries();
}
