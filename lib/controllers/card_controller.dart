import 'package:get/get.dart';
import 'package:uniqkids_suarakita/controllers/languages_controller.dart';
import 'package:uniqkids_suarakita/models/database.dart';
import 'package:uniqkids_suarakita/services/audio_services.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart' as drift;

class CardController extends GetxController {
  final AppDatabase db;
  final _uuid = const Uuid();
  final _audioService = AudioService();
  final langController = Get.find<LanguagesController>();

  var cards = <Card>[].obs;
  var selectedCards = <Card>[].obs;
  var isTextMode = false.obs;

  CardController(this.db);

  @override
  void onInit() {
    super.onInit();
    loadCards();
  }

  // Load semua kartu dari database
  Future<void> loadCards() async {
    final allCards = await db.select(db.cards).get();
    cards.assignAll(allCards);
  }

  // Tambah kartu baru
  Future<void> addCard({
    required String name,
    required String categoryId,
    String? enName,
    String? imagePath,
    String? soundPath,
    String? enSoundPath,
  }) async {
    final cardCompanion = CardsCompanion.insert(
      id: _uuid.v4(),
      name: name,
      enName: drift.Value(enName),
      categoryId: categoryId,
      imagePath: drift.Value(imagePath),
      soundPath: drift.Value(soundPath),
      enSoundPath: drift.Value(enSoundPath),
      createdAt: DateTime.now(),
    );

    await db.into(db.cards).insert(cardCompanion);
    await loadCards();
  }

  // Hapus kartu berdasarkan ID
  Future<void> deleteCard(String cardId) async {
    await (db.delete(db.cards)..where((tbl) => tbl.id.equals(cardId))).go();
    await loadCards();
  }

  // Ambil semua kartu berdasarkan kategori
  Future<List<Card>> getCardsByCategory(String categoryId) async {
    return await (db.select(db.cards)
      ..where((tbl) => tbl.categoryId.equals(categoryId)))
      .get();
  }

  // Tambahkan kartu ke daftar terpilih
  void addToSelected(Card card) {
    if (!selectedCards.contains(card)) {
      selectedCards.add(card);
    }
  }

  // Hapus kartu dari daftar terpilih
  void removeFromSelected(Card card) {
    selectedCards.remove(card);
  }

  // Reorder posisi kartu di daftar terpilih
  void reorderSelectedCards(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex--;
    final card = selectedCards.removeAt(oldIndex);
    selectedCards.insert(newIndex, card);
  }

  // Ganti mode tampilan teks/gambar
  void toggleViewMode() {
    isTextMode.value = !isTextMode.value;
  }

  // Putar suara dari semua kartu terpilih
  Future<void> playSelectedCards() async {
    if (selectedCards.isEmpty) return;

    final soundPaths = selectedCards.map((card) {
      if (langController.currentLanguage.value == 'en') {
        return card.enSoundPath;
      } else {
        return card.soundPath;
      }
    }).where((path) => path != null && path.isNotEmpty).map((path) => path!).toList();

    if (soundPaths.isNotEmpty) {
      await _audioService.playMultipleFiles(soundPaths);
    }
  }

  // Hapus semua kartu yang terpilih
  void clearSelection() {
    selectedCards.clear();
  }

  // Stream untuk ambil kartu beserta kategorinya
  Stream<List<CardWithCategory>> watchCardsWithCategories() {
    return db.watchCardsWithCategories();
  }
}
