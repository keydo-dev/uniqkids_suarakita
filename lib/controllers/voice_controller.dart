import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:SuaraKita/controllers/languages_controller.dart';
import 'package:SuaraKita/services/tts_service.dart';

const _kUseTts = 'voice.useTts';
const _kGender = 'voice.gender';
const _kVoiceName = 'voice.name';

/// Holds the user's voice preferences.
/// - `useTts`: sentence playback uses TTS (natural) or stitched clips.
/// - `voiceGender`: 'female' or 'male'; informs auto-pick when no voice
///   has been chosen explicitly.
/// - `selectedVoiceName`: a specific voice picked from `availableVoices`.
///   Persisted across launches; resolved to a real voice on every change.
class VoiceController extends GetxController {
  final TtsService tts;
  final LanguagesController _langController = Get.find<LanguagesController>();

  final RxBool useTts = true.obs;
  final RxString voiceGender = 'female'.obs;
  final RxnString selectedVoiceName = RxnString();
  final RxList<Map<String, String>> availableVoices =
      <Map<String, String>>[].obs;

  VoiceController(this.tts);

  @override
  void onInit() {
    super.onInit();
    _load();
    ever<String>(_langController.currentLanguage, (_) => _applyVoice());
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    useTts.value = prefs.getBool(_kUseTts) ?? true;
    voiceGender.value = prefs.getString(_kGender) ?? 'female';
    selectedVoiceName.value = prefs.getString(_kVoiceName);
    await _applyVoice();
  }

  Future<void> setUseTts(bool value) async {
    useTts.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kUseTts, value);
  }

  /// Switch gender; clears any manually-picked voice so we re-pick the
  /// best kid voice for the new gender.
  Future<void> setGender(String gender) async {
    if (gender != 'male' && gender != 'female') return;
    voiceGender.value = gender;
    selectedVoiceName.value = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kGender, gender);
    await prefs.remove(_kVoiceName);

    await _applyVoice();
  }

  /// User picked a specific voice from the dropdown.
  Future<void> setVoiceByName(String name) async {
    final voice = availableVoices.firstWhere(
      (v) => v['name'] == name,
      orElse: () => const {},
    );
    if (voice.isEmpty) return;

    selectedVoiceName.value = name;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kVoiceName, name);

    await tts.setVoiceByName(
      name: name,
      locale: voice['locale'] ?? '',
    );
  }

  /// True if the picked voice (if any) is a kids voice.
  bool isKidVoiceSelected() {
    final name = selectedVoiceName.value;
    if (name == null) return false;
    final voice = availableVoices.firstWhere(
      (v) => v['name'] == name,
      orElse: () => const {},
    );
    return voice.isNotEmpty && tts.isKidVoice(voice);
  }

  Future<void> _applyVoice() async {
    final lang = _langController.currentLanguage.value;
    availableVoices.assignAll(await tts.getVoicesForLang(lang));

    // 1. Honour saved voice if it still exists for this language.
    final saved = selectedVoiceName.value;
    if (saved != null) {
      final voice = availableVoices.firstWhere(
        (v) => v['name'] == saved,
        orElse: () => const {},
      );
      if (voice.isNotEmpty) {
        await tts.setVoiceByName(
          name: voice['name'] ?? '',
          locale: voice['locale'] ?? '',
        );
        return;
      }
    }

    // 2. Auto-pick best (kids voice preferred, then gender match).
    final picked = await tts.pickBestVoice(
      langCode: lang,
      gender: voiceGender.value,
    );
    if (picked == null) return;

    selectedVoiceName.value = picked['name'];
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kVoiceName, picked['name'] ?? '');

    await tts.setVoiceByName(
      name: picked['name'] ?? '',
      locale: picked['locale'] ?? '',
    );
  }
}
