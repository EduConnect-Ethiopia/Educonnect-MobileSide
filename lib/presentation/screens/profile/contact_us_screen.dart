import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/settings_provider.dart';

class ContactUsScreen extends ConsumerWidget {
  const ContactUsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAmharic = ref.watch(settingsProvider).language == 'am';

    return Scaffold(
      appBar: AppBar(
        title: Text(isAmharic ? 'ያግኙን' : 'Contact Us'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _InfoCard(
            title: isAmharic ? 'የድጋፍ ኢሜይል' : 'Support Email',
            value: 'support@educonnect.et',
          ),
          const SizedBox(height: 12),
          _InfoCard(
            title: isAmharic ? 'የመለያ ድጋፍ' : 'Account Questions',
            value: isAmharic
                ? 'ለመለያ ማጥፋት ወይም ማስቀመጫ ጥያቄዎች አስተዳዳሪዎን ያነጋግሩ።'
                : 'Contact your admin for deletion or retention questions.',
          ),
          const SizedBox(height: 12),
          _InfoCard(
            title: isAmharic ? 'አጭር መልዕክት' : 'Message',
            value: isAmharic
                ? 'ኮርስ፣ ፈተና፣ ሰርተፊኬት ወይም መግቢያ ችግኝ ካለ ይጻፉ።'
                : 'Write to us about courses, assessments, certificates, or sign-in issues.',
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 8),
            Text(value, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
