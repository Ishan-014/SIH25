// widgets/voice_replay_button.dart
import 'package:flutter/material.dart';
import '../services/tts_service.dart';
import '../main.dart';

class VoiceReplayButton extends StatelessWidget {
  final String text;
  final Color? color;
  final double size;

  const VoiceReplayButton({
    Key? key,
    required this.text,
    this.color,
    this.size = 24,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => TTSService.speak(text),
      icon: Icon(
        Icons.volume_up,
        size: size,
        color: color ?? AppConstants.primaryGreen,
      ),
      tooltip: 'ਦੁਬਾਰਾ ਸੁਣੋ',
    );
  }
}