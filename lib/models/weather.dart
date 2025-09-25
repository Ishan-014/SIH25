// models/weather.dart
import 'package:flutter/material.dart';

class Weather {
  final String location;
  final String condition;
  final double temperature;
  final int humidity;
  final String description;
  final String advice;
  final List<String> alerts;
  final DateTime timestamp;
  final String iconCode;

  Weather({
    required this.location,
    required this.condition,
    required this.temperature,
    required this.humidity,
    required this.description,
    required this.advice,
    required this.alerts,
    required this.timestamp,
    required this.iconCode,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      location: json['location'] ?? '',
      condition: json['condition'] ?? 'clear',
      temperature: (json['temperature'] ?? 25.0).toDouble(),
      humidity: json['humidity'] ?? 60,
      description: json['description'] ?? '',
      advice: json['advice'] ?? '',
      alerts: List<String>.from(json['alerts'] ?? []),
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      iconCode: json['icon_code'] ?? 'sun',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'location': location,
      'condition': condition,
      'temperature': temperature,
      'humidity': humidity,
      'description': description,
      'advice': advice,
      'alerts': alerts,
      'timestamp': timestamp.toIso8601String(),
      'icon_code': iconCode,
    };
  }

  IconData get weatherIcon {
    switch (iconCode) {
      case 'rain':
        return Icons.cloud_outlined;
      case 'cloud':
        return Icons.cloud;
      case 'sun':
      default:
        return Icons.wb_sunny;
    }
  }
}