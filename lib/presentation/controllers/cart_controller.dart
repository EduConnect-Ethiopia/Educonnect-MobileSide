import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:state_notifier/state_notifier.dart';

import '../../domain/entities/cart_item.dart';
import '../../domain/repositories/cart_repository.dart';
import '../../domain/repositories/payment_repository.dart';

class CartState {
  const CartState({
    this.isLoading = true,
    this.isProcessing = false,
    this.items = const [],
    this.paymentMethod = PaymentMethod.chapa,
    this.promoDiscountPercent = 0,
  });

  final bool isLoading;
  final bool isProcessing;
  final List<CartItem> items;
  final PaymentMethod paymentMethod;
  final double promoDiscountPercent;

  bool get isEmpty => items.isEmpty;
  double get subtotal => items.fold(0.0, (p, e) => p + e.price);
  double get discountAmount => subtotal * (promoDiscountPercent / 100);
  double get total => subtotal - discountAmount;
}

class CartController extends StateNotifier<CartState> {
  CartController({
    required CartRepository cartRepository,
    required PaymentRepository paymentRepository,
  })  : _cartRepository = cartRepository,
        _paymentRepository = paymentRepository,
        super(const CartState()) {
    _load();
  }

  final CartRepository _cartRepository;
  final PaymentRepository _paymentRepository;

  Future<void> _load() async {
    state = CartState(isLoading: true, items: state.items);
    final items = await _cartRepository.getCart();
    state = CartState(isLoading: false, items: items, paymentMethod: state.paymentMethod, promoDiscountPercent: state.promoDiscountPercent);
  }

  Future<void> removeFromCart(String courseId) async {
    await _cartRepository.removeFromCart(courseId);
    await _load();
  }

  void applyPromoCode(String code) {
    // Example simple promo rules
    final percent = _promoForCode(code);
    state = CartState(
      isLoading: state.isLoading,
      isProcessing: state.isProcessing,
      items: state.items,
      paymentMethod: state.paymentMethod,
      promoDiscountPercent: percent,
    );
  }

  void setPaymentMethod(PaymentMethod method) {
    state = CartState(
      isLoading: state.isLoading,
      isProcessing: state.isProcessing,
      items: state.items,
      paymentMethod: method,
      promoDiscountPercent: state.promoDiscountPercent,
    );
  }

  Future<bool> checkout({PaymentMethod? method}) async {
    if (state.items.isEmpty) return false;
    state = CartState(
      isLoading: state.isLoading,
      isProcessing: true,
      items: state.items,
      paymentMethod: method ?? state.paymentMethod,
      promoDiscountPercent: state.promoDiscountPercent,
    );

    try {
      final intent = await _paymentRepository.createPaymentIntent(
        amount: state.total,
        items: state.items,
        method: state.paymentMethod,
      );

      // For this controller we just return whether a checkout URL exists.
      final success = intent.checkoutUrl.isNotEmpty;
      state = CartState(
        isLoading: false,
        isProcessing: false,
        items: state.items,
        paymentMethod: state.paymentMethod,
        promoDiscountPercent: state.promoDiscountPercent,
      );
      return success;
    } catch (e) {
      state = CartState(
        isLoading: false,
        isProcessing: false,
        items: state.items,
        paymentMethod: state.paymentMethod,
        promoDiscountPercent: state.promoDiscountPercent,
      );
      return false;
    }
  }

  double _promoForCode(String code) {
    final c = code.toUpperCase();
    if (c == 'EDU10') return 10; // 10%
    if (c == 'LEARN20') return 20; // 20%
    return 0;
  }
}
