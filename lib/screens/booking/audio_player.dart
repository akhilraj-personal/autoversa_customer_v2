import 'package:audioplayers/audioplayers.dart';
import 'package:autoversa/constant/image_const.dart';
import 'package:autoversa/constant/text_style.dart';
import 'package:autoversa/utils/color_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AudioPlayerUI extends StatefulWidget {
  final String? audio;
  AudioPlayerUI({required this.audio, super.key});

  @override
  State<AudioPlayerUI> createState() => _AudioPlayerUIState();
}

class _AudioPlayerUIState extends State<AudioPlayerUI> {
  bool isPlaying = false;
  AudioPlayer player = AudioPlayer();

  @override
  void initState() {
    super.initState();
  }

  void onPlay() {
    if (isPlaying) {
      player.pause();
    } else {
      player.resume();
    }

    setState(() {
      isPlaying = !isPlaying;
    });
  }

  @override
  Future<void> dispose() async {
    player.dispose();
    player.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String url = dotenv.env['aws_url']! + widget.audio!;
    if (widget.audio != "") {
      player.setSourceUrl(url);
    }
    return Padding(
      padding: EdgeInsets.fromLTRB(8, 8, 20, 0),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 4,
            child: Container(
              margin: const EdgeInsets.fromLTRB(14.0, 0, 0, 0),
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.2),
                    blurRadius: 0.1,
                    spreadRadius: 0,
                  ),
                ],
                border: Border.all(color: greyColor.withOpacity(0.5)),
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Padding(padding: EdgeInsets.all(4)),
                      Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topRight,
                            end: Alignment.bottomRight,
                            colors: [
                              lightblueColor,
                              syanColor,
                            ],
                          ),
                        ),
                        child: Icon(Icons.record_voice_over_outlined,
                            color: Colors.white, size: 20),
                      ),
                      SizedBox(
                        width: 16,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(isPlaying ? "Stop Playing" : "Play Recording",
                              style: montserratRegular.copyWith(
                                  color: Colors.black,
                                  fontSize: width * 0.034)),
                        ],
                      )
                    ],
                  ),
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.white,
                    child: IconButton(
                      icon: Icon(
                          isPlaying
                              ? Icons.stop_circle_outlined
                              : Icons.play_circle_outline_sharp,
                          color: Colors.black),
                      onPressed: onPlay,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
