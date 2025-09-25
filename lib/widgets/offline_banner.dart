// widgets/offline_banner.dart
import 'package:flutter/material.dart';
import '../services/translation_service.dart';
import '../main.dart';

class OfflineBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppConstants.accentYellow,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(Icons.offline_bolt, color: Colors.black87, size: 20),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              TranslationService.tr('no_network'),
              style: TextStyle(
                color: Colors.black87,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}