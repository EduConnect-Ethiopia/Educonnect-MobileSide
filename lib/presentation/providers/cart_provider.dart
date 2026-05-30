import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/di/app_providers.dart';
import '../../data/datasources/local/cart_local_data_source.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/entities/course.dart';
import '../../domain/repositories/payment_repository.dart';
import '../providers/enrollment_provider.dart';

final cartControllerProvider =
    NotifierProvider<CartController, CartState>(CartController.new);

class CartController extends Notifier<CartState> {
  CartLocalDataSource get _local => ref.read(cartLocalDataSourceProvider);

  @override
  CartState build() {
    Future.microtask(loadCart);
    return CartState.initial();
  }

  Future<void> loadCart() async {
    state = state.copyWith(isLoading: true);
    final items = await ref.read(cartRepositoryProvider).getCart();
    final discount = await _local.getPromoDiscountPercent();
    state = state.copyWith(
      isLoading: false,
      items: items,
      promoDiscountPercent: discount,
    );
  }

  Future<void> addToCart(Course course) async {
    if (state.items.any((item) => item.courseId == course.id)) return;
    await ref.read(cartRepositoryProvider).addToCart(course);
    state = state.copyWith(
      items: [...state.items, CartItem(courseId: course.id, course: course)],
    );
  }

  Future<void> removeFromCart(String courseId) async {
    await ref.read(cartRepositoryProvider).removeFromCart(courseId);
    state = state.copyWith(
      items: state.items.where((i) => i.courseId != courseId).toList(),
    );
  }

  void setPaymentMethod(PaymentMethod method) {
    state = state.copyWith(paymentMethod: method);
  }

  Future<void> applyPromoCode(String code) async {
    await _local.savePromoCode(code);
    final discount = await _local.getPromoDiscountPercent();
    state = state.copyWith(promoCode: code, promoDiscountPercent: discount);
  }

  Future<bool> checkout({PaymentMethod method = PaymentMethod.chapa}) async {
    if (state.items.isEmpty) return false;

    state = state.copyWith(isProcessing: true);
    final paymentRepo = ref.read(paymentRepositoryProvider);
    final enrollmentRepo = ref.read(enrollmentRepositoryProvider);
    
    final successfulCourseIds = <String>[];
    bool hasFailure = false;

    for (final item in state.items) {
      try {
        if (item.course.isFree) {
          await enrollmentRepo.enroll(item.courseId);
          successfulCourseIds.add(item.courseId);
          continue;
        }

        final intent = await paymentRepo.createPaymentIntent(
          amount: item.course.price,
          items: [item],
          method: method,
        );

        final paid = await paymentRepo.processMockPayment(intent);
        if (paid) {
          successfulCourseIds.add(item.courseId);
        } else {
          hasFailure = true;
        }
      } catch (e) {
        hasFailure = true;
      }
    }

    // Remove successful items from the cart
    for (final courseId in successfulCourseIds) {
      await ref.read(cartRepositoryProvider).removeFromCart(courseId);
    }

    if (successfulCourseIds.isNotEmpty) {
      ref.invalidate(myEnrollmentsProvider);
      ref.invalidate(myCoursesProvider);
    }

    final remainingItems = state.items
        .where((item) => !successfulCourseIds.contains(item.courseId))
        .toList();

    state = state.copyWith(items: remainingItems, isProcessing: false);

    return successfulCourseIds.isNotEmpty && !hasFailure;
  }
}

class CartState {
  const CartState({
    required this.items,
    required this.isLoading,
    required this.isProcessing,
    required this.promoCode,
    required this.promoDiscountPercent,
    required this.paymentMethod,
  });

  const CartState.initial()
      : items = const [],
        isLoading = false,
        isProcessing = false,
        promoCode = null,
        promoDiscountPercent = 0,
        paymentMethod = PaymentMethod.chapa;

  final List<CartItem> items;
  final bool isLoading;
  final bool isProcessing;
  final String? promoCode;
  final double promoDiscountPercent;
  final PaymentMethod paymentMethod;

  double get subtotal =>
      items.fold(0.0, (sum, item) => sum + item.course.price);

  double get discountAmount => subtotal * (promoDiscountPercent / 100);

  double get total => subtotal - discountAmount;

  bool get isEmpty => items.isEmpty;

  int get itemCount => items.length;

  CartState copyWith({
    List<CartItem>? items,
    bool? isLoading,
    bool? isProcessing,
    String? promoCode,
    double? promoDiscountPercent,
    PaymentMethod? paymentMethod,
  }) {
    return CartState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      isProcessing: isProcessing ?? this.isProcessing,
      promoCode: promoCode ?? this.promoCode,
      promoDiscountPercent:
          promoDiscountPercent ?? this.promoDiscountPercent,
      paymentMethod: paymentMethod ?? this.paymentMethod,
    );
  }
}
