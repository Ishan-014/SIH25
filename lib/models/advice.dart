// models/advice.dart
class Advice {
  final String id;
  final String cropType;
  final String soilType;
  final String recommendation;
  final String expectedYield;
  final String fertilizer;
  final List<String> steps;
  final DateTime timestamp;
  final String language;

  Advice({
    required this.id,
    required this.cropType,
    required this.soilType,
    required this.recommendation,
    required this.expectedYield,
    required this.fertilizer,
    required this.steps,
    required this.timestamp,
    required this.language,
  });

  factory Advice.fromJson(Map<String, dynamic> json) {
    return Advice(
      id: json['id'] ?? '',
      cropType: json['crop_type'] ?? '',
      soilType: json['soil_type'] ?? '',
      recommendation: json['recommendation'] ?? '',
      expectedYield: json['expected_yield'] ?? '',
      fertilizer: json['fertilizer'] ?? '',
      steps: List<String>.from(json['steps'] ?? []),
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      language: json['language'] ?? 'pa',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'crop_type': cropType,
      'soil_type': soilType,
      'recommendation': recommendation,
      'expected_yield': expectedYield,
      'fertilizer': fertilizer,
      'steps': steps,
      'timestamp': timestamp.toIso8601String(),
      'language': language,
    };
  }
}