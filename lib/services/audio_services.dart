import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import '../utils/asset_helper.dart';

class AudioService {
  FlutterSoundRecorder? _recorder;
  FlutterSoundPlayer? _player;
  bool _initialized = false;
  bool _isStopped = false;

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
    await _player!.setVolume(1.0);

    _initialized = true;
  }

  Future<bool> requestPermissions() async {
    final status = await Permission.microphone.request();
    return status == PermissionStatus.granted;
  }

  Future<String?> startRecording({required String fileName, required String lang}) async {
    if (!_initialized) await init();
    if (!await requestPermissions()) return null;

    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/$fileName-$lang.aac';

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
  Future<void> playFile(String? filePath) async {
    if (!_initialized) await init();
    if (_player == null || !_player!.isOpen() || filePath == null) return;

    if (filePath.startsWith('assets/')) {
      try {
        final data = await rootBundle.load(filePath);
        await _player!.startPlayer(fromDataBuffer: data.buffer.asUint8List());
      } catch (e) {
        print('Error playing asset $filePath: $e');
      }
    } else {
      await _player!.startPlayer(fromURI: filePath);
    }
  }

  // Stop player
  Future<void> stopPlayer() async {
    if (_player?.isPlaying ?? false) {
      await _player!.stopPlayer();
    }
    _isStopped = true;
  }

  // Play beberapa file secara berurutan
  Future<void> playMultipleFiles(List<String?> filePaths) async {
    if (!_initialized) await init();
    if (filePaths.isEmpty || _player == null) return;
    if (_player!.isPlaying) return; // cegah overlap

    _isStopped = false;

    for (final filePath in filePaths) {
      if (_isStopped) break;

      if (filePath == null) continue;

      if (filePath.startsWith('assets/')) {
        try {
          final data = await rootBundle.load(filePath);
          await _player!.startPlayer(fromDataBuffer: data.buffer.asUint8List());
        } catch (e) {
          print('Error playing asset $filePath: $e');
          continue;
        }
      } else {
        await _player!.startPlayer(fromURI: filePath);
      }

      while (_player!.isPlaying) {
        await Future.delayed(const Duration(milliseconds: 1));
        if (_isStopped) {
          await _player!.stopPlayer();
          break;
        }
      }
      await Future.delayed(const Duration(milliseconds: 1));
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
