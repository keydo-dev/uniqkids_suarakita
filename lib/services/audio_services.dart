import 'dart:io';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

class AudioService {
  FlutterSoundRecorder? _recorder;
  FlutterSoundPlayer? _player;

  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  Future<void> init() async {
    _recorder = FlutterSoundRecorder();
    _player = FlutterSoundPlayer();

    await _recorder!.openRecorder();
    await _player!.openPlayer();
  }

  Future<bool> requestPermissions() async {
    final status = await Permission.microphone.request();
    return status == PermissionStatus.granted;
  }

  Future<String?> startRecording() async {
    if (!await requestPermissions()) {
      return null;
    }

    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/${DateTime.now().millisecondsSinceEpoch}.aac';

    await _recorder!.startRecorder(
      toFile: filePath,
      codec: Codec.aacADTS,
    );

    return filePath;
  }

  Future<void> stopRecording() async {
    await _recorder!.stopRecorder();
  }

  Future<void> playFile(String filePath) async {
    if (File(filePath).existsSync()) {
      await _player!.startPlayer(
        fromURI: filePath,
        whenFinished: () {},
      );
    }
  }

  Future<void> stopPlayer() async {
    await _player!.stopPlayer();
  }

  Future<void> playMultipleFiles(List<String> filePaths) async {
    for (final filePath in filePaths) {
      if (File(filePath).existsSync()) {
        await _player!.startPlayer(fromURI: filePath);
        
        // Wait for the current file to finish before playing the next
        while (_player!.isPlaying) {
          await Future.delayed(const Duration(milliseconds: 100));
        }
        
        // Small delay between files
        await Future.delayed(const Duration(milliseconds: 300));
      }
    }
  }

  bool get isRecording => _recorder?.isRecording ?? false;
  bool get isPlaying => _player?.isPlaying ?? false;

  void dispose() {
    _recorder?.closeRecorder();
    _player?.closePlayer();
  }
}
