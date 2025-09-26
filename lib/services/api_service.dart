// services/api_service.dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/advice.dart';
import '../models/weather.dart';
import '../models/market.dart';
import '../models/pest_report.dart';
import '../config/api_config.dart';
import 'translation_service.dart';
import 'location_service.dart'; // import your service

class ApiService {
  static const int timeoutSeconds = 15;

  // Network connectivity check
  static Future<bool> hasNetwork() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  // Generic API call with retry logic
  static Future<http.Response?> _makeRequest(
    String url, {
    String method = 'GET',
    Map<String, dynamic>? data,
    Map<String, String>? headers,
    Map<String, String>? queryParams,
    int retries = 3,
  }) async {
    if (!await hasNetwork()) {
      throw NetworkException('No internet connection');
    }

    // Build URL with query parameters
    Uri uri = Uri.parse(url);
    if (queryParams != null) {
      uri = uri.replace(queryParameters: {
        ...uri.queryParameters,
        ...queryParams,
      });
    }

    final defaultHeaders = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'User-Agent': 'FarmerApp/1.0',
    };

    if (headers != null) {
      defaultHeaders.addAll(headers);
    }

    print('Making API request to: $uri');

    for (int attempt = 0; attempt <= retries; attempt++) {
      try {
        http.Response response;
        
        switch (method.toUpperCase()) {
          case 'POST':
            response = await http.post(
              uri,
              headers: defaultHeaders,
              body: data != null ? jsonEncode(data) : null,
            ).timeout(Duration(seconds: timeoutSeconds));
            break;
          case 'PUT':
            response = await http.put(
              uri,
              headers: defaultHeaders,
              body: data != null ? jsonEncode(data) : null,
            ).timeout(Duration(seconds: timeoutSeconds));
            break;
          default:
            response = await http.get(
              uri,
              headers: defaultHeaders,
            ).timeout(Duration(seconds: timeoutSeconds));
        }

        print('API Response Status: ${response.statusCode}');
        if (response.body.length > 200) {
          print('API Response Body (first 200 chars): ${response.body.substring(0, 200)}...');
        } else {
          print('API Response Body: ${response.body}');
        }

        if (response.statusCode >= 200 && response.statusCode < 300) {
          return response;
        } else if (response.statusCode >= 500 && attempt < retries) {
          await Future.delayed(Duration(seconds: attempt + 1));
          continue;
        } else {
          throw ApiException('API Error: ${response.statusCode} - ${response.body}');
        }
      } catch (e) {
        print('API request attempt $attempt failed: $e');
        if (attempt == retries) rethrow;
        await Future.delayed(Duration(seconds: attempt + 1));
      }
    }
    
