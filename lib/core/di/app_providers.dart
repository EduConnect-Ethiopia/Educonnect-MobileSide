import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/datasources/auth_remote_data_source.dart';
import '../../data/datasources/file_access_remote_data_source.dart';
import '../../data/datasources/course_remote_data_source.dart';
import '../../data/datasources/enrollment_remote_data_source.dart';
import '../../data/datasources/local/cart_local_data_source.dart';
import '../../data/datasources/local/course_cache_local_data_source.dart';
import '../../data/datasources/local/progress_local_data_source.dart';
import '../../data/datasources/remote/assessment_remote_data_source.dart';
import '../../data/datasources/remote/certificate_remote_data_source.dart';
import '../../data/datasources/remote/notification_remote_data_source.dart';
import '../../data/datasources/remote/payment_api.dart';
import '../../data/datasources/remote/progress_remote_data_source.dart';
import '../../data/datasources/remote/recommendation_remote_data_source.dart';
import '../../data/datasources/session_remote_data_source.dart';
import '../../data/repositories/assessment_repository_impl.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/file_access_repository_impl.dart';
import '../../data/repositories/cart_repository_impl.dart';
import '../../data/repositories/certificate_repository_impl.dart';
import '../../data/repositories/course_repository_impl.dart';
import '../../data/repositories/enrollment_repository_impl.dart';
import '../../data/repositories/notification_repository_impl.dart';
import '../../data/repositories/payment_repository_impl.dart';
import '../../data/repositories/progress_repository_impl.dart';
import '../../data/repositories/recommendation_repository_impl.dart';
import '../../data/services/material_file_cache_service.dart';
import '../../domain/repositories/assessment_repository.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/file_access_repository.dart';
import '../../domain/repositories/cart_repository.dart';
import '../../domain/repositories/certificate_repository.dart';
import '../../domain/repositories/course_repository.dart';
import '../../domain/repositories/enrollment_repository.dart';
import '../../domain/repositories/notification_repository.dart';
import '../../domain/repositories/payment_repository.dart';
import '../../domain/repositories/progress_repository.dart';
import '../../domain/repositories/recommendation_repository.dart';
import '../../presentation/controllers/checkout_controller.dart';
import '../network/dio_client.dart';
import '../storage/token_storage.dart';
import '../../presentation/providers/auth_controller.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'SharedPreferences must be provided during app bootstrap.',
  );
});

final tokenStorageProvider = Provider<TokenStorage>((ref) {
  return TokenStorage(ref.watch(sharedPreferencesProvider));
});

final dioProvider = Provider<Dio>((ref) {
  return DioClient.create(
    tokenStorage: ref.watch(tokenStorageProvider),
    onSessionExpired: () {
      ref.read(authControllerProvider.notifier).markSessionExpired();
    },
  );
});

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return DioAuthRemoteDataSource(ref.watch(dioProvider));
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    remoteDataSource: ref.watch(authRemoteDataSourceProvider),
    tokenStorage: ref.watch(tokenStorageProvider),
  );
});

final courseRemoteDataSourceProvider = Provider<CourseRemoteDataSource>((ref) {
  return DioCourseRemoteDataSource(ref.watch(dioProvider));
});

final courseCacheLocalDataSourceProvider =
    Provider<CourseCacheLocalDataSource>((ref) {
  return CourseCacheLocalDataSource();
});

final courseRepositoryProvider = Provider<CourseRepository>((ref) {
  return CourseRepositoryImpl(
    remoteDataSource: ref.watch(courseRemoteDataSourceProvider),
    localDataSource: ref.watch(courseCacheLocalDataSourceProvider),
  );
});

final fileAccessRemoteDataSourceProvider =
    Provider<FileAccessRemoteDataSource>((ref) {
  return DioFileAccessRemoteDataSource(ref.watch(dioProvider));
});

final fileAccessRepositoryProvider = Provider<FileAccessRepository>((ref) {
  return FileAccessRepositoryImpl(
    remoteDataSource: ref.watch(fileAccessRemoteDataSourceProvider),
  );
});

