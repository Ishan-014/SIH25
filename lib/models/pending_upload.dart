// import 'package:flutter/material.dart';

class PendingUpload {
  final String id;
  final String type; // 'pest_image', 'feedback', etc.
  final Map<String, dynamic> data;
  final String? filePath;
  final DateTime timestamp;
  final int retryCount;

  PendingUpload({
    required this.id,
    required this.type,
    required this.data,
    this.filePath,
    required this.timestamp,
    this.retryCount = 0,
  });

  factory PendingUpload.fromJson(Map<String, dynamic> json) {
    return PendingUpload(
      id: json['id'] ?? '',
      type: json['type'] ?? '',
      data: json['data'] ?? {},
      filePath: json['file_path'],
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      retryCount: json['retry_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'data': data,
      'file_path': filePath,
      'timestamp': timestamp.toIso8601String(),
      'retry_count': retryCount,
    };
  }
}