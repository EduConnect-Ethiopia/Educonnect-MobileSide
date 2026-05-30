import '../entities/cart_item.dart';
import '../entities/course.dart';

abstract class CartRepository {
  Future<List<CartItem>> getCart();
  Future<void> addToCart(Course course);
  Future<void> removeFromCart(String courseId);
  Future<void> clearCart();
  Future<List<String>> getCartCourseIds();
}