final enrollmentRemoteDataSourceProvider =
    Provider<EnrollmentRemoteDataSource>((ref) {
  return DioEnrollmentRemoteDataSource(ref.watch(dioProvider));
});

final enrollmentRepositoryProvider = Provider<EnrollmentRepository>((ref) {
  return EnrollmentRepositoryImpl(
    remoteDataSource: ref.watch(enrollmentRemoteDataSourceProvider),
  );
});

final sessionRemoteDataSourceProvider = Provider<SessionRemoteDataSource>((ref) {
  return DioSessionRemoteDataSource(ref.watch(dioProvider));
});

final appStartupProvider = FutureProvider<bool>((ref) {
  return ref.watch(authRepositoryProvider).isAuthenticated();
});

final progressLocalDataSourceProvider = Provider<ProgressLocalDataSource>((ref) {
  return ProgressLocalDataSource(ref.watch(sharedPreferencesProvider));
});

final progressRemoteDataSourceProvider =
    Provider<ProgressRemoteDataSource>((ref) {
  return DioProgressRemoteDataSource(ref.watch(dioProvider));
});

final progressRepositoryProvider = Provider<ProgressRepository>((ref) {
  return ProgressRepositoryImpl(
    ref.watch(progressRemoteDataSourceProvider),
    ref.watch(progressLocalDataSourceProvider),
  );
});

final cartLocalDataSourceProvider = Provider<CartLocalDataSource>((ref) {
  return CartLocalDataSource(ref.watch(sharedPreferencesProvider));
});

final cartRepositoryProvider = Provider<CartRepository>((ref) {
  return CartRepositoryImpl(
    localDataSource: ref.watch(cartLocalDataSourceProvider),
    courseRepository: ref.watch(courseRepositoryProvider),
  );
});

final materialFileCacheServiceProvider = Provider<MaterialFileCacheService>((ref) {
  return MaterialFileCacheService(
    dio: ref.watch(dioProvider),
    cache: ref.watch(courseCacheLocalDataSourceProvider),
  );
});

final paymentApiProvider = Provider<PaymentApi>((ref) {
  return PaymentApi(ref.watch(dioProvider));
});

final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  return PaymentRepositoryImpl(paymentApi: ref.watch(paymentApiProvider));
});

final checkoutControllerProvider = Provider.autoDispose((ref) {
  return CheckoutController(
    paymentRepository: ref.watch(paymentRepositoryProvider),
    cartRepository: ref.watch(cartRepositoryProvider),
  );
});

final certificateRemoteDataSourceProvider =
    Provider<CertificateRemoteDataSource>((ref) {
  return DioCertificateRemoteDataSource(ref.watch(dioProvider));
});

final certificateRepositoryProvider = Provider<CertificateRepository>((ref) {
  return CertificateRepositoryImpl(
    remoteDataSource: ref.watch(certificateRemoteDataSourceProvider),
    courseRepository: ref.watch(courseRepositoryProvider),
    authRepository: ref.watch(authRepositoryProvider),
  );
});

final assessmentRemoteDataSourceProvider =
    Provider<AssessmentRemoteDataSource>((ref) {
  return DioAssessmentRemoteDataSource(ref.watch(dioProvider));
});

final assessmentRepositoryProvider = Provider<AssessmentRepository>((ref) {
  return AssessmentRepositoryImpl(ref.watch(assessmentRemoteDataSourceProvider));
});

final notificationRemoteDataSourceProvider =
    Provider<NotificationRemoteDataSource>((ref) {
  return DioNotificationRemoteDataSource(ref.watch(dioProvider));
});

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepositoryImpl(
    ref.watch(notificationRemoteDataSourceProvider),
  );
});

final recommendationRemoteDataSourceProvider =
    Provider<RecommendationRemoteDataSource>((ref) {
  return DioRecommendationRemoteDataSource(ref.watch(dioProvider));
});

final recommendationRepositoryProvider =
    Provider<RecommendationRepository>((ref) {
  return RecommendationRepositoryImpl(
    ref.watch(recommendationRemoteDataSourceProvider),
  );
});
