// widgets/help_overlay.dart
import 'package:flutter/material.dart';
import '../services/tts_service.dart';
import '../main.dart';

class HelpOverlay extends StatelessWidget {
  final String title;
  final String description;
  final List<String> tips;

  const HelpOverlay({
    Key? key,
    required this.title,
    required this.description,
    required this.tips,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.help_outline, color: AppConstants.primaryGreen),
          SizedBox(width: 8),
          Expanded(child: Text(title)),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(description),
            SizedBox(height: 16),
            if (tips.isNotEmpty) ...[
              Text(
                'ਸੁਝਾਅ:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              ...tips.asMap().entries.map((entry) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${entry.key + 1}. '),
                      Expanded(child: Text(entry.value)),
                    ],
                  ),
                );
              }).toList(),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('ਬੰਦ ਕਰੋ'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            _speakHelp();
          },
          child: Text('ਸੁਣੋ'),
        ),
      ],
    );
  }

  void _speakHelp() {
    String fullText = '$title. $description';
    if (tips.isNotEmpty) {
      fullText += '. ਸੁਝਾਅ: ${tips.join('. ')}';
    }
    TTSService.speak(fullText);
  }

  static void show(
    BuildContext context, {
    required String title,
    required String description,
    List<String> tips = const [],
  }) {
    showDialog(
      context: context,
      builder: (context) => HelpOverlay(
        title: title,
        description: description,
        tips: tips,
      ),
    );
  }
}