import 'package:get/get.dart';
import 'package:uniqkids_suarakita/models/database.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart' as drift;

class CategoryController extends GetxController {
  final AppDatabase db;
  final _uuid = const Uuid();

  var categories = <Category>[].obs;

  CategoryController(this.db);

  @override
  void onInit() {
    super.onInit();
    loadCategories();
  }

  Future<void> loadCategories() async {
    final data = await db.select(db.categories).get();
    categories.assignAll(data);
  }

  Future<void> addCategory(String name, String? parentId, int level) async {
    final categoryCompanion = CategoriesCompanion.insert(
      id: _uuid.v4(),
      name: name,
      parentId: drift.Value(parentId),
      level: level,
    );

    await db.into(db.categories).insert(categoryCompanion);
    await loadCategories();
  }

  Future<void> deleteCategory(String categoryId) async {
    await (db.delete(db.categories)
          ..where((tbl) => tbl.id.equals(categoryId)))
        .go();

    await loadCategories();
  }

  List<Category> getCategoriesByLevel(int level) {
    return categories.where((cat) => cat.level == level).toList();
  }

  List<Category> getChildCategories(String parentId) {
    return categories.where((cat) => cat.parentId == parentId).toList();
  }

  Category? getCategoryById(String id) {
    try {
      return categories.firstWhere((cat) => cat.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Category> getAllowedParentCategories(int level) {
    if (level == 1) return [];
    return getCategoriesByLevel(level - 1);
  }
}