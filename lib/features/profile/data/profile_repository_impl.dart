import '../data/profile_local_data_source.dart';
import '../data/profile_model.dart';
import '../domain/profile_repository.dart';

/// Concrete [ProfileRepository] backed by [ProfileLocalDataSource].
class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileLocalDataSource _dataSource;

  ProfileRepositoryImpl(this._dataSource);

  @override
  Future<void> saveProfile(ProfileModel profile) =>
      _dataSource.saveProfile(profile);

  @override
  ProfileModel? getProfile() => _dataSource.getProfile();

  @override
  bool hasProfile() => _dataSource.hasProfile();
}
