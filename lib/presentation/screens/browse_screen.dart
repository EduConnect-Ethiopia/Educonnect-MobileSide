import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../data/mock/mock_courses.dart';
import '../widgets/course_card.dart';
import '../widgets/section_header.dart';

class BrowseScreen extends StatelessWidget {
  const BrowseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final courses = mockRecommendedCourses();

    return Scaffold(
      appBar: AppBar(title: const Text('Browse')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 16),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              enabled: false,
              decoration: InputDecoration(
                hintText: 'Search courses',
                prefixIcon: const Icon(Icons.search_outlined),
                suffixIcon: Tooltip(
                  message: 'Course catalog is coming soon',
                  child: Icon(
                    Icons.info_outline,
                    color: AppColors.textSubtitle.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: _CatalogNotice(),
          ),
          const SectionHeader(title: 'Discovery Preview'),
          ...courses.map((course) => CourseCard(course: course)),
        ],
      ),
    );
  }
}

class _CatalogNotice extends StatelessWidget {
  const _CatalogNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.search_off_outlined, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Live catalog browsing is waiting on the learner catalog API.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
