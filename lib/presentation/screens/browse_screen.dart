import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/search_debouncer.dart';
import '../../domain/entities/course.dart';
import '../providers/featured_courses_provider.dart';
import '../providers/recommendation_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/enrollment_provider.dart';
import '../widgets/section_header.dart';
import 'course_detail_screen.dart';

class BrowseScreen extends ConsumerStatefulWidget {
  const BrowseScreen({super.key});

  @override
  ConsumerState<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends ConsumerState<BrowseScreen> {
  final _searchController = TextEditingController();
  final _debouncer = SearchDebouncer();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debouncer.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _debouncer.run(() {
      if (!mounted) return;
      final query = _searchController.text.trim();
      setState(() => _query = query);
      ref.read(featuredCoursesControllerProvider.notifier).loadCourses(query: query);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(featuredCoursesControllerProvider);
    final courses = state.courses;
    final isAmharic = ref.watch(settingsProvider).language == 'am';
    final myCourses = ref.watch(myCoursesProvider).value ?? const <Course>[];
    final ownedCourseIds = myCourses.map((course) => course.id).toSet();

    return Scaffold(
      appBar: AppBar(
        title: Text(isAmharic ? 'ይፈልጉ' : 'Browse'),
        actions: [
          IconButton(
            tooltip: isAmharic ? 'አድስ' : 'Refresh',
            onPressed: state.isLoading
                ? null
                : () => ref
                    .read(featuredCoursesControllerProvider.notifier)
                    .loadCourses(query: _query),
            icon: const Icon(Icons.refresh_outlined),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(featuredCoursesControllerProvider.notifier).loadCourses(query: _query),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search courses',
                    prefixIcon: const Icon(Icons.search_outlined),
                    suffixIcon: _query.isEmpty
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () => _searchController.clear(),
                          ),
                  ),
                ),
              ),
            ),
            if (state.errorMessage != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: _ErrorBanner(message: state.errorMessage!),
                ),
              ),
            if (state.isLoading && state.courses.isEmpty)
              const SliverToBoxAdapter(child: LinearProgressIndicator()),
            if (courses.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: SectionHeader(
                  title: _query.isEmpty
                      ? 'Available Courses'
                      : 'Results (${courses.length})',
                ),
              ),
              SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.75,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final course = courses[index];
                    final isOwned =
                        ownedCourseIds.contains(course.id) || course.enrollmentId != null;
                    return _CourseGridCard(course: course, showBuyButton: !isOwned);
                  },
                  childCount: courses.length,
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
            ] else if (!state.isLoading)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: Text(
                      _query.isEmpty
                          ? 'No courses available yet.'
                          : 'No courses match your search.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CourseGridCard extends ConsumerWidget {
  const _CourseGridCard({required this.course, required this.showBuyButton});

  final Course course;
  final bool showBuyButton;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void openCourseDetail() {
      ref
          .read(recommendationControllerProvider)
          .trackView(course.id, category: course.category);
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => CourseDetailScreen(course: course),
        ),
      );
    }

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: openCourseDetail,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CourseGridThumbnail(course: course),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      course.category,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        if (course.isFree)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.secondary.withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Free',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                    color: AppColors.secondary,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          )
                        else
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${course.price.toStringAsFixed(0)} ETB',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ),
                        const Spacer(),
                        if (showBuyButton)
                          OutlinedButton(
                            onPressed: () {
                              ref.read(cartControllerProvider.notifier).addToCart(course);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Course added to cart')),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 0,
                              ),
                              minimumSize: const Size(0, 28),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              visualDensity: VisualDensity.compact,
                            ),
                            child: const Text('Buy'),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CourseGridThumbnail extends StatelessWidget {
  const _CourseGridThumbnail({required this.course});

  final Course course;

  @override
  Widget build(BuildContext context) {
    final thumbnailUrl = course.thumbnailUrl;

    return Container(
      width: double.infinity,
      height: 120,
      color: AppColors.primary.withValues(alpha: 0.12),
      child: thumbnailUrl == null || thumbnailUrl.isEmpty
          ? const Icon(
              Icons.school_outlined,
              size: 40,
              color: AppColors.primary,
            )
          : CachedNetworkImage(
              imageUrl: thumbnailUrl,
              fit: BoxFit.cover,
              errorWidget: (_, _, _) => const Icon(
                Icons.school_outlined,
                size: 40,
                color: AppColors.primary,
              ),
            ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
