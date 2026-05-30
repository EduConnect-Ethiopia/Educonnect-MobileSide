import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../../../core/constants/api_endpoints.dart';
import '../../../core/utils/json_map.dart';
import '../../models/certificate_models.dart';

abstract class CertificateRemoteDataSource {
  Future<List<CertificateDto>> getMyCertificates();
  Future<CertificateDto?> getCertificate(String id);
  Future<Uint8List> downloadCertificatePdf(String id);
}

class DioCertificateRemoteDataSource implements CertificateRemoteDataSource {
  const DioCertificateRemoteDataSource(this._dio);

  final Dio _dio;

  @override
  Future<List<CertificateDto>> getMyCertificates() async {
    final response = await _dio.get<dynamic>(ApiEndpoints.certificates);
    final data = _unwrapList(response.data);
    return data
        .map((json) => CertificateDto.fromJson(castJsonMap(json)))
        .toList();
  }

  @override
  Future<CertificateDto?> getCertificate(String id) async {
    final response = await _dio.get<dynamic>(ApiEndpoints.certificate(id));
    if (response.data == null) return null;
    return CertificateDto.fromJson(castJsonMap(response.data));
  }

  @override
  Future<Uint8List> downloadCertificatePdf(String id) async {
    final response = await _dio.get<List<int>>(
      ApiEndpoints.certificateDownload(id),
      options: Options(responseType: ResponseType.bytes),
    );
    return Uint8List.fromList(response.data ?? []);
  }

  List<Map<String, dynamic>> _unwrapList(Object? value) {
    if (value is List) {
      return value.whereType<Map<String, dynamic>>().toList();
    }
    if (value is Map) {
      final map = castJsonMap(value);
      final data = map['data'];
      if (data is List) {
        return data.whereType<Map<String, dynamic>>().toList();
      }
    }
    return const [];
  }
}
