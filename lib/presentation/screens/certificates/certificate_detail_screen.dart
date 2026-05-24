import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../../../domain/entities/certificate.dart';
import '../../providers/certificate_provider.dart';

class CertificateDetailScreen extends ConsumerWidget {
  const CertificateDetailScreen({required this.certificate, super.key});

  final Certificate certificate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Certificate')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildCertificatePreview(context),
            const SizedBox(height: 24),
            _buildCertificateInfo(context),
            const SizedBox(height: 24),
            _buildQRCode(),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.download),
                    label: const Text('Download PDF'),
                    onPressed: () => _downloadCertificate(context, ref),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.share),
                    label: const Text('Share'),
                    onPressed: () => _shareCertificate(context, ref),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCertificatePreview(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.amber, width: 2),
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [
            Colors.amber.shade50,
            Colors.white,
          ],
        ),
      ),
      child: Column(
        children: [
          const Icon(Icons.workspace_premium, size: 48, color: Colors.amber),
          const SizedBox(height: 12),
          Text(
            'Certificate of Completion',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            certificate.courseTitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildCertificateInfo(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.person_outline),
          title: const Text('Learner'),
          subtitle: Text(certificate.learnerName),
        ),
        ListTile(
          leading: const Icon(Icons.calendar_today_outlined),
          title: const Text('Issued'),
          subtitle: Text(
            '${certificate.issuedAt.day}/${certificate.issuedAt.month}/${certificate.issuedAt.year}',
          ),
        ),
        ListTile(
          leading: const Icon(Icons.verified_outlined),
          title: const Text('Verification code'),
          subtitle: Text(certificate.uniqueCode),
        ),
      ],
    );
  }

  Widget _buildQRCode() {
    return Column(
      children: [
        QrImageView(
          data: certificate.shareVerificationUrl,
          size: 150,
        ),
        const SizedBox(height: 8),
        Text(
          'Scan to verify',
          style: TextStyle(color: Colors.grey.shade600),
        ),
        const SizedBox(height: 4),
        SelectableText(
          certificate.shareVerificationUrl,
          style: const TextStyle(fontSize: 12),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Future<void> _downloadCertificate(BuildContext context, WidgetRef ref) async {
    try {
      final file = await ref
          .read(certificateControllerProvider.notifier)
          .downloadCertificate(certificate.id);
      if (!context.mounted) return;
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'My Certificate from EduConnect',
      );
    } on Object {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to generate certificate PDF')),
      );
    }
  }

  Future<void> _shareCertificate(BuildContext context, WidgetRef ref) async {
    await Share.share(
      'I earned a certificate for ${certificate.courseTitle}! '
      'Verify at ${certificate.shareVerificationUrl}',
    );
  }
}
