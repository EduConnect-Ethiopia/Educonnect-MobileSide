import 'package:dio/dio.dart';

import '../../../core/config/app_environment.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/utils/json_map.dart';

class PaymentIntentResponse {
  const PaymentIntentResponse({
    required this.paymentId,
    required this.courseId,
    required this.amount,
    required this.status,
    required this.demoPayPath,
    this.enrollmentId,
  });

  final String paymentId;
  final String courseId;
  final double amount;
  final String status;
  final String demoPayPath;
  final String? enrollmentId;

  factory PaymentIntentResponse.fromJson(JsonMap json) {
    final data = findMap(json, const ['data', 'result']) ?? json;
    final demoPath = findString(data, const ['demoPayPath']) ?? '';
    return PaymentIntentResponse(
      paymentId: findString(data, const ['paymentId', 'id']) ?? '',
      courseId: findString(data, const ['courseId']) ?? '',
      amount: _readDouble(data['amount']) ?? 0,
      status: findString(data, const ['status']) ?? 'Pending',
      demoPayPath: demoPath,
      enrollmentId: findString(data, const ['enrollmentId']),
    );
  }

  String get checkoutUrl {
    if (demoPayPath.isEmpty) return '';
    if (demoPayPath.startsWith('http')) return demoPayPath;
    final base = AppEnvironment.apiBaseUrl;
    final path = demoPayPath.startsWith('/') ? demoPayPath : '/$demoPayPath';
    return '$base$path';
  }
}

class PaymentStatusResponse {
  const PaymentStatusResponse({
    required this.isPaid,
    required this.status,
    required this.paymentId,
  });

  final bool isPaid;
  final String status;
  final String paymentId;

  factory PaymentStatusResponse.fromJson(JsonMap json) {
    final data = findMap(json, const ['data', 'result']) ?? json;
    final status = findString(data, const ['status']) ?? '';
    return PaymentStatusResponse(
      isPaid: status.toLowerCase() == 'success',
      status: status,
      paymentId: findString(data, const ['paymentId', 'id']) ?? '',
    );
  }
}

class PaymentApi {
  PaymentApi(this._dio);

  final Dio _dio;

  Future<PaymentIntentResponse> initiatePayment(String courseId) async {
    final response = await _dio.post<dynamic>(
      ApiEndpoints.paymentInitiate,
      data: {'courseId': courseId},
    );
    return PaymentIntentResponse.fromJson(castJsonMap(response.data));
  }

  Future<PaymentStatusResponse> getPayment(String paymentId) async {
    final response = await _dio.get<dynamic>(
      ApiEndpoints.payment(paymentId),
    );
    return PaymentStatusResponse.fromJson(castJsonMap(response.data));
  }

  Future<PaymentStatusResponse> completePayment(
    String paymentId, {
    String outcome = 'Success',
  }) async {
    final response = await _dio.post<dynamic>(
      ApiEndpoints.paymentComplete(paymentId),
      data: {'outcome': outcome},
    );
    return PaymentStatusResponse.fromJson(castJsonMap(response.data));
  }
}

double? _readDouble(Object? value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}
