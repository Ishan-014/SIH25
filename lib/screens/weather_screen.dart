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
  }

  Future<void> _loadWeather() async {
    try {
      final weather = await ApiService.getWeather();
      
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
      // Load from cache if API fails
      final cachedWeather = await StorageService.getCachedWeather();
      
      setState(() {
        _weather = cachedWeather;
        _isLoading = false;
        _isFromCache = true;
      });
      
      if (cachedWeather != null) {
        await TTSService.speak(TranslationService.tr('no_network'));
        await TTSService.speak(cachedWeather.description);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(TranslationService.tr('weather')),
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _replayWeather,
            icon: Icon(Icons.volume_up),
          ),
          IconButton(
            onPressed: _refreshWeather,
            icon: Icon(Icons.refresh),
          ),
        ],
      ),
      body: _isLoading ? _buildLoading() : _buildWeatherContent(),
    );
  }

  Widget _buildLoading() {
    return Center(child: LoadingSpinner());
  }

  Widget _buildWeatherContent() {
    if (_weather == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              TranslationService.tr('error_generic'),
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _refreshWeather,
              child: Text('ਦੁਬਾਰਾ ਕੋਸ਼ਿਸ਼'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          if (_isFromCache) _buildCacheNotice(),
          _buildMainWeatherCard(),
          SizedBox(height: 16),
          _buildTemperatureCard(),
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
      child: Card(
        color: AppConstants.accentYellow,
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(Icons.warning, color: Colors.black87),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  TranslationService.tr('no_network'),
                  style: TextStyle(color: Colors.black87, fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainWeatherCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              _weather!.weatherIcon,
              size: 80,
              color: AppConstants.accentYellow,
            ),
            SizedBox(height: 16),
            Text(
              _weather!.location,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    _weather!.description,
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                ),
                IconButton(
                  onPressed: () => TTSService.speak(_weather!.description),
                  icon: Icon(Icons.volume_up),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTemperatureCard() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildWeatherStat(
              '${_weather!.temperature.toStringAsFixed(1)}°C',
              'ਤਾਪਮਾਨ',
              Icons.thermostat,
            ),
            _buildWeatherStat(
              '${_weather!.humidity}%',
              'ਨਮੀ',
              Icons.water_drop,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherStat(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 32, color: AppConstants.primaryGreen),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildAdviceCard() {
    if (_weather!.advice.isEmpty) return SizedBox.shrink();

    return Card(
      color: AppConstants.primaryGreen,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.lightbulb, color: Colors.white, size: 32),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                _weather!.advice,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            IconButton(
              onPressed: () => TTSService.speak(_weather!.advice),
              icon: Icon(Icons.volume_up, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: _weather!.advice.contains('ਸਿੰਚਾਈ ਨਾ') || _weather!.advice.contains('सिंचाई न')
              ? ElevatedButton.icon(
                  onPressed: () => _showIrrigationAlert(false),
                  icon: Icon(Icons.water_drop_outlined),
                  label: Text('ਸਿੰਚਾਈ ਨਾ ਕਰੋ'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppConstants.dangerRed),
                )
              : ElevatedButton.icon(
                  onPressed: () => _showIrrigationAlert(true),
                  icon: Icon(Icons.water_drop),
                  label: Text('ਸਿੰਚਾਈ ਕਰੋ'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppConstants.primaryGreen),
                ),
        ),
      ],
    );
  }

  Future<void> _replayWeather() async {
    if (_weather != null) {
      await TTSService.speak(_weather!.description);
      if (_weather!.advice.isNotEmpty) {
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
        title: Text(shouldIrrigate ? 'ਸਿੰਚਾਈ ਕਰੋ' : 'ਸਿੰਚਾਈ ਨਾ ਕਰੋ'),
        content: Text(
          shouldIrrigate 
            ? 'ਅੱਜ ਸਿੰਚਾਈ ਕਰਨਾ ਚੰਗਾ ਰਹੇਗਾ'
            : 'ਅੱਜ ਸਿੰਚਾਈ ਦੀ ਜ਼ਰੂਰਤ ਨਹੀਂ',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('ਠੀਕ ਹੈ'),
          ),
        ],
      ),
    );
  }
}