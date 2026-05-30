import 'course.dart';

class CartItem {
  const CartItem({
    required this.courseId,
    required this.course,
    this.promoApplied = false,
  });

  final String courseId;
  final Course course;
  final bool promoApplied;

  double get price => course.price;
}
