import '../entities/cart_item.dart';

class PaymentIntent {
  const PaymentIntent({
    required this.transactionId,
    required this.checkoutUrl,
    required this.amount,
    this.courseId,
  });

  final String transactionId;
  final String checkoutUrl;
  final double amount;
  final String? courseId;
}

enum PaymentMethod { chapa, telebirr }

abstract class PaymentRepository {
  Future<PaymentIntent> createPaymentIntent({
    required double amount,
    required List<CartItem> items,
    PaymentMethod method = PaymentMethod.chapa,
  });

  Future<bool> checkPaymentStatus(String transactionId);

  Future<bool> processMockPayment(PaymentIntent intent);
}
