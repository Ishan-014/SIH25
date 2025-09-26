// lib/config/api_config.dart
class ApiConfig {
  // Replace with your actual API details
  static const String MARKET_API_BASE_URL = 'https://api.data.gov.in//resource/35985678-0d79-46b4-9ed6-6f13308a1d24';
  
  // Your API key - Replace 'YOUR_API_KEY_HERE' with actual key
  static const String MARKET_API_KEY = '579b464db66ec23bdd000001ffd44385f3ab478276f8b2a9242419b5';
  
  // Additional API endpoints if needed
  static const String WEATHER_API_URL = 'https://api.openweathermap.org/data/2.5';
  static const String WEATHER_API_KEY = 'ec3c955581d8c3d618e7d6a8d32cc931';
  
  // API request headers
  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  
  // Common API parameters
  static Map<String, String> get commonParams => {
    'api-key': MARKET_API_KEY,
    'format': 'json',
    'limit': '50',
  };
}