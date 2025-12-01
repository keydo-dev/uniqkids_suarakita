import 'package:get/get.dart';
import 'package:SuaraKita/controllers/languages_controller.dart';
import 'package:SuaraKita/models/database.dart';
import 'package:SuaraKita/services/audio_services.dart';
import 'package:SuaraKita/utils/asset_helper.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart' as drift;

class CardController extends GetxController {
  final AppDatabase db;
  final _uuid = const Uuid();
  final _audioService = Get.find<AudioService>();
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
    bool isAsset = false,
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
      isAsset: drift.Value(isAsset),
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

  // Toggle card selection
  void toggleCardSelection(Card card) {
    if (selectedCards.contains(card)) {
      selectedCards.remove(card);
    } else {
      selectedCards.add(card);
    }
  }

  // Hapus kartu dari daftar terpilih
  void removeCard(Card card) {
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

    final resolvedSoundPaths = <String>[];
    for (final card in selectedCards) {
      final originalPath = langController.currentLanguage.value == 'en'
          ? card.enSoundPath
          : card.soundPath;
      final resolvedPath = await AssetHelper.getSound(originalPath);
      resolvedSoundPaths.add(resolvedPath);
    }

    if (resolvedSoundPaths.isNotEmpty) {
      await _audioService.playMultipleFiles(resolvedSoundPaths);
    }
  }

  // Hapus semua kartu yang terpilih
  void clearSelection() {
    selectedCards.clear();
  }

  // Stream untuk ambil kartu berdasarkan kategori
  Stream<List<Card>> watchCardsByCategoryId(String categoryId) {
    return (db.select(db.cards)..where((tbl) => tbl.categoryId.equals(categoryId))).watch();
  }

  // Stream untuk ambil kartu beserta kategorinya
  Stream<List<CardWithCategory>> watchCardsWithCategories() {
    return db.watchCardsWithCategories();
  }
}
