import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../domain/entities/certificate.dart';

class PdfService {
  Future<File> generateCertificate(Certificate certificate) async {
    final doc = pw.Document();
    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        build: (context) => pw.Center(
          child: pw.Column(
            mainAxisAlignment: pw.MainAxisAlignment.center,
            children: [
              pw.Text(
                'Certificate of Completion',
                style: pw.TextStyle(
                  fontSize: 28,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 24),
              pw.Text(
                certificate.learnerName,
                style: const pw.TextStyle(fontSize: 22),
              ),
              pw.SizedBox(height: 12),
              pw.Text(
                'has successfully completed',
                style: const pw.TextStyle(fontSize: 14),
              ),
              pw.SizedBox(height: 12),
              pw.Text(
                certificate.courseTitle,
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 24),
              pw.Text(
                'Verification: ${certificate.uniqueCode}',
                style: const pw.TextStyle(fontSize: 10),
              ),
              pw.Text(
                'Issued: ${certificate.issuedAt.day}/${certificate.issuedAt.month}/${certificate.issuedAt.year}',
                style: const pw.TextStyle(fontSize: 10),
              ),
            ],
          ),
        ),
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/certificate_${certificate.id}.pdf');
    await file.writeAsBytes(await doc.save());
    return file;
  }
}
