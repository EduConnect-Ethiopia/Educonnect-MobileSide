import 'package:dio/dio.dart';

import '../../../core/constants/api_endpoints.dart';
import '../../../core/utils/json_map.dart';
import '../../models/assessment_models.dart';

abstract class AssessmentRemoteDataSource {
  Future<List<AssessmentSummaryDto>> getAssessmentsByCourse(String courseId);
  Future<AssessmentSummaryDto?> getAssessment(String assessmentId);
  Future<List<AssessmentQuestionDto>> getQuestions(String assessmentId);
  Future<void> startAssessment(String assessmentId);
  Future<SubmissionResultDto> submitAssessment({
    required String assessmentId,
    required Map<String, String> answers,
    String content = '',
  });
}

class DioAssessmentRemoteDataSource implements AssessmentRemoteDataSource {
  const DioAssessmentRemoteDataSource(this._dio);

  final Dio _dio;

  @override
  Future<List<AssessmentSummaryDto>> getAssessmentsByCourse(
    String courseId,
  ) async {
    final response = await _dio.get<dynamic>(
      ApiEndpoints.assessmentsByCourse(courseId),
    );
    return _mapAssessmentList(response.data);
  }

  @override
  Future<AssessmentSummaryDto?> getAssessment(String assessmentId) async {
    final response = await _dio.get<dynamic>(
      ApiEndpoints.assessment(assessmentId),
    );
    if (response.data == null) return null;
    return AssessmentSummaryDto.fromJson(castJsonMap(response.data));
  }

  @override
  Future<List<AssessmentQuestionDto>> getQuestions(String assessmentId) async {
    final response = await _dio.get<dynamic>(
      ApiEndpoints.assessmentQuestions(assessmentId),
    );
    final list = _unwrapList(response.data);
    final questions = list
        .map((json) => AssessmentQuestionDto.fromJson(castJsonMap(json)))
        .toList()
      ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
    return questions;
  }

  @override
  Future<void> startAssessment(String assessmentId) async {
    await _dio.post<dynamic>(ApiEndpoints.startAssessment(assessmentId));
  }

  @override
  Future<SubmissionResultDto> submitAssessment({
    required String assessmentId,
    required Map<String, String> answers,
    String content = '',
  }) async {
    final response = await _dio.post<dynamic>(
      ApiEndpoints.submitAssessment,
      data: {
        'assessmentId': assessmentId,
        'answers': answers,
        'content': content,
      },
    );
    return SubmissionResultDto.fromJson(castJsonMap(response.data));
  }

  List<AssessmentSummaryDto> _mapAssessmentList(Object? value) {
    return _unwrapList(value)
        .map((json) => AssessmentSummaryDto.fromJson(castJsonMap(json)))
        .where((a) => _isPublished(a.status))
        .toList();
  }

  bool _isPublished(String status) {
    final normalized = status.toLowerCase();
    return normalized.isEmpty ||
        normalized.contains('published') ||
        normalized == '1';
  }

  List<Map<String, dynamic>> _unwrapList(Object? value) {
    if (value is List) {
      return value.whereType<Map<String, dynamic>>().toList();
    }
    if (value is Map) {
      final map = castJsonMap(value);
      final data = map['data'];
      if (data is List) {
        return data.whereType<Map<String, dynamic>>().toList();
      }
    }
    return const [];
  }
}
