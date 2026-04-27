import 'package:get/get.dart';
import 'package:SuaraKita/controllers/languages_controller.dart';
import 'package:SuaraKita/controllers/voice_controller.dart';
import 'package:SuaraKita/models/database.dart';
import 'package:SuaraKita/services/audio_services.dart';
import 'package:SuaraKita/services/tts_service.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart' as drift;

class CardController extends GetxController {
  final AppDatabase db;
  final _uuid = const Uuid();
  final _audioService = Get.find<AudioService>();
  final _ttsService = Get.find<TtsService>();
  final langController = Get.find<LanguagesController>();
  final voiceController = Get.find<VoiceController>();

  var cards = <Card>[].obs;
  var selectedCards = <Card>[].obs;
  // Mirror of `selectedCards` keyed by id for O(1) `contains` checks in the
  // grid build path (called once per visible card on every selection change).
  final RxSet<String> selectedIds = <String>{}.obs;
  var isTextMode = false.obs;

  bool isSelected(String cardId) => selectedIds.contains(cardId);

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
    if (selectedIds.contains(card.id)) {
      selectedCards.removeWhere((c) => c.id == card.id);
      selectedIds.remove(card.id);
    } else {
      selectedCards.add(card);
      selectedIds.add(card.id);
    }
  }

  // Hapus kartu dari daftar terpilih
  void removeCard(Card card) {
    selectedCards.removeWhere((c) => c.id == card.id);
    selectedIds.remove(card.id);
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

  // Putar suara dari semua kartu terpilih sebagai satu kalimat.
  // Pakai TTS (suara natural, satu utterance) bila diaktifkan; bila tidak,
  // fallback ke pemutaran berurutan klip rekaman.
  Future<void> playSelectedCards() async {
    if (selectedCards.isEmpty) return;

    final lang = langController.currentLanguage.value;

    try {
      if (voiceController.useTts.value) {
        final sentence = selectedCards
            .map((c) {
              final word = lang == 'en' ? (c.enName ?? c.name) : c.name;
              return word.trim();
            })
            .where((w) => w.isNotEmpty)
            .join(' ');

        if (sentence.isEmpty) return;
        await _ttsService.speak(sentence, langCode: lang);
        return;
      }

      final paths = selectedCards
          .map((card) {
            final p = lang == 'en'
                ? (card.enSoundPath ?? card.soundPath)
                : card.soundPath;
            return (p != null && p.isNotEmpty) ? p : null;
          })
          .whereType<String>()
          .toList();

      if (paths.isEmpty) return;
      await _audioService.playMultipleFiles(paths);
    } catch (e) {
      print('Error playing selected cards: $e');
    }
  }

  // Hapus semua kartu yang terpilih
  void clearSelection() {
    selectedCards.clear();
    selectedIds.clear();
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
