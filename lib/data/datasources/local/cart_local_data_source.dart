
import 'package:shared_preferences/shared_preferences.dart';

class CartLocalDataSource {
  CartLocalDataSource(this._prefs);

  final SharedPreferences _prefs;
  static const _cartKey = 'shopping_cart_ids';

  Future<List<String>> getCartCourseIds() async {
    final raw = _prefs.getStringList(_cartKey);
    return raw ?? [];
  }

  Future<void> saveCartCourseIds(List<String> ids) async {
    await _prefs.setStringList(_cartKey, ids);
  }

  Future<void> addCourseId(String courseId) async {
    final ids = await getCartCourseIds();
    if (!ids.contains(courseId)) {
      ids.add(courseId);
      await saveCartCourseIds(ids);
    }
  }

  Future<void> removeCourseId(String courseId) async {
    final ids = await getCartCourseIds();
    ids.remove(courseId);
    await saveCartCourseIds(ids);
  }

  Future<void> clear() async {
    await _prefs.remove(_cartKey);
  }

  Future<String?> getPromoCode() async {
    return _prefs.getString('cart_promo_code');
  }

  Future<void> savePromoCode(String? code) async {
    if (code == null || code.isEmpty) {
      await _prefs.remove('cart_promo_code');
    } else {
      await _prefs.setString('cart_promo_code', code);
    }
  }

  Future<double> getPromoDiscountPercent() async {
    final code = await getPromoCode();
    if (code == null) return 0;
    final upper = code.toUpperCase();
    if (upper == 'EDU10') return 10;
    if (upper == 'LEARN20') return 20;
    return 0;
  }
}
