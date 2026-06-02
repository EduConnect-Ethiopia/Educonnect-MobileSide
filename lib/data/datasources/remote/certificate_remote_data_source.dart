import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../../../core/constants/api_endpoints.dart';
import '../../../core/utils/json_map.dart';
import '../../models/certificate_models.dart';

abstract class CertificateRemoteDataSource {
  Future<List<CertificateDto>> getMyCertificates();
  Future<CertificateDto?> getCertificate(String id);
  Future<Uint8List> downloadCertificatePdf(String id);
  Future<CertificateEligibilityDto> getEligibility(String courseId);
  Future<CertificateDto> issueCertificate(String courseId);
}

class DioCertificateRemoteDataSource implements CertificateRemoteDataSource {
  const DioCertificateRemoteDataSource(this._dio);

  final Dio _dio;

  @override
  Future<List<CertificateDto>> getMyCertificates() async {
    final response = await _dio.get<dynamic>(ApiEndpoints.certificates);
    return unwrapJsonList(response.data)
        .map(CertificateDto.fromJson)
        .toList();
  }

  @override
  Future<CertificateDto?> getCertificate(String id) async {
    final response = await _dio.get<dynamic>(ApiEndpoints.certificate(id));
    if (response.data == null) return null;
    return CertificateDto.fromJson(castJsonMap(response.data));
  }

  @override
  Future<CertificateEligibilityDto> getEligibility(String courseId) async {
    final response = await _dio.get<dynamic>(
      ApiEndpoints.certificateEligibility(courseId),
    );
    return CertificateEligibilityDto.fromJson(castJsonMap(response.data));
  }

  @override
  Future<CertificateDto> issueCertificate(String courseId) async {
    final response = await _dio.post<dynamic>(
      ApiEndpoints.certificateIssue(courseId),
    );
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

}
