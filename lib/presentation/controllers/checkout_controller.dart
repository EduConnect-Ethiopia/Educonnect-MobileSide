import '../../domain/repositories/cart_repository.dart';
import '../../domain/repositories/payment_repository.dart';

class CheckoutController {
  CheckoutController({
    required this.paymentRepository,
    required this.cartRepository,
  });

  final PaymentRepository paymentRepository;
  final CartRepository cartRepository;

  Future<PaymentIntent> createPaymentIntent({PaymentMethod method = PaymentMethod.chapa}) async {
    final items = await cartRepository.getCart();
    final amount = items.fold<double>(0, (p, e) => p + e.price);
    return paymentRepository.createPaymentIntent(amount: amount, items: items, method: method);
  }

  Future<bool> checkPaymentStatus(String transactionId) async {
    return paymentRepository.checkPaymentStatus(transactionId);
  }
}
