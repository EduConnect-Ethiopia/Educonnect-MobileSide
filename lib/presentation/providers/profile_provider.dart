import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/backend_enum_values.dart';
import '../../core/di/app_providers.dart';
import '../../data/datasources/local/profile_local_data_source.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/entities/course.dart';
import 'enrollment_provider.dart';

class ProfileStats {
  const ProfileStats({
    required this.coursesCompleted,
    required this.certificatesEarned,
    required this.learningHours,
  });

  final int coursesCompleted;
  final int certificatesEarned;
  final int learningHours;
}

class LearnerProfile {
  const LearnerProfile({
    required this.user,
    required this.phone,
    required this.bio,
    required this.stats,
    this.isVerified = true,
  });

  final AuthenticatedUser user;
  final String phone;
  final String bio;
  final ProfileStats stats;
  final bool isVerified;
}

final profileLocalDataSourceProvider = Provider<ProfileLocalDataSource>((ref) {
  return ProfileLocalDataSource(ref.watch(sharedPreferencesProvider));
});

final profileProvider = FutureProvider<LearnerProfile?>((ref) async {
  final user = await ref.watch(authRepositoryProvider).getCurrentUser();
  if (user == null) return null;

  final local = ref.watch(profileLocalDataSourceProvider);
  final phone = await local.getPhone() ?? '';
  final bio = await local.getBio() ?? '';

  final enrollments = await ref.watch(enrollmentRepositoryProvider).getMyEnrollments();
  final completedCourses = enrollments
      .where((e) => e.status == BackendEnumValues.enrollmentCompleted)
      .length;

  final certificates =
      await ref.watch(certificateRepositoryProvider).getCertificates();

  return LearnerProfile(
    user: user,
    phone: phone,
    bio: bio,
    stats: ProfileStats(
      coursesCompleted: completedCourses,
      certificatesEarned: certificates.length,
      learningHours: completedCourses * 4,
    ),
    isVerified: true,
  );
});

final profileCoursesForAssessmentsProvider =
    FutureProvider<List<Course>>((ref) {
  return ref.watch(myCoursesProvider.future);
});
