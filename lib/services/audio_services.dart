import 'dart:io';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

class AudioService {
  FlutterSoundRecorder? _recorder;
  FlutterSoundPlayer? _player;
  bool _initialized = false;

  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  // Inisialisasi sekali saja
  Future<void> init() async {
    if (_initialized) return;

    _recorder = FlutterSoundRecorder();
    _player = FlutterSoundPlayer();

    await _recorder!.openRecorder();
    await _player!.openPlayer();

    _initialized = true;
  }

  Future<bool> requestPermissions() async {
    final status = await Permission.microphone.request();
    return status == PermissionStatus.granted;
  }

  // Mulai rekam
  Future<String?> startRecording() async {
    if (!_initialized) await init();
    if (!await requestPermissions()) return null;

    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/${DateTime.now().millisecondsSinceEpoch}.aac';

    await _recorder!.startRecorder(
      toFile: filePath,
      codec: Codec.aacADTS,
    );

    return filePath;
  }

  // Stop rekaman
  Future<void> stopRecording() async {
    if (_recorder?.isRecording ?? false) {
      await _recorder!.stopRecorder();
    }
  }

  // Play file tunggal
  Future<void> playFile(String filePath) async {
    if (!_initialized) await init();
    if (_player == null || !_player!.isOpen()) return;
    if (!File(filePath).existsSync()) return;

    await _player!.startPlayer(fromURI: filePath);
  }

  // Stop player
  Future<void> stopPlayer() async {
    if (_player?.isPlaying ?? false) {
      await _player!.stopPlayer();
    }
  }

  // Play beberapa file secara berurutan
  Future<void> playMultipleFiles(List<String> filePaths) async {
    if (!_initialized) await init();
    if (filePaths.isEmpty || _player == null) return;
    if (_player!.isPlaying) return; // cegah overlap

    for (final filePath in filePaths) {
      if (!File(filePath).existsSync()) continue;

      await _player!.startPlayer(fromURI: filePath);
      while (_player!.isPlaying) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
      await Future.delayed(const Duration(milliseconds: 300));
    }
  }

  bool get isRecording => _recorder?.isRecording ?? false;
  bool get isPlaying => _player?.isPlaying ?? false;

  // Bersihkan resource
  Future<void> dispose() async {
    await _recorder?.closeRecorder();
    await _player?.closePlayer();
    _recorder = null;
    _player = null;
    _initialized = false;
  }
}
