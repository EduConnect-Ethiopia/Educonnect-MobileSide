import 'dart:io';

import 'package:dio/dio.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

import '../datasources/local/course_cache_local_data_source.dart';

class MaterialFileCacheService {
  MaterialFileCacheService({
    required Dio dio,
    required CourseCacheLocalDataSource cache,
  })  : _dio = dio,
        _cache = cache;

  final Dio _dio;
  final CourseCacheLocalDataSource _cache;

  Future<void> openOrDownloadMaterial({
    required String materialId,
    required String accessUrl,
  }) async {
    final cachedPath = _cache.getMaterialFilePath(materialId);
    if (cachedPath != null) {
      final cachedFile = File(cachedPath);
      if (await cachedFile.exists()) {
        await OpenFilex.open(cachedPath);
        return;
      }
    }

    final file = await _downloadMaterial(materialId: materialId, accessUrl: accessUrl);
    await OpenFilex.open(file.path);
  }

  Future<File> _downloadMaterial({
    required String materialId,
    required String accessUrl,
  }) async {
    final directory = await getApplicationDocumentsDirectory();
    final materialsDirectory = Directory(
      '${directory.path}${Platform.pathSeparator}materials',
    );
    if (!await materialsDirectory.exists()) {
      await materialsDirectory.create(recursive: true);
    }

    final extension = _resolveExtension(accessUrl);
    final filePath =
        '${materialsDirectory.path}${Platform.pathSeparator}$materialId$extension';

    try {
      await _dio.download(accessUrl, filePath);
    } catch (e) {
      // If download fails, ensure we don't leave a partial file and provide a clear error
      final partial = File(filePath);
      if (await partial.exists()) {
        try {
          await partial.delete();
        } catch (_) {}
      }
      rethrow;
    }
    await _cache.saveMaterialFilePath(materialId, filePath);
    return File(filePath);
  }

  String _resolveExtension(String accessUrl) {
    try {
      final path = Uri.parse(accessUrl).path;
      final fileName = path.split('/').last;
      if (fileName.contains('.')) {
        final extension = fileName.substring(fileName.lastIndexOf('.'));
        if (extension.length <= 5) {
          return extension;
        }
      }
    } on Object {
      // Fall back below.
    }

    return '.pdf';
  }
}
