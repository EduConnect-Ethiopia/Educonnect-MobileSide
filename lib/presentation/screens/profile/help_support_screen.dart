import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/settings_provider.dart';
import 'contact_us_screen.dart';
import 'faq_screen.dart';
import 'policy_document_screen.dart';

class HelpSupportScreen extends ConsumerWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAmharic = ref.watch(settingsProvider).language == 'am';

    return Scaffold(
      appBar: AppBar(
        title: Text(isAmharic ? 'እገዛ እና ድጋፍ' : 'Help & Support'),
      ),
      body: ListView(
        children: [
          _SupportTile(
            icon: Icons.quiz_outlined,
            title: isAmharic ? 'ጥያቄና መልስ' : 'FAQ',
            subtitle: isAmharic
                ? 'በተደጋጋሚ የሚጠየቁ ጥያቄዎች'
                : 'Browse common questions and answers',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const FaqScreen()),
              );
            },
          ),
          _SupportTile(
            icon: Icons.support_agent_outlined,
            title: isAmharic ? 'ያግኙን' : 'Contact Us',
            subtitle: isAmharic
                ? 'የድጋፍ መረጃ እና መገኛ'
                : 'Support contact details',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const ContactUsScreen()),
              );
            },
          ),
          _SupportTile(
            icon: Icons.privacy_tip_outlined,
            title: isAmharic ? 'የግል መረጃ ፖሊሲ' : 'Privacy Policy',
            subtitle: isAmharic
                ? 'የሚሰበሰበው መረጃ እና የአጠቃቀም መመሪያ'
                : 'How EduConnect collects and uses data',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => PolicyDocumentScreen(
                    title: isAmharic ? 'የግል መረጃ ፖሊሲ' : 'Privacy Policy',
                    sections: const [
                      PolicySection(
                        title: 'Data we collect',
                        body:
                            'EduConnect is designed to collect only the information needed to deliver learning, assessments, and certificates with confidence.\n\nEduConnect collects only data needed to operate accounts, courses, assessments, and certificates.',
                      ),
                      PolicySection(
                        title: 'How we use it',
                        body:
                            'Account data is used for authentication and notifications. Institutions may submit accreditation documents for review. Public certificate verification may show learner and course names.',
                      ),
                      PolicySection(
                        title: 'Cookie policy summary',
                        body:
                            'EduConnect may use essential cookies and session technologies to keep sign-in secure, maintain preferences, and understand baseline usage patterns. No personal data is sold, and users can contact support for more information about retention or deletion requests.',
                      ),
                      PolicySection(
                        title: 'Retention and deletion',
                        body:
                            'Contact your admin for deletion or retention questions.',
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          _SupportTile(
            icon: Icons.gavel_outlined,
            title: isAmharic ? 'የህግ ውሎች' : 'Terms of Use',
            subtitle: isAmharic
                ? 'የመድረኩ አጠቃቀም ውሎች'
                : 'Platform rules and responsibilities',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => PolicyDocumentScreen(
                    title: isAmharic ? 'የህግ ውሎች' : 'Terms of Use',
                    sections: const [
                      PolicySection(
                        title: 'Terms',
                        body:
                            'The platform works best when learners, instructors, institutions, and administrators all share the same trust expectations.',
                      ),
                      PolicySection(
                        title: 'Responsible use',
                        body:
                            'By using EduConnect you agree to responsible use and academic integrity. Protect staff login credentials. Course content must comply with copyright and regulations. Certificates reflect system-recorded completion. Learner enrollment and payments are handled in the mobile app.',
                      ),
                      PolicySection(
                        title: 'Certificate responsibility',
                        body:
                            'Verifiable certificates are a trust feature. They must not be misrepresented, altered, or used to imply completion where requirements were not actually met.',
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SupportTile extends StatelessWidget {
  const _SupportTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
