// screens/weather_screen.dart
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/tts_service.dart';
import '../services/translation_service.dart';
import '../services/storage_service.dart';
import '../models/weather.dart';
import '../widgets/loading_spinner.dart';
import '../main.dart';

class WeatherScreen extends StatefulWidget {
  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  Weather? _weather;
  bool _isLoading = true;
  bool _isFromCache = false;

  @override
  void initState() {
    super.initState();
    _loadWeather();
    
    // Listen for language changes
    TranslationService.addLanguageChangeListener(_onLanguageChanged);
  }

  void _onLanguageChanged() {
    if (mounted) {
      setState(() {
        // Trigger rebuild with new language
      });
    }
  }

  Future<void> _loadWeather() async {
    try {
      // Get weather for Punjab, India (default location)
      final weather = await ApiService.getWeather(location: 'Punjab,IN');
      
      setState(() {
        _weather = weather;
        _isLoading = false;
        _isFromCache = false;
      });
      
      // Cache the weather data
      await StorageService.cacheWeather(weather);
      
      // Speak weather info
      await TTSService.speak(weather.description);
      
    } catch (e) {
      print('Weather API Error: $e');
      
      // Load from cache if API fails
      final cachedWeather = await StorageService.getCachedWeather();
      
      setState(() {
        _weather = cachedWeather;
        _isLoading = false;
        _isFromCache = true;
      });
      
      if (cachedWeather != null) {
        await TTSService.speak(TranslationService.tr('no_network'));
        await Future.delayed(Duration(milliseconds: 500));
        await TTSService.speak(cachedWeather.description);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppConstants.skyBlue,
              AppConstants.lightBackground,
            ],
            stops: [0.0, 0.4],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              Expanded(
                child: _isLoading ? _buildLoading() : _buildWeatherContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                TranslationService.tr('weather'),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Colors.black26,
                      offset: Offset(1, 1),
                      blurRadius: 2,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: _isLoading ? null : _replayWeather,
                child: Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.volume_up,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
              SizedBox(width: 8),
              GestureDetector(
                onTap: _refreshWeather,
                child: Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.refresh,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          LoadingSpinner(color: Colors.white),
          SizedBox(height: 16),
          Text(
            TranslationService.getCurrentLanguage() == 'pa' 
              ? 'ਮੌਸਮ ਦੀ ਜਾਣਕਾਰੀ ਲੋਡ ਹੋ ਰਹੀ...'
              : TranslationService.getCurrentLanguage() == 'hi'
                ? 'मौसम की जानकारी लोड हो रही...'
                : 'Loading weather information...',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherContent() {
    if (_weather == null) {
      return Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.white),
            SizedBox(height: 16),
            Text(
              TranslationService.tr('error_generic'),
              style: TextStyle(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _refreshWeather,
              icon: Icon(Icons.refresh),
              label: Text(TranslationService.tr('retry')),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppConstants.skyBlue,
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          if (_isFromCache) _buildCacheNotice(),
          _buildMainWeatherCard(),
          SizedBox(height: 16),
          _buildStatsCard(),
          SizedBox(height: 16),
          _buildAdviceCard(),
          SizedBox(height: 16),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildCacheNotice() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppConstants.accentYellow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.offline_bolt, color: Colors.black87),
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

  Widget _buildMainWeatherCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Weather icon and temperature
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: AppConstants.skyGradient,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  _weather!.weatherIcon,
                  size: 60,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_weather!.temperature.toStringAsFixed(1)}°C',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: AppConstants.primaryText,
                    ),
                  ),
                  Text(
                    _weather!.location,
                    style: TextStyle(
                      fontSize: 16,
                      color: AppConstants.mutedText,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          SizedBox(height: 20),
          
          // Weather description
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppConstants.skyBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _weather!.description,
                    style: TextStyle(
                      fontSize: 18,
                      color: AppConstants.primaryText,
                      fontWeight: FontWeight.w500,
                      height: 1.3,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                GestureDetector(
                  onTap: () => TTSService.speak(_weather!.description),
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppConstants.skyBlue.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.volume_up,
                      color: AppConstants.skyBlue,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: AppUtils.agriculturalCardDecoration,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildWeatherStat(
            '${_weather!.temperature.toStringAsFixed(1)}°C',
            TranslationService.tr('temperature'),
            Icons.thermostat,
            AppConstants.dangerRed,
          ),
          Container(
            height: 40,
            width: 1,
            color: Colors.grey.shade300,
          ),
          _buildWeatherStat(
            '${_weather!.humidity}%',
            TranslationService.tr('humidity'),
            Icons.water_drop,
            AppConstants.skyBlue,
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherStat(String value, String label, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 24, color: color),
        ),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppConstants.primaryText,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppConstants.mutedText,
          ),
        ),
      ],
    );
  }

  Widget _buildAdviceCard() {
    if (_weather!.advice.isEmpty) return SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppConstants.primaryGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppConstants.primaryGreen.withOpacity(0.3),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.lightbulb, color: Colors.white, size: 24),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Text(
              _weather!.advice,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
                height: 1.3,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => TTSService.speak(_weather!.advice),
            child: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.volume_up, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    bool shouldIrrigate = !(_weather!.advice.contains('ਸਿੰਚਾਈ ਨਾ') || 
                           _weather!.advice.contains('सिंचाई न') ||
                           _weather!.advice.contains('Don\'t irrigate') ||
                           _weather!.condition.contains('rain'));

    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _showIrrigationAlert(shouldIrrigate),
            icon: Icon(
              shouldIrrigate ? Icons.water_drop : Icons.water_drop_outlined,
              size: 20,
            ),
            label: Text(
              shouldIrrigate 
                ? TranslationService.tr('irrigation_yes')
                : TranslationService.tr('irrigation_no'),
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: shouldIrrigate 
                ? AppConstants.primaryGreen 
                : AppConstants.dangerRed,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _replayWeather() async {
    if (_weather != null) {
      await TTSService.speak(_weather!.description);
      if (_weather!.advice.isNotEmpty) {
        await Future.delayed(Duration(milliseconds: 500));
        await TTSService.speak(_weather!.advice);
      }
    }
  }

  Future<void> _refreshWeather() async {
    setState(() => _isLoading = true);
    await _loadWeather();
  }

  void _showIrrigationAlert(bool shouldIrrigate) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              shouldIrrigate ? Icons.water_drop : Icons.warning,
              color: shouldIrrigate ? AppConstants.primaryGreen : AppConstants.dangerRed,
            ),
            SizedBox(width: 8),
            Text(
              shouldIrrigate 
                ? TranslationService.tr('irrigation_yes')
                : TranslationService.tr('irrigation_no')
            ),
          ],
        ),
        content: Text(
          shouldIrrigate 
            ? TranslationService.tr('weather_advice_good')
            : TranslationService.tr('weather_advice_bad'),
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              TranslationService.tr('ok'),
              style: TextStyle(
                color: AppConstants.primaryGreen,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    TranslationService.removeLanguageChangeListener(_onLanguageChanged);
    super.dispose();
  }
}