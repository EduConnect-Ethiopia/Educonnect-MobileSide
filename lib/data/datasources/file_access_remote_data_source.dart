import 'package:dio/dio.dart';

import '../../core/constants/api_endpoints.dart';
import '../../core/utils/json_map.dart';

class MaterialAccessGrant {
  const MaterialAccessGrant({
    required this.accessUrl,
    required this.expiresInMinutes,
    required this.suggestedFileName,
  });

  final String accessUrl;
  final int expiresInMinutes;
  final String suggestedFileName;

  factory MaterialAccessGrant.fromJson(JsonMap json) {
    final data = findMap(json, const ['data', 'result']) ?? json;
    return MaterialAccessGrant(
      accessUrl: findString(data, const ['accessUrl']) ?? '',
      expiresInMinutes: _readInt(data['expiresInMinutes']) ?? 10,
      suggestedFileName: findString(data, const ['suggestedFileName']) ?? '',
    );
  }
}

abstract class FileAccessRemoteDataSource {
  Future<MaterialAccessGrant> createMaterialAccess(String materialId);
}

class DioFileAccessRemoteDataSource implements FileAccessRemoteDataSource {
  const DioFileAccessRemoteDataSource(this._dio);

  final Dio _dio;

  @override
  Future<MaterialAccessGrant> createMaterialAccess(String materialId) async {
    final response = await _dio.post<dynamic>(ApiEndpoints.materialAccess(materialId));
    return MaterialAccessGrant.fromJson(castJsonMap(response.data));
  }
}

int? _readInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}