import 'package:dio/dio.dart';

import '../../domain/entities/cart_item.dart';
import '../../domain/repositories/payment_repository.dart';
import '../datasources/remote/payment_api.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  PaymentRepositoryImpl({required PaymentApi paymentApi})
      : _api = paymentApi;

  final PaymentApi _api;

  @override
  Future<PaymentIntent> createPaymentIntent({
    required double amount,
    required List<CartItem> items,
    PaymentMethod method = PaymentMethod.chapa,
  }) async {
    if (items.isEmpty) {
      throw StateError('Cart is empty');
    }

    final courseId = items.first.courseId;
    final response = await _api.initiatePayment(courseId);
    return PaymentIntent(
      transactionId: response.paymentId,
      checkoutUrl: response.checkoutUrl,
      amount: response.amount > 0 ? response.amount : amount,
      courseId: response.courseId.isNotEmpty ? response.courseId : courseId,
    );
  }

  @override
  Future<bool> checkPaymentStatus(String transactionId) async {
    try {
      final status = await _api.getPayment(transactionId);
      return status.isPaid;
    } on DioException {
      return false;
    }
  }

  Future<bool> completeDemoPayment(String paymentId) async {
    try {
      final result = await _api.completePayment(paymentId);
      return result.isPaid;
    } on Object {
      return false;
    }
  }

  @override
  Future<bool> processMockPayment(PaymentIntent intent) async {
    if (intent.transactionId.isEmpty) return false;
    return completeDemoPayment(intent.transactionId);
  }
}
