import 'package:flutter/material.dart';

class PolicySection {
  const PolicySection({required this.title, required this.body});

  final String title;
  final String body;
}

class PolicyDocumentScreen extends StatelessWidget {
  const PolicyDocumentScreen({
    required this.title,
    required this.sections,
    super.key,
  });

  final String title;
  final List<PolicySection> sections;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: sections.length,
        itemBuilder: (context, index) {
          final section = sections[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    section.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    section.body,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          height: 1.45,
                        ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
