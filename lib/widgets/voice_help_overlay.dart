// widgets/voice_help_overlay.dart
import 'package:flutter/material.dart';
import '../services/tts_service.dart';
import '../services/translation_service.dart';
import '../main.dart';

class VoiceHelpOverlay extends StatelessWidget {
  final String title;
  final String description;
  final VoidCallback? onUseVoice;

  const VoiceHelpOverlay({
    Key? key,
    required this.title,
    required this.description,
    this.onUseVoice,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      contentPadding: EdgeInsets.all(0),
      content: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppConstants.primaryGreen.withOpacity(0.1),
              Colors.white,
            ],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon and title
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: AppConstants.primaryGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppConstants.primaryGreen.withOpacity(0.3),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.mic,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              SizedBox(height: 20),
              Text(
                title,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.primaryText,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              Text(
                description,
                style: TextStyle(
                  fontSize: 16,
                  color: AppConstants.mutedText,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),
              // Voice command examples
              _buildVoiceExamples(),
              SizedBox(height: 24),
              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppConstants.primaryGreen,
                        side: BorderSide(color: AppConstants.primaryGreen),
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(TranslationService.tr('close')),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        onUseVoice?.call();
                      },
                      icon: Icon(Icons.mic, size: 20),
                      label: Text(TranslationService.tr('voice_instruction')),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConstants.primaryGreen,
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVoiceExamples() {
    final examples = [
      {'icon': Icons.lightbulb, 'text': TranslationService.tr('advice')},
      {'icon': Icons.wb_cloudy, 'text': TranslationService.tr('weather')},
      {'icon': Icons.store, 'text': TranslationService.tr('market')},
      {'icon': Icons.camera_alt, 'text': TranslationService.tr('pest_photo')},
    ];

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppConstants.primaryGreen.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppConstants.primaryGreen.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            TranslationService.tr('voice_instruction'),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppConstants.primaryGreen,
            ),
          ),
          SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: examples.map((example) => _buildExampleChip(
              example['icon'] as IconData,
              example['text'] as String,
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildExampleChip(IconData icon, String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: AppConstants.primaryGreen,
          ),
          SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: AppConstants.primaryText,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  static void show(
    BuildContext context, {
    required String title,
    required String description,
    VoidCallback? onUseVoice,
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => VoiceHelpOverlay(
        title: title,
        description: description,
        onUseVoice: onUseVoice,
      ),
    );
  }
}