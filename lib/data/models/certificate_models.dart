import '../../core/utils/json_map.dart';
import '../../domain/entities/certificate.dart';

class CertificateDto {
  const CertificateDto({
    required this.certificateId,
    required this.courseId,
    required this.issueDate,
    required this.certificateUrl,
    required this.verificationCode,
  });

  final String certificateId;
  final String courseId;
  final DateTime issueDate;
  final String certificateUrl;
  final String verificationCode;

  factory CertificateDto.fromJson(JsonMap json) {
    final data = findMap(json, const ['data', 'result']) ?? json;
    return CertificateDto(
      certificateId:
          findString(data, const ['certificateId', 'id']) ?? '',
      courseId: findString(data, const ['courseId']) ?? '',
      issueDate:
          parseDateTime(readJsonValue(data, const ['issueDate'])) ??
          DateTime.now(),
      certificateUrl: findString(data, const ['certificateUrl']) ?? '',
      verificationCode:
          findString(data, const ['verificationCode']) ?? '',
    );
  }

  Certificate toEntity({
    required String courseTitle,
    required String learnerName,
    String? publicBaseUrl,
  }) {
    final verifyBase = publicBaseUrl ?? 'https://verify.educonnect.et';
    return Certificate(
      id: certificateId,
      courseId: courseId,
      courseTitle: courseTitle,
      learnerName: learnerName,
      issuedAt: issueDate,
      uniqueCode: verificationCode,
      pdfUrl: certificateUrl.isNotEmpty ? certificateUrl : null,
      verificationUrl: '$verifyBase/$verificationCode',
    );
  }
}

class CertificateEligibilityDto {
  const CertificateEligibilityDto({
    required this.isEligible,
    required this.missingRequirements,
    this.existingCertificateId,
  });

  final bool isEligible;
  final List<String> missingRequirements;
  final String? existingCertificateId;

  factory CertificateEligibilityDto.fromJson(JsonMap json) {
    final data = findMap(json, const ['data', 'result']) ?? json;
    final missingRaw = readJsonValue(data, const ['missingRequirements']);
    final missing = missingRaw is List
        ? missingRaw.map((e) => e.toString()).toList()
        : <String>[];

    return CertificateEligibilityDto(
      isEligible: readJsonValue(data, const ['isEligible']) == true,
      missingRequirements: missing,
      existingCertificateId:
          findString(data, const ['existingCertificateId']),
    );
  }
}
