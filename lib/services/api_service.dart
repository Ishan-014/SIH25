// services/api_service.dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/advice.dart';
import '../models/weather.dart';
import '../models/market.dart';
import '../models/pest_report.dart';
import 'translation_service.dart';

class ApiService {
  static const String baseUrl = 'https://your-api-endpoint.com/api/v1';
  static const int timeoutSeconds = 10;

  // Network connectivity check
  static Future<bool> hasNetwork() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  // Generic API call with retry logic
  static Future<http.Response?> _makeRequest(
    String endpoint, {
    String method = 'GET',
    Map<String, dynamic>? data,
    Map<String, String>? headers,
    int retries = 3,
  }) async {
    if (!await hasNetwork()) {
      throw NetworkException('No internet connection');
    }

    final url = Uri.parse('$baseUrl$endpoint');
    final defaultHeaders = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    if (headers != null) {
      defaultHeaders.addAll(headers);
    }

    for (int attempt = 0; attempt <= retries; attempt++) {
      try {
        http.Response response;
        
        switch (method.toUpperCase()) {
          case 'POST':
            response = await http.post(
              url,
              headers: defaultHeaders,
              body: data != null ? jsonEncode(data) : null,
            ).timeout(Duration(seconds: timeoutSeconds));
            break;
          case 'PUT':
            response = await http.put(
              url,
              headers: defaultHeaders,
              body: data != null ? jsonEncode(data) : null,
            ).timeout(Duration(seconds: timeoutSeconds));
            break;
          default:
            response = await http.get(
              url,
              headers: defaultHeaders,
            ).timeout(Duration(seconds: timeoutSeconds));
        }

        if (response.statusCode >= 200 && response.statusCode < 300) {
          return response;
        } else if (response.statusCode >= 500 && attempt < retries) {
          // Retry on server errors
          await Future.delayed(Duration(seconds: attempt + 1));
          continue;
        } else {
          throw ApiException('API Error: ${response.statusCode}');
        }
      } catch (e) {
        if (attempt == retries) rethrow;
        await Future.delayed(Duration(seconds: attempt + 1));
      }
    }
    
    return null;
  }

  // Get crop advice
  static Future<Advice> getAdvice({
    required String cropType,
    required String soilType,
    String? location,
  }) async {
    try {
      final response = await _makeRequest('/advice', method: 'POST', data: {
        'crop_type': cropType,
        'soil_type': soilType,
        'location': location,
        'language': TranslationService.getCurrentLanguage(),
      });

      if (response != null) {
        final data = jsonDecode(response.body);
        return Advice.fromJson(data);
      }
    } catch (e) {
      // Return demo advice if API fails
      print('API Error: $e');
    }
    
    // Fallback demo advice
    return Advice(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      cropType: cropType,
      soilType: soilType,
      recommendation: TranslationService.getCurrentLanguage() == 'pa' 
        ? 'ਇਸ ਮੌਸਮ ਵਿੱਚ ਪਾਣੀ ਦੀ ਮਾਤਰਾ ਘੱਟ ਕਰੋ ਅਤੇ ਜੈਵਿਕ ਖਾਦ ਵਰਤੋ'
        : 'इस मौसम में पानी की मात्रा कम करें और जैविक खाद का प्रयोग करें',
      expectedYield: '3.2 t/ha',
      fertilizer: 'N:40kg, P:30kg, K:20kg',
      steps: [
        TranslationService.getCurrentLanguage() == 'pa' ? 'ਪਹਿਲੇ ਖੇਤ ਦੀ ਤਿਆਰੀ ਕਰੋ' : 'पहले खेत की तैयारी करें',
        TranslationService.getCurrentLanguage() == 'pa' ? 'ਬੀਜ ਬੀਜੋ' : 'बीज बोएं',
        TranslationService.getCurrentLanguage() == 'pa' ? 'ਸਮੇਂ ਸਿਰ ਪਾਣੀ ਦਿਓ' : 'समय पर पानी दें',
      ],
      timestamp: DateTime.now(),
      language: TranslationService.getCurrentLanguage(),
    );
  }