    return null;
  }

  // Get real market prices from government API
  static Future<List<MarketItem>> getMarketPrices({String? location, String? state}) async {
    try {
      // Prepare query parameters for the API
      Map<String, String> queryParams = {
        'api-key': ApiConfig.MARKET_API_KEY,
        'format': 'json',
        'filters[Arrival_Date]' : '26/09/2025',
        'limit': '20',
      };

      // Add filters if provided
      if (state != null && state.isNotEmpty) {
        queryParams['filters[State]'] = state;
      }
      if (location != null && location.isNotEmpty) {
        queryParams['filters[District]'] = location;
      }

      final response = await _makeRequest(
        ApiConfig.MARKET_API_BASE_URL,
        queryParams: queryParams,
      );

      if (response != null) {
        final data = jsonDecode(response.body);
        
        if (data['records'] != null && data['records'] is List) {
          List<dynamic> records = data['records'];
          print('Found ${records.length} market records');
          
          return records.map((record) {
            return MarketItem(
              id: record['Commodity_Code']?.toString() ?? 
                  DateTime.now().millisecondsSinceEpoch.toString(),
              mandiName: _translateText(record['Market'] ?? 'Market'),
              commodity: _translateText(record['Commodity'] ?? 'Commodity'),
              price: _parsePrice(record['Modal_Price'] ?? 
                     record['Max_Price'] ?? 
                     record['Min_Price'] ?? '0'),
              unit: 'quintal',
              trend: _calculateTrend(record['Min_Price'], record['Max_Price']),
              lastUpdated: _parseDate(record['Arrival_Date']) ?? DateTime.now(),
              location: record['District'] ?? record['State'] ?? 'Unknown',
            );
          }).toList();
        } else {
          print('No records found in API response');
          throw ApiException('No market data available');
        }
      }
    } catch (e) {
      print('Market API Error: $e');
      // Return demo data if API fails
      return _getDemoMarketData(location);
    }
    
    // Fallback to demo data
    return _getDemoMarketData(location);
  }

  // Get weather information from OpenWeatherMap
  static Future<Weather> getWeather({String? location}) async {
    try {
      final position = await LocationService.getCurrentLocation();
      final lat = position.latitude.toString();
      final lon = position.longitude.toString();
      print(lat);
      print(lon);

      Map<String, String> queryParams = {
        'lat': lat,
        'lon': lon,
        'appid': ApiConfig.WEATHER_API_KEY,
        'units': 'metric',
        'lang': _getWeatherLanguage(),
      };

      final response = await _makeRequest(
        '${ApiConfig.WEATHER_API_URL}/weather',
        queryParams: queryParams,
      );

      if (response != null) {
        final data = jsonDecode(response.body);
        
        return Weather(
          location: data['name'] ?? location ?? 'Unknown',
          condition: data['weather'][0]['main']?.toLowerCase() ?? 'clear',
          temperature: (data['main']['temp'] ?? 25.0).toDouble(),
          humidity: data['main']['humidity'] ?? 60,
          description: _translateWeatherDescription(
            data['weather'][0]['description'] ?? 'Clear sky'
          ),
          advice: _generateWeatherAdvice(data),
          alerts: [], // Can be populated from weather alerts API
          timestamp: DateTime.now(),
          iconCode: _mapWeatherIcon(data['weather'][0]['icon'] ?? '01d'),
        );
      }
    } catch (e) {
      print('Weather API Error: $e');
    }
    
    // Fallback demo weather
    return _getDemoWeather(location);
  }

  // Parse price from string to double
  static double _parsePrice(String priceStr) {
    try {
      String cleanPrice = priceStr.replaceAll(RegExp(r'[^\d.]'), '');
      return double.parse(cleanPrice);
    } catch (e) {
      return 0.0;
    }
  }

  // Calculate trend based on min and max prices
  static double _calculateTrend(dynamic minPrice, dynamic maxPrice) {
    try {
      double min = _parsePrice(minPrice?.toString() ?? '0');
      double max = _parsePrice(maxPrice?.toString() ?? '0');
      if (min > 0 && max > 0) {
        return ((max - min) / min) * 100;
      }
      return 0.0;
    } catch (e) {
      return 0.0;
    }
  }

  // Parse date from API response (handles DD/MM/YYYY format)
  static DateTime? _parseDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return null;
    
    try {
      if (dateStr.contains('/')) {
        List<String> parts = dateStr.split('/');
        if (parts.length == 3) {
          return DateTime(
            int.parse(parts[2]), // year
            int.parse(parts[1]), // month
            int.parse(parts[0]), // day
          );
        }
      } else if (dateStr.contains('-')) {
        return DateTime.parse(dateStr);
      }
    } catch (e) {
      print('Date parsing error: $e');
    }
    
    return DateTime.now();
  }

  // Translate text based on current language
  static String _translateText(String text) {
    String currentLang = TranslationService.getCurrentLanguage();
    
    // Basic commodity translations
    Map<String, Map<String, String>> translations = {
      'wheat': {'pa': 'ਕਣਕ', 'hi': 'गेहूं', 'en': 'Wheat'},
      'rice': {'pa': 'ਚਾਵਲ', 'hi': 'चावल', 'en': 'Rice'},
      'maize': {'pa': 'ਮੱਕੀ', 'hi': 'मक्का', 'en': 'Maize'},
      'cotton': {'pa': 'ਕਪਾਸ', 'hi': 'कपास', 'en': 'Cotton'},
      'sugarcane': {'pa': 'ਗੰਨਾ', 'hi': 'गन्ना', 'en': 'Sugarcane'},
    };
    
    String lowerText = text.toLowerCase();
    for (String key in translations.keys) {
      if (lowerText.contains(key)) {
        return translations[key]?[currentLang] ?? text;
      }
    }
    
    return text;
  }

  // Get language code for weather API
  static String _getWeatherLanguage() {
    String currentLang = TranslationService.getCurrentLanguage();
    switch (currentLang) {
      case 'pa': return 'hi'; // Use Hindi for Punjabi (closest available)
      case 'hi': return 'hi';
      case 'en': return 'en';
      default: return 'en';
    }
  }

  // Translate weather description
  static String _translateWeatherDescription(String description) {
    String currentLang = TranslationService.getCurrentLanguage();
    
    Map<String, Map<String, String>> weatherTranslations = {
      'clear sky': {
        'pa': 'ਸਾਫ ਅਸਮਾਨ',
        'hi': 'साफ आसमान',
        'en': 'Clear sky'
      },
      'few clouds': {
        'pa': 'ਕੁਝ ਬੱਦਲ',
        'hi': 'कुछ बादल',
        'en': 'Few clouds'
      },
      'scattered clouds': {
        'pa': 'ਬਿਖਰੇ ਬੱਦਲ',
        'hi': 'बिखरे बादल',
        'en': 'Scattered clouds'
      },
      'broken clouds': {
        'pa': 'ਅੱਧੇ ਬੱਦਲ',
        'hi': 'आधे बादल',
        'en': 'Broken clouds'
      },
      'light rain': {
        'pa': 'ਹਲਕੀ ਬਾਰਿਸ਼',
        'hi': 'हल्की बारिश',
        'en': 'Light rain'
      },
      'moderate rain': {
        'pa': 'ਮੱਧਮ ਬਾਰਿਸ਼',
        'hi': 'मध्यम बारिश',
        'en': 'Moderate rain'
      },
    };
    
    String lowerDesc = description.toLowerCase();
    for (String key in weatherTranslations.keys) {
      if (lowerDesc.contains(key)) {
        return weatherTranslations[key]?[currentLang] ?? description;
      }
    }
    
    return description;
  }

  // Generate weather advice based on conditions
  static String _generateWeatherAdvice(Map<String, dynamic> weatherData) {
    String currentLang = TranslationService.getCurrentLanguage();
    
    double temp = (weatherData['main']['temp'] ?? 25.0).toDouble();
    int humidity = weatherData['main']['humidity'] ?? 60;
    String condition = weatherData['weather'][0]['main']?.toLowerCase() ?? 'clear';
    
    if (condition.contains('rain')) {
      return currentLang == 'pa' 
        ? 'ਅੱਜ ਸਿੰਚਾਈ ਨਾ ਕਰੋ'
        : currentLang == 'hi'
          ? 'आज सिंचाई न करें'
          : 'Don\'t irrigate today';
    } else if (temp > 35) {
      return currentLang == 'pa' 
        ? 'ਗਰਮੀ ਬਹੁਤ ਹੈ, ਸਵੇਰੇ ਸਿੰਚਾਈ ਕਰੋ'
        : currentLang == 'hi'
          ? 'गर्मी बहुत है, सुबह सिंचाई करें'
          : 'Very hot, irrigate in early morning';
    } else if (humidity < 30) {
      return currentLang == 'pa' 
        ? 'ਨਮੀ ਘੱਟ ਹੈ, ਪਾਣੀ ਦਿਓ'
        : currentLang == 'hi'
          ? 'नमी कम है, पानी दें'
          : 'Low humidity, water the crops';
    } else {
      return currentLang == 'pa' 
        ? 'ਮੌਸਮ ਖੇਤੀ ਲਈ ਚੰਗਾ ਹੈ'
        : currentLang == 'hi'
          ? 'मौसम खेती के लिए अच्छा है'
          : 'Weather is good for farming';
    }
  }

  // Map weather icon codes
  static String _mapWeatherIcon(String iconCode) {
    if (iconCode.startsWith('01')) return 'sun';
    if (iconCode.startsWith('02') || iconCode.startsWith('03')) return 'cloud';
    if (iconCode.startsWith('04')) return 'cloud';
    if (iconCode.startsWith('09') || iconCode.startsWith('10')) return 'rain';
    if (iconCode.startsWith('11')) return 'rain';
    return 'sun';
  }

  // Demo market data fallback
  static List<MarketItem> _getDemoMarketData(String? location) {
    String currentLang = TranslationService.getCurrentLanguage();
    
    return [
      MarketItem(
        id: '1',
        mandiName: currentLang == 'pa' ? 'ਮੁੱਖ ਮੰਡੀ' : currentLang == 'hi' ? 'मुख्य मंडी' : 'Main Market',
        commodity: currentLang == 'pa' ? 'ਕਣਕ' : currentLang == 'hi' ? 'गेहूं' : 'Wheat',
        price: 2100,
        unit: 'quintal',
        trend: 50,
        lastUpdated: DateTime.now(),
        location: location ?? (currentLang == 'pa' ? 'ਪੰਜਾਬ' : currentLang == 'hi' ? 'पंजाब' : 'Punjab'),
      ),
      MarketItem(
        id: '2',
        mandiName: currentLang == 'pa' ? 'ਮੁੱਖ ਮੰਡੀ' : currentLang == 'hi' ? 'मुख्य मंडी' : 'Main Market',
        commodity: currentLang == 'pa' ? 'ਚਾਵਲ' : currentLang == 'hi' ? 'चावल' : 'Rice',
        price: 1800,
        unit: 'quintal',
        trend: -30,
        lastUpdated: DateTime.now(),
        location: location ?? (currentLang == 'pa' ? 'ਪੰਜਾਬ' : currentLang == 'hi' ? 'पंजाब' : 'Punjab'),
      ),
    ];
  }

  // Demo weather fallback
  static Weather _getDemoWeather(String? location) {
    String currentLang = TranslationService.getCurrentLanguage();
    
    return Weather(
      location: location ?? (currentLang == 'pa' ? 'ਪੰਜਾਬ' : currentLang == 'hi' ? 'पंजाब' : 'Punjab'),
      condition: 'partly_cloudy',
      temperature: 28.5,
      humidity: 65,
      description: currentLang == 'pa' 
        ? 'ਅੱਜ ਅੱਧੇ ਬੱਦਲ ਹਨ, ਬਰਸਾਤ ਦੀ ਸੰਭਾਵਨਾ'
        : currentLang == 'hi'
          ? 'आज आंशिक बादल, बारिश की संभावना'
          : 'Partly cloudy today, chance of rain',
      advice: currentLang == 'pa'
        ? 'ਅੱਜ ਸਿੰਚਾਈ ਨਾ ਕਰੋ'
        : currentLang == 'hi'
          ? 'आज सिंचाई न करें'
          : 'Don\'t irrigate today',
      alerts: [],
      timestamp: DateTime.now(),
      iconCode: 'cloud',
    );
  }

  // Get crop advice (keeping existing implementation)
  static Future<Advice> getAdvice({
    required String cropType,
    required String soilType,
    String? location,
  }) async {
    // Return demo advice for now
    return Advice(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      cropType: cropType,
      soilType: soilType,
      recommendation: TranslationService.getCurrentLanguage() == 'pa' 
        ? 'ਇਸ ਮੌਸਮ ਵਿੱਚ ਪਾਣੀ ਦੀ ਮਾਤਰਾ ਘੱਟ ਕਰੋ ਅਤੇ ਜੈਵਿਕ ਖਾਦ ਵਰਤੋ'
        : TranslationService.getCurrentLanguage() == 'hi'
          ? 'इस मौसम में पानी की मात्रा कम करें और जैविक खाद का प्रयोग करें'
          : 'Reduce water quantity this season and use organic fertilizer',
      expectedYield: '3.2 t/ha',
      fertilizer: 'N:40kg, P:30kg, K:20kg',
      steps: [
        TranslationService.getCurrentLanguage() == 'pa' ? 'ਪਹਿਲੇ ਖੇਤ ਦੀ ਤਿਆਰੀ ਕਰੋ' 
          : TranslationService.getCurrentLanguage() == 'hi' ? 'पहले खेत की तैयारी करें'
          : 'First prepare the field',
        TranslationService.getCurrentLanguage() == 'pa' ? 'ਬੀਜ ਬੀਜੋ' 
          : TranslationService.getCurrentLanguage() == 'hi' ? 'बीज बोएं'
          : 'Sow seeds',
        TranslationService.getCurrentLanguage() == 'pa' ? 'ਸਮੇਂ ਸਿਰ ਪਾਣੀ ਦਿਓ' 
          : TranslationService.getCurrentLanguage() == 'hi' ? 'समय पर पानी दें'
          : 'Water on time',
      ],
      timestamp: DateTime.now(),
      language: TranslationService.getCurrentLanguage(),
    );
  }

  // Upload pest image (keeping existing implementation)
  static Future<PestReport> uploadPestImage(String imagePath) async {
    // Return demo pest report
    return PestReport(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      imagePath: imagePath,
      cropType: TranslationService.getCurrentLanguage() == 'pa' ? 'ਕਣਕ' 
        : TranslationService.getCurrentLanguage() == 'hi' ? 'गेहूं' : 'Wheat',
      pestDetected: TranslationService.getCurrentLanguage() == 'pa' ? 'ਅਫਿਡ' 
        : TranslationService.getCurrentLanguage() == 'hi' ? 'एफिड' : 'Aphid',
      remedy: TranslationService.getCurrentLanguage() == 'pa' ? 'ਨੀਮ ਦਾ ਤੇਲ ਸਪ੍ਰੇ ਕਰੋ' 
        : TranslationService.getCurrentLanguage() == 'hi' ? 'नीम का तेल स्प्रे करें' : 'Spray neem oil',
      remedySteps: [
        TranslationService.getCurrentLanguage() == 'pa' ? 'ਨੀਮ ਦਾ ਤੇਲ 10ml ਪਾਣੀ 1 ਲੀਟਰ ਵਿੱਚ ਮਿਲਾਓ'
          : TranslationService.getCurrentLanguage() == 'hi' ? 'नीम का तेल 10ml पानी 1 लीटर में मिलाएं'
          : 'Mix 10ml neem oil in 1 liter water',
        TranslationService.getCurrentLanguage() == 'pa' ? 'ਸਵੇਰੇ ਜਾਂ ਸ਼ਾਮ ਨੂੰ ਛਿੜਕਾਅ ਕਰੋ'
          : TranslationService.getCurrentLanguage() == 'hi' ? 'सुबह या शाम को छिड़काव करें'
          : 'Spray in morning or evening',
        TranslationService.getCurrentLanguage() == 'pa' ? '7 ਦਿਨ ਬਾਅਦ ਦੁਹਰਾਓ'
          : TranslationService.getCurrentLanguage() == 'hi' ? '7 दिन बाद दोहराएं'
          : 'Repeat after 7 days',
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