import '../../domain/repositories/file_access_repository.dart';
import '../datasources/file_access_remote_data_source.dart';

class FileAccessRepositoryImpl implements FileAccessRepository {
  const FileAccessRepositoryImpl({required FileAccessRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  final FileAccessRemoteDataSource _remoteDataSource;

  @override
  Future<String> createMaterialAccessUrl(String materialId) async {
    final grant = await _remoteDataSource.createMaterialAccess(materialId);
    return grant.accessUrl;
  }
}