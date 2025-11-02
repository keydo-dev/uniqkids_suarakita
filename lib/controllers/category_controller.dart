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

  // Stream kategori (untuk StreamBuilder)
  Stream<List<Category>> watchCategories() {
    return db.select(db.categories).watch();
  }

  // Load semua kategori dari database
  Future<void> loadCategories() async {
    final data = await db.select(db.categories).get();
    categories.assignAll(data);
  }

  // Tambah kategori baru (pakai nama Indonesia, nama Inggris, warna, dan parent opsional)
  Future<void> addCategory(
    String name,
    int color, {
    String? enName,
    String? parentId,
  }) async {
    final categoryCompanion = CategoriesCompanion.insert(
      id: _uuid.v4(),
      name: name,
      enName: drift.Value(enName),
      parentId: drift.Value(parentId),
      imagePath: const drift.Value(null),
      color: drift.Value(color),
    );

    await db.into(db.categories).insert(categoryCompanion);
    await loadCategories();
  }

  // Hapus kategori berdasarkan ID
  Future<void> deleteCategory(String categoryId) async {
    await (db.delete(db.categories)..where((tbl) => tbl.id.equals(categoryId))).go();
    await loadCategories();
  }

  // Ambil kategori anak dari parent tertentu
  List<Category> getChildCategories(String parentId) {
    return categories.where((cat) => cat.parentId == parentId).toList();
  }

  // Ambil kategori utama (yang tidak punya parent)
  List<Category> getRootCategories() {
    return categories.where((cat) => cat.parentId == null).toList();
  }

  // Cari kategori berdasarkan ID
  Category? getCategoryById(String id) {
    try {
      return categories.firstWhere((cat) => cat.id == id);
    } catch (e) {
      return null;
    }
  }
}
