import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/cart_item.dart';
import '../../../domain/repositories/payment_repository.dart';
import '../../providers/cart_provider.dart';
import '../main_navigation_screen.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  final _promoController = TextEditingController();

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My Cart')),
      body: cart.isLoading
          ? const Center(child: CircularProgressIndicator())
          : cart.isEmpty
              ? _buildEmptyCart(context)
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: cart.items.length,
                        itemBuilder: (context, index) {
                          final item = cart.items[index];
                          return _buildCartItem(context, item, cart);
                        },
                      ),
                    ),
                    _buildPromoSection(cart),
                    _buildCheckoutSection(context, cart),
                  ],
                ),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE0E0E0)),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.shopping_cart_outlined, size: 48),
              SizedBox(height: 16),
              Text(
                'Cart is empty',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
              ),
              SizedBox(height: 6),
              Text('Add paid courses from Browse to checkout.'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCartItem(
    BuildContext context,
    CartItem item,
    CartState cart,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(item.course.title),
        subtitle: Text('${item.course.price.toStringAsFixed(2)} ETB'),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: () => ref
              .read(cartControllerProvider.notifier)
              .removeFromCart(item.courseId),
        ),
      ),
    );
  }

  Widget _buildPromoSection(CartState cart) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _promoController,
              decoration: const InputDecoration(
                hintText: 'Promo code (EDU10, LEARN20)',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: () {
              ref
                  .read(cartControllerProvider.notifier)
                  .applyPromoCode(_promoController.text.trim());
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckoutSection(BuildContext context, CartState cart) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: const [
          BoxShadow(blurRadius: 4, color: Colors.black12),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Subtotal'),
              Text('${cart.subtotal.toStringAsFixed(2)} ETB'),
            ],
          ),
          if (cart.promoDiscountPercent > 0) ...[
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Discount (${cart.promoDiscountPercent.toStringAsFixed(0)}%)'),
                Text('-${cart.discountAmount.toStringAsFixed(2)} ETB'),
              ],
            ),
          ],
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                '${cart.total.toStringAsFixed(2)} ETB',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SegmentedButton<PaymentMethod>(
            segments: const [
              ButtonSegment(
                value: PaymentMethod.chapa,
                label: Text('Chapa'),
              ),
              ButtonSegment(
                value: PaymentMethod.telebirr,
                label: Text('Telebirr'),
              ),
            ],
            selected: {cart.paymentMethod},
            onSelectionChanged: (methods) {
              ref
                  .read(cartControllerProvider.notifier)
                  .setPaymentMethod(methods.first);
            },
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: cart.isProcessing ? null : () => _checkout(context),
              child: cart.isProcessing
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Proceed to Checkout'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _checkout(BuildContext context) async {
    final cart = ref.read(cartControllerProvider);
    final success = await ref.read(cartControllerProvider.notifier).checkout(
          method: cart.paymentMethod,
        );

    if (!context.mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Purchase successful! Enrolling in courses...'),
        ),
      );
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(builder: (_) => const MainNavigationScreen()),
        (_) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment failed. Please try again.')),
      );
    }
  }
}
