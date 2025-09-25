// widgets/voice_button.dart
import 'package:flutter/material.dart';
import '../services/translation_service.dart';
import '../main.dart';

class VoiceButton extends StatelessWidget {
  final bool isListening;
  final VoidCallback onPressed;

  const VoiceButton({
    Key? key,
    required this.isListening,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        width: double.infinity,
        height: AppConstants.buttonHeight,
        decoration: BoxDecoration(
          color: isListening ? AppConstants.accentYellow : AppConstants.primaryGreen,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isListening) ...[
              _buildListeningAnimation(),
              SizedBox(width: 12),
              Text(
                TranslationService.tr('listening_prompt'),
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ] else ...[
              Icon(
                Icons.mic,
                color: Colors.white,
                size: 28,
              ),
              SizedBox(width: 12),
              Text(
                TranslationService.tr('speak'),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildListeningAnimation() {
    return Container(
      width: 28,
      height: 28,
      child: Stack(
        children: [
          // Pulsing circles
          ...List.generate(3, (index) => _buildPulse(index)),
          // Mic icon
          Center(
            child: Icon(
              Icons.mic,
              color: Colors.black87,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPulse(int index) {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: AlwaysStoppedAnimation(0.0),
        builder: (context, child) {
          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: Duration(milliseconds: 1000 + (index * 200)),
            builder: (context, value, child) {
              return Transform.scale(
                scale: 0.5 + (value * 0.5),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.black87.withOpacity(1.0 - value),
                      width: 2,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