  // Get weather information
  static Future<Weather> getWeather({String? location}) async {
    try {
      final response = await _makeRequest('/weather', data: {
        'location': location,
        'language': TranslationService.getCurrentLanguage(),
      });

      if (response != null) {
        final data = jsonDecode(response.body);
        return Weather.fromJson(data);
      }
    } catch (e) {
      print('Weather API Error: $e');
    }
    
    // Fallback demo weather
    return Weather(
      location: location ?? 'ਤੁਹਾਡਾ ਖੇਤਰ',
      condition: 'partly_cloudy',
      temperature: 28.5,
      humidity: 65,
      description: TranslationService.getCurrentLanguage() == 'pa' 
        ? 'ਅੱਜ ਅੱਧੇ ਬੱਦਲ ਹਨ, ਬਰਸਾਤ ਦੀ ਸੰਭਾਵਨਾ'
        : 'आज आंशिक बादल, बारिश की संभावना',
      advice: TranslationService.getCurrentLanguage() == 'pa'
        ? 'ਅੱਜ ਸਿੰਚਾਈ ਨਾ ਕਰੋ'
        : 'आज सिंचाई न करें',
      alerts: [],
      timestamp: DateTime.now(),
      iconCode: 'cloud',
    );
  }

  // Get market prices
  static Future<List<MarketItem>> getMarketPrices({String? location}) async {
    try {
      final response = await _makeRequest('/market', data: {
        'location': location,
        'language': TranslationService.getCurrentLanguage(),
      });

      if (response != null) {
        final data = jsonDecode(response.body);
        return (data['items'] as List)
            .map((item) => MarketItem.fromJson(item))
            .toList();
      }
    } catch (e) {
      print('Market API Error: $e');
    }
    
    // Fallback demo market data
    return [
      MarketItem(
        id: '1',
        mandiName: 'ਮੁੱਖ ਮੰਡੀ',
        commodity: 'ਕਣਕ',
        price: 2100,
        unit: 'quintal',
        trend: 50,
        lastUpdated: DateTime.now(),
        location: location ?? 'ਤੁਹਾਡਾ ਖੇਤਰ',
      ),
      MarketItem(
        id: '2', 
        mandiName: 'ਮੁੱਖ ਮੰਡੀ',
        commodity: 'ਚਾਵਲ',
        price: 1800,
        unit: 'quintal',
        trend: -30,
        lastUpdated: DateTime.now(),
        location: location ?? 'ਤੁਹਾਡਾ ਖੇਤਰ',
      ),
    ];
  }

  // Upload pest image
  static Future<PestReport> uploadPestImage(String imagePath) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/pest-detection'),
      );
      
      request.files.add(await http.MultipartFile.fromPath('image', imagePath));
      request.fields['language'] = TranslationService.getCurrentLanguage();
      
      var response = await request.send().timeout(Duration(seconds: 30));
      
      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final data = jsonDecode(responseBody);
        return PestReport.fromJson(data);
      }
    } catch (e) {
      print('Pest upload error: $e');
    }
    
    // Fallback demo pest report
    return PestReport(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      imagePath: imagePath,
      cropType: 'ਕਣਕ',
      pestDetected: 'ਅਫਿਡ',
      remedy: 'ਨੀਮ ਦਾ ਤੇਲ ਸਪ੍ਰੇ ਕਰੋ',
      remedySteps: [
        'ਨੀਮ ਦਾ ਤੇਲ 10ml ਪਾਣੀ 1 ਲੀਟਰ ਵਿੱਚ ਮਿਲਾਓ',
        'ਸਵੇਰੇ ਜਾਂ ਸ਼ਾਮ ਨੂੰ ਛਿੜਕਾਅ ਕਰੋ',
        '7 ਦਿਨ ਬਾਅਦ ਦੁਹਰਾਓ',
      ],
      timestamp: DateTime.now(),
      isUploaded: true,
    );
  }
}

// Custom exceptions
class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);
}

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
}