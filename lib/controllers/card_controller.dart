import 'package:get/get.dart';
import 'package:uniqkids_suarakita/models/database.dart';
import 'package:uniqkids_suarakita/services/audio_services.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart' as drift;

class CardController extends GetxController {
  final AppDatabase db;
  final _uuid = Uuid();
  final _audioService = AudioService();

  var cards = <Card>[].obs; // pakai tipe dari Drift
  var selectedCards = <Card>[].obs;
  var isTextMode = false.obs;

  CardController(this.db);

  @override
  void onInit() {
    super.onInit();
    loadCards();
  }

  Future<void> loadCards() async {
    final allCards = await db.select(db.cards).get();
    cards.assignAll(allCards);
  }

  //add card
  Future<void> addCard({
    required String name,
    required String categoryId,
    String? imagePath,
    String? soundPath,
  }) async {
    final cardCompanion = CardsCompanion.insert(
      id: _uuid.v4(),
      name: name,
      categoryId: categoryId,
      imagePath: drift.Value(imagePath),
      soundPath: drift.Value(soundPath),
      createdAt: DateTime.now(),
    );

    await db.into(db.cards).insert(cardCompanion);
    await loadCards();
  }

  //remove card by id
  Future<void> deleteCard(String cardId) async {
    await (db.delete(db.cards)..where((tbl) => tbl.id.equals(cardId))).go();
    await loadCards();
  }

  // ambil card berdasarkan kategori
  Future<List<Card>> getCardsByCategory(String categoryId) async {
    return await (db.select(db.cards)
      ..where((tbl) => tbl.categoryId.equals(categoryId)))
      .get();
  }

  //select card untuk ditampilkan/ dimainkan
  void addToSelected(Card card) {
    if (!selectedCards.contains(card)) {
      selectedCards.add(card);
    }
  }

  void removeFromSelected(Card card) {
    selectedCards.remove(card);
  }

  void reorderSelectedCards(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex--;
    final card = selectedCards.removeAt(oldIndex);
    selectedCards.insert(newIndex, card);
  }

  void toggleViewMode() {
    isTextMode.value = !isTextMode.value;
  }

  // play suara dari selected card
  Future<void> playSelectedCards() async {
    if (selectedCards.isEmpty) return;

    final soundPaths = selectedCards
        .where((card) => card.soundPath != null && card.soundPath!.isNotEmpty)
        .map((card) => card.soundPath!)
        .toList();

    if (soundPaths.isNotEmpty) {
      await _audioService.playMultipleFiles(soundPaths);
    }
  }

  void clearSelection() {
    selectedCards.clear();
  }

  // helper untuk stream agar bisa dipanggil dari controller/UI
  Stream<List<CardWithCategory>> watchCardsWithCategories() {
  return db.watchCardsWithCategories();
}
}