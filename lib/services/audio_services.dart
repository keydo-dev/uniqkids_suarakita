import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

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

  // Play beberapa file secara berurutan tanpa jeda (gapless).
  Future<void> playMultipleFiles(List<String?> filePaths) async {
    if (!_initialized) await init();
    if (filePaths.isEmpty || _player == null) return;
    if (_player!.isPlaying) {
      await _player!.stopPlayer();
    }

    _isStopped = false;

    final paths = filePaths
        .where((p) => p != null && p.isNotEmpty)
        .cast<String>()
        .toList();
    if (paths.isEmpty) return;

    // Pre-load semua asset buffer secara paralel sebelum playback dimulai
    // supaya tidak ada delay loading antar klip.
    final buffers = await Future.wait(paths.map((p) async {
      if (!p.startsWith('assets/')) return null;
      try {
        final data = await rootBundle.load(p);
        return data.buffer.asUint8List();
      } catch (e) {
        print('Error loading asset $p: $e');
        return null;
      }
    }));

    for (var i = 0; i < paths.length; i++) {
      if (_isStopped) break;

      final path = paths[i];
      final buffer = buffers[i];
      final completer = Completer<void>();

      void onFinished() {
        if (!completer.isCompleted) completer.complete();
      }

      try {
        if (buffer != null) {
          await _player!.startPlayer(
            fromDataBuffer: buffer,
            whenFinished: onFinished,
          );
        } else if (!path.startsWith('assets/')) {
          await _player!.startPlayer(
            fromURI: path,
            whenFinished: onFinished,
          );
        } else {
          continue;
        }
      } catch (e) {
        print('Error starting player for $path: $e');
        continue;
      }

      await completer.future;
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
