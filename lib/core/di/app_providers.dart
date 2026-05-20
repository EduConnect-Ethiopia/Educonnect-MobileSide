import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/datasources/auth_remote_data_source.dart';
import '../../data/datasources/course_remote_data_source.dart';
import '../../data/datasources/enrollment_remote_data_source.dart';
import '../../data/datasources/session_remote_data_source.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/course_repository_impl.dart';
import '../../data/repositories/enrollment_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/course_repository.dart';
import '../../domain/repositories/enrollment_repository.dart';
import '../network/dio_client.dart';
import '../storage/token_storage.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'SharedPreferences must be provided during app bootstrap.',
  );
});

final tokenStorageProvider = Provider<TokenStorage>((ref) {
  return TokenStorage(ref.watch(sharedPreferencesProvider));
});

final dioProvider = Provider<Dio>((ref) {
  return DioClient.create(tokenStorage: ref.watch(tokenStorageProvider));
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

final courseRepositoryProvider = Provider<CourseRepository>((ref) {
  return CourseRepositoryImpl(
    remoteDataSource: ref.watch(courseRemoteDataSourceProvider),
  );
});

final enrollmentRemoteDataSourceProvider = Provider<EnrollmentRemoteDataSource>((ref) {
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
