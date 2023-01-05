import 'package:flutter/cupertino.dart';
import 'package:flutter_sound_lite/flutter_sound.dart';
import 'package:shared_preferences/shared_preferences.dart';

final pathToSaveAudio = "audio_test.aac";

class SoundPlayer {
  FlutterSoundPlayer? _audioPlayer;

  bool get isPlaying => _audioPlayer!.isPlaying;

  Future init() async {
    _audioPlayer = FlutterSoundPlayer();

    await _audioPlayer!.openAudioSession();
  }

  Future dispose() async {
    await _audioPlayer!.closeAudioSession();
    _audioPlayer = null;
  }

  Future _play(VoidCallback whenFinished) async {
    await _audioPlayer!.startPlayer(
      fromURI: pathToSaveAudio,
      whenFinished: whenFinished,
    );
  }

  Future _stop() async {
    await _audioPlayer!.stopPlayer();
  }

  Future togglePlaying({required VoidCallback whenFinished}) async {
    if (_audioPlayer!.isStopped) {
      await _play(whenFinished);
    } else {
      await _stop();
    }
  }

  Future myplay({required VoidCallback whenFinished}) async {
    print("---->" + pathToSaveAudio);
    final prefs = await SharedPreferences.getInstance();

    await _audioPlayer!.startPlayer(
      fromURI: prefs.getString('comp_audio'),
      whenFinished: whenFinished,
    );
  }
}
