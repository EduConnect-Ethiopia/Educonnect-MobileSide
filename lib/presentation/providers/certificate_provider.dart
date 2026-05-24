import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/di/app_providers.dart';
import '../../domain/entities/certificate.dart';

final certificateControllerProvider =
    NotifierProvider<CertificateController, CertificateState>(
  CertificateController.new,
);

class CertificateController extends Notifier<CertificateState> {
  @override
  CertificateState build() => CertificateState.initial();

  Future<void> loadCertificates() async {
    state = state.copyWith(isLoading: true);
    try {
      final certs =
          await ref.read(certificateRepositoryProvider).getCertificates();
      state = state.copyWith(isLoading: false, certificates: certs);
    } on Object {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<File> downloadCertificate(String certificateId) async {
    final bytes = await ref
        .read(certificateRepositoryProvider)
        .downloadCertificatePdf(certificateId);
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/certificate-$certificateId.pdf');
    await file.writeAsBytes(bytes);
    return file;
  }
}

class CertificateState {
  const CertificateState({
    required this.certificates,
    required this.isLoading,
  });

  const CertificateState.initial()
      : certificates = const [],
        isLoading = false;

  final List<Certificate> certificates;
  final bool isLoading;

  CertificateState copyWith({
    List<Certificate>? certificates,
    bool? isLoading,
  }) {
    return CertificateState(
      certificates: certificates ?? this.certificates,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
