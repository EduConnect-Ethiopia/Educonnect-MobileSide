import '../../domain/entities/cart_item.dart';
import '../../domain/entities/course.dart';
import '../../domain/repositories/cart_repository.dart';
import '../../domain/repositories/course_repository.dart';
import '../datasources/local/cart_local_data_source.dart';

class CartRepositoryImpl implements CartRepository {
  CartRepositoryImpl({
    required CartLocalDataSource localDataSource,
    required CourseRepository courseRepository,
  })  : _local = localDataSource,
        _courses = courseRepository;

  final CartLocalDataSource _local;
  final CourseRepository _courses;

  @override
  Future<List<CartItem>> getCart() async {
    final ids = await _local.getCartCourseIds();
    final items = <CartItem>[];
    for (final id in ids) {
      try {
        final course = await _courses.getCourseById(id);
        items.add(CartItem(courseId: id, course: course));
      } on Object {
        await _local.removeCourseId(id);
      }
    }
    return items;
  }

  @override
  Future<void> addToCart(Course course) async {
    await _local.addCourseId(course.id);
  }

  @override
  Future<void> removeFromCart(String courseId) async {
    await _local.removeCourseId(courseId);
  }

  @override
  Future<void> clearCart() => _local.clear();

  @override
  Future<List<String>> getCartCourseIds() => _local.getCartCourseIds();
}
