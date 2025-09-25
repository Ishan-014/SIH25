// models/pest_report.dart

// import 'package:flutter/material.dart';

class PestReport {
  final String id;
  final String imagePath;
  final String cropType;
  final String pestDetected;
  final String remedy;
  final List<String> remedySteps;
  final DateTime timestamp;
  final bool isUploaded;

  PestReport({
    required this.id,
    required this.imagePath,
    required this.cropType,
    required this.pestDetected,
    required this.remedy,
    required this.remedySteps,
    required this.timestamp,
    this.isUploaded = false,
  });

  factory PestReport.fromJson(Map<String, dynamic> json) {
    return PestReport(
      id: json['id'] ?? '',
      imagePath: json['image_path'] ?? '',
      cropType: json['crop_type'] ?? '',
      pestDetected: json['pest_detected'] ?? '',
      remedy: json['remedy'] ?? '',
      remedySteps: List<String>.from(json['remedy_steps'] ?? []),
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      isUploaded: json['is_uploaded'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'image_path': imagePath,
      'crop_type': cropType,
      'pest_detected': pestDetected,
      'remedy': remedy,
      'remedy_steps': remedySteps,
      'timestamp': timestamp.toIso8601String(),
      'is_uploaded': isUploaded,
    };
  }
}