import 'package:flutter_test/flutter_test.dart';

import 'package:educonnect_mobile/presentation/controllers/cart_controller.dart';
import 'package:educonnect_mobile/domain/entities/cart_item.dart';
import 'package:educonnect_mobile/domain/entities/course.dart';
import 'package:educonnect_mobile/domain/repositories/cart_repository.dart';
import 'package:educonnect_mobile/domain/repositories/payment_repository.dart';

class _FakeCartRepo implements CartRepository {
  final List<String> _ids;
  _FakeCartRepo(this._ids);

  @override
  Future<void> addToCart(course) async {}

  @override
  Future<void> clearCart() async {}

  @override
  Future<List<String>> getCartCourseIds() async => _ids;

  @override
  Future<List<CartItem>> getCart() async {
    return _ids
        .map((id) => CartItem(
            courseId: id,
            course: Course(
              id: id,
              title: 'C$id',
              description: 'desc',
              category: 'cat',
              mode: 0,
              status: 0,
              price: 10.0,
              instructor: 'inst',
            )))
        .toList();
  }

  @override
  Future<void> removeFromCart(String courseId) async {}
}

class _FakePaymentRepo implements PaymentRepository {
  @override
  Future<bool> checkPaymentStatus(String transactionId) async => true;

  @override
  Future<bool> processMockPayment(intent) async => true;

  @override
  Future<PaymentIntent> createPaymentIntent({required double amount, required List<CartItem> items, method = PaymentMethod.chapa}) async {
    return PaymentIntent(transactionId: 'tx', checkoutUrl: 'http://checkout', amount: amount, courseId: items.isNotEmpty ? items.first.courseId : null);
  }
}

void main() {
  test('cart loads and computes totals', () async {
    final cartRepo = _FakeCartRepo(['c1', 'c2']);
    final paymentRepo = _FakePaymentRepo();

    final controller = CartController(cartRepository: cartRepo, paymentRepository: paymentRepo);
    // wait for load
    await Future.delayed(const Duration(milliseconds: 50));

    expect(controller.state.isLoading, false);
    expect(controller.state.items.length, 2);
    expect(controller.state.subtotal, 20.0);

    controller.applyPromoCode('EDU10');
    expect(controller.state.promoDiscountPercent, 10);
    expect(controller.state.total, 18.0);

    final success = await controller.checkout();
    expect(success, true);
  });
}
