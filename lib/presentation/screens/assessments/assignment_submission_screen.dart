import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/app_providers.dart';
import '../../../domain/entities/assessment.dart';
import '../../providers/assessment_provider.dart';

class AssignmentSubmissionScreen extends ConsumerStatefulWidget {
  const AssignmentSubmissionScreen({required this.assessment, super.key});

  final Assessment assessment;

  @override
  ConsumerState<AssignmentSubmissionScreen> createState() =>
      _AssignmentSubmissionScreenState();
}

class _AssignmentSubmissionScreenState
    extends ConsumerState<AssignmentSubmissionScreen> {
  final _commentController = TextEditingController();
  String? _filePath;
  String? _fileName;
  bool _submitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  bool get _isLate {
    final dueDate = widget.assessment.dueDate;
    return dueDate != null && DateTime.now().isAfter(dueDate);
  }

  Future<void> _pickPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf'],
      withData: false,
    );

    if (!mounted || result == null || result.files.single.path == null) {
      return;
    }

    setState(() {
      _filePath = result.files.single.path;
      _fileName = result.files.single.name;
    });
  }

  Future<void> _submit() async {
    if (_isLate) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('The assignment deadline has passed.')),
      );
      return;
    }

    final filePath = _filePath;
    if (filePath == null || filePath.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please choose a PDF file first.')),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      await ref.read(assessmentRepositoryProvider).submitAssignment(
            assessmentId: widget.assessment.id,
            filePath: filePath,
            content: _commentController.text.trim(),
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Assignment submitted successfully.')),
      );
      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dueDateText = widget.assessment.dueDate == null
        ? 'No deadline set'
        : 'Due ${widget.assessment.dueDate!.day}/${widget.assessment.dueDate!.month}/${widget.assessment.dueDate!.year}';

    return Scaffold(
      appBar: AppBar(title: Text(widget.assessment.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.assessment.description,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(dueDateText),
                    if (_isLate) ...[
                      const SizedBox(height: 8),
                      const Text(
                        'This assignment is closed because the deadline has passed.',
                        style: TextStyle(color: Colors.red),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _submitting || _isLate ? null : _pickPdf,
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text('Choose PDF file'),
            ),
            if (_fileName != null) ...[
              const SizedBox(height: 8),
              Text('Selected file: $_fileName'),
            ],
            const SizedBox(height: 16),
            TextField(
              controller: _commentController,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Optional note',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _submitting || _isLate ? null : _submit,
              icon: _submitting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.cloud_upload),
              label: const Text('Submit assignment'),
            ),
          ],
        ),
      ),
    );
  }
}