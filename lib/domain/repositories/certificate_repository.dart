import 'dart:typed_data';

import '../entities/certificate.dart';

class CertificateEligibility {
  const CertificateEligibility({
    required this.isEligible,
    required this.missingRequirements,
    this.existingCertificateId,
  });

  final bool isEligible;
  final List<String> missingRequirements;
  final String? existingCertificateId;
}

abstract class CertificateRepository {
  Future<List<Certificate>> getCertificates();
  Future<Certificate?> getCertificate(String certificateId);
  Future<Uint8List> downloadCertificatePdf(String certificateId);
  Future<CertificateEligibility> getEligibility(String courseId);
  Future<Certificate> issueCertificate(String courseId);
}
