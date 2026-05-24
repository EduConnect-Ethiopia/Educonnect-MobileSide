import 'dart:typed_data';

import '../entities/certificate.dart';

abstract class CertificateRepository {
  Future<List<Certificate>> getCertificates();
  Future<Certificate?> getCertificate(String certificateId);
  Future<Uint8List> downloadCertificatePdf(String certificateId);
}
