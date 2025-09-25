// models/market.dart
import 'package:flutter/material.dart';
import '../services/translation_service.dart';

class MarketItem {
  final String id;
  final String mandiName;
  final String commodity;
  final double price;
  final String unit;
  final double trend; // positive = up, negative = down
  final DateTime lastUpdated;
  final String location;

  MarketItem({
    required this.id,
    required this.mandiName,
    required this.commodity,
    required this.price,
    required this.unit,
    required this.trend,
    required this.lastUpdated,
    required this.location,
  });

  factory MarketItem.fromJson(Map<String, dynamic> json) {
    return MarketItem(
      id: json['id'] ?? '',
      mandiName: json['mandi_name'] ?? '',
      commodity: json['commodity'] ?? '',
      price: (json['price'] ?? 0.0).toDouble(),
      unit: json['unit'] ?? 'kg',
      trend: (json['trend'] ?? 0.0).toDouble(),
      lastUpdated: DateTime.parse(json['last_updated'] ?? DateTime.now().toIso8601String()),
      location: json['location'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mandi_name': mandiName,
      'commodity': commodity,
      'price': price,
      'unit': unit,
      'trend': trend,
      'last_updated': lastUpdated.toIso8601String(),
      'location': location,
    };
  }

  String get trendText {
    if (trend > 0) return TranslationService.tr('price_increased');
    if (trend < 0) return TranslationService.tr('price_decreased');
    return TranslationService.tr('price_stable');
  }

  IconData get trendIcon {
    if (trend > 0) return Icons.arrow_upward;
    if (trend < 0) return Icons.arrow_downward;
    return Icons.remove;
  }

  Color get trendColor {
    if (trend > 0) return Colors.green;
    if (trend < 0) return Colors.red;
    return Colors.grey;
  }
}