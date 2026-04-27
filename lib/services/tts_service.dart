import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter_tts/flutter_tts.dart';

/// Wraps flutter_tts for natural sentence playback.
/// Speaks an entire sentence as one utterance so prosody is natural,
/// instead of stitching individual recorded clips together.
class TtsService {
  final FlutterTts _tts = FlutterTts();
  bool _initialized = false;
  List<Map<String, String>> _voicesCache = [];

  // Cached so we can re-apply the voice after `setLanguage`, which
  // otherwise resets the engine to that language's default voice on Android.
  String? _currentVoiceName;
  String? _currentVoiceLocale;

  static final TtsService _instance = TtsService._internal();
  factory TtsService() => _instance;
  TtsService._internal();

  Future<void> init() async {
    if (_initialized) return;

    // Ensure await speak() resolves only after playback finishes.
    await _tts.awaitSpeakCompletion(true);
    await _tts.setSpeechRate(0.45);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);

    _initialized = true;
  }

  /// Speak an entire sentence (one utterance, natural intonation).
  Future<void> speak(String text, {required String langCode}) async {
    if (!_initialized) await init();
    if (text.trim().isEmpty) return;

    await _tts.stop();
    await _tts.setLanguage(_resolveLocale(langCode));
    // Re-apply the cached voice — `setLanguage` resets the active voice
    // to the language default on Android, which would clobber the
    // user's male/female / kids choice.
    if (_currentVoiceName != null && _currentVoiceLocale != null) {
      await _tts.setVoice({
        'name': _currentVoiceName!,
        'locale': _currentVoiceLocale!,
      });
    }
    await _tts.speak(text);
  }

  Future<void> stop() async {
    if (!_initialized) return;
    await _tts.stop();
  }

  /// Voices available on the device, filtered by the requested language.
  /// Sorted: detected "kids" voices first, then alphabetical by name.
  Future<List<Map<String, String>>> getVoicesForLang(String langCode) async {
    if (!_initialized) await init();

    if (_voicesCache.isEmpty) {
      final raw = await _tts.getVoices;
      if (raw is List) {
        _voicesCache = raw
            .whereType<Map>()
            .map((v) => v.map(
                  (k, value) =>
                      MapEntry(k.toString(), value?.toString() ?? ''),
                ))
            .toList();
      }
    }

    final lang = langCode.toLowerCase();
    final filtered = _voicesCache.where((v) {
      final loc = (v['locale'] ?? '').toLowerCase();
      return loc.startsWith(lang);
    }).toList();

    filtered.sort((a, b) {
      final ak = isKidVoice(a) ? 0 : 1;
      final bk = isKidVoice(b) ? 0 : 1;
      if (ak != bk) return ak - bk;
      return (a['name'] ?? '').compareTo(b['name'] ?? '');
    });

    return filtered;
  }

  /// Best default voice for a (lang, gender), preferring kid-sounding voices.
  /// Returns null if the device has no voice for that language.
  Future<Map<String, String>?> pickBestVoice({
    required String langCode,
    required String gender,
  }) async {
    final voices = await getVoicesForLang(langCode);
    if (voices.isEmpty) return null;

    // 1. Kid voice that also matches requested gender.
    final kidMatch = voices.firstWhere(
      (v) => isKidVoice(v) && _matchesGender(v, gender),
      orElse: () => const {},
    );
    if (kidMatch.isNotEmpty) return kidMatch;

    // 2. Any kid voice (gender unknown / not specified).
    final anyKid = voices.firstWhere(
      isKidVoice,
      orElse: () => const {},
    );
    if (anyKid.isNotEmpty) return anyKid;

    // 3. Adult voice that matches requested gender.
    final genderMatch = voices.firstWhere(
      (v) => _matchesGender(v, gender),
      orElse: () => const {},
    );
    if (genderMatch.isNotEmpty) return genderMatch;

    // 4. Android last-resort: dedupe to distinct speakers (e.g. collapse
    //    `-local` and `-network` variants of the same voice), then alternate
    //    so 'male' and 'female' at least map to genuinely different voices.
    if (Platform.isAndroid) {
      final speakers = <String, Map<String, String>>{};
      for (final v in voices) {
        final key = _speakerKey(v['name'] ?? '');
        speakers.putIfAbsent(key, () => v);
      }
      final distinct = speakers.values.toList();
      if (distinct.length >= 2) {
        return gender == 'male' ? distinct[1] : distinct.first;
      }
      if (distinct.isNotEmpty) return distinct.first;
    }

    return voices.first;
  }

  /// Strip the `-local` / `-network` suffix so two variants of the same
  /// Google TTS speaker collapse to one.
  String _speakerKey(String voiceName) {
    final parts = voiceName.split('-');
    if (parts.length >= 5) {
      return parts.sublist(0, 4).join('-');
    }
    return voiceName;
  }

  Future<void> setVoiceByName({
    required String name,
    required String locale,
  }) async {
    if (!_initialized) await init();
    if (name.isEmpty) return;
    _currentVoiceName = name;
    _currentVoiceLocale = locale;
    await _tts.setVoice({'name': name, 'locale': locale});
  }

  /// Heuristic: voice name suggests a child / young voice.
  bool isKidVoice(Map<String, String> v) {
    final name = (v['name'] ?? '').toLowerCase();
    final extra = (v['identifier'] ?? '').toLowerCase();
    const kidMarkers = [
      'child',
      'children',
      'kid',
      'kids',
      'young',
      'junior',
      'boy',
      'girl',
    ];
    for (final m in kidMarkers) {
      if (name.contains(m) || extra.contains(m)) return true;
    }
    return false;
  }

  bool _matchesGender(Map<String, String> v, String gender) {
    final g = (v['gender'] ?? '').toLowerCase();
    if (g.isNotEmpty) return g == gender;

    final name = (v['name'] ?? '').toLowerCase();
    if (name.contains(gender)) return true;

    final googleGender = _googleVoiceGenderFor(name);
    if (googleGender != null) return googleGender == gender;

    return false;
  }

  /// Curated mapping for Google TTS voice ids that don't expose `gender`.
  /// Voice names look like `id-id-x-idd-local` or `en-us-x-iol-network`.
  /// The 4th dash-separated segment is the speaker id.
  static const Map<String, String> _googleVoiceGenders = {
    // Indonesian (id-ID)
    'idc': 'female',
    'ide': 'female',
    'idd': 'male',
    'idf': 'male',
    // US English (en-US)
    'iol': 'male',
    'iom': 'male',
    'iog': 'female',
    'tpc': 'female',
    'tpd': 'female',
    'sfg': 'female',
    // UK English (en-GB)
    'gba': 'female',
    'gbb': 'male',
    'gbc': 'female',
    'gbd': 'male',
  };

  String? _googleVoiceGenderFor(String voiceName) {
    final parts = voiceName.split('-');
    if (parts.length < 5) return null;
    return _googleVoiceGenders[parts[3]];
  }

  String _resolveLocale(String langCode) {
    switch (langCode.toLowerCase()) {
      case 'id':
        return 'id-ID';
      case 'en':
      default:
        return 'en-US';
    }
  }

  Future<void> dispose() async {
    if (!_initialized) return;
    await _tts.stop();
    _initialized = false;
  }
}
