// screens/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import '../services/tts_service.dart';
import '../services/translation_service.dart';
import '../services/storage_service.dart';
import 'home_screen.dart';
import '../main.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  bool _showLanguageSelection = false;
  bool _showLocationPermission = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _checkFirstTimeUser();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
    
    _animationController.forward();
  }

  Future<void> _checkFirstTimeUser() async {
    await Future.delayed(Duration(seconds: 2));
    
    bool isFirstTime = StorageService.getBool('is_first_time', defaultValue: true);
    
    if (isFirstTime) {
      setState(() {
        _showLanguageSelection = true;
      });
    } else {
      _navigateToHome();
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
              AppConstants.primaryGreen,
              AppConstants.lightGreen,
              AppConstants.accentYellow.withOpacity(0.3),
            ],
          ),
        ),
        child: SafeArea(
          child: _showLocationPermission 
              ? _buildLocationPermissionScreen()
              : _showLanguageSelection 
                  ? _buildLanguageSelection() 
                  : _buildSplashContent(),
        ),
      ),
    );
  }

  Widget _buildSplashContent() {
    return Center(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Agricultural themed icon
              Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 20,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.agriculture,
                  size: 80,
                  color: AppConstants.primaryGreen,
                ),
              ),
              SizedBox(height: 32),
              // App title with beautiful typography
              Text(
                TranslationService.tr('app_name'),
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Colors.black26,
                      offset: Offset(2, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12),
              Text(
                TranslationService.tr('for_farmers'),
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 40),
              // Loading indicator
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageSelection() {
    final languages = [
      {'code': 'pa', 'name': 'ਪੰਜਾਬੀ', 'flag': '🇮🇳', 'subtitle': 'Punjabi'},
      {'code': 'hi', 'name': 'हिंदी', 'flag': '🇮🇳', 'subtitle': 'Hindi'},
      {'code': 'en', 'name': 'English', 'flag': '🇬🇧', 'subtitle': 'English'},
    ];

    return Container(
      padding: EdgeInsets.all(24),
      child: Column(
        children: [
          Spacer(),
          // Welcome message
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(
                  Icons.language,
                  size: 60,
                  color: AppConstants.primaryGreen,
                ),
                SizedBox(height: 16),
                Text(
                  'ਭਾਸ਼ਾ ਚੁਣੋ / भाषा चुनें / Choose Language',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.primaryText,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text(
                  'किसान मित्र में आपका स्वागत है',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppConstants.mutedText,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          SizedBox(height: 32),
          // Language options
          ...languages.map((lang) => _buildLanguageButton(
            lang['code']!,
            lang['name']!,
            lang['flag']!,
            lang['subtitle']!,
          )).toList(),
          Spacer(),
        ],
      ),
    );
  }

  Widget _buildLanguageButton(String code, String name, String flag, String subtitle) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(vertical: 8),
      child: ElevatedButton(
        onPressed: () => _selectLanguage(code),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: AppConstants.primaryText,
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppConstants.primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(flag, style: TextStyle(fontSize: 24)),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppConstants.primaryText,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppConstants.mutedText,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => _playLanguageSample(code, name),
              icon: Icon(
                Icons.volume_up,
                color: AppConstants.primaryGreen,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationPermissionScreen() {
    return Container(
      padding: EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 15,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppConstants.primaryGreen.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.location_on,
                    size: 50,
                    color: AppConstants.primaryGreen,
                  ),
                ),
                SizedBox(height: 24),
                Text(
                  TranslationService.tr('location_permission_title'),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.primaryText,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                Text(
                  TranslationService.tr('location_permission_message'),
                  style: TextStyle(
                    fontSize: 16,
                    color: AppConstants.mutedText,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _handleLocationPermission(false),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppConstants.mutedText,
                          side: BorderSide(color: AppConstants.mutedText),
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(TranslationService.tr('location_permission_deny')),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () => _handleLocationPermission(true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppConstants.primaryGreen,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          TranslationService.tr('location_permission_allow'),
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _playLanguageSample(String code, String name) async {
    String sampleText = code == 'pa' 
      ? 'ਸਤ ਸ੍ਰੀ ਅਕਾਲ ਕਿਸਾਨ ਮਿੱਤਰ'
      : code == 'hi' 
        ? 'नमस्ते किसान मित्र'
        : 'Hello farmer friend';
    
    await TranslationService.setLanguage(code);
    await TTSService.speak(sampleText);
  }

  Future<void> _selectLanguage(String languageCode) async {
    await TranslationService.setLanguage(languageCode);
    await TTSService.speak(TranslationService.tr('language_changed'));
    
    // Show location permission screen
    setState(() {
      _showLocationPermission = true;
    });
  }

  Future<void> _handleLocationPermission(bool allow) async {
    if (allow) {
      // Request location permission
      LocationPermission permission = await Geolocator.requestPermission();
      
      if (permission == LocationPermission.denied) {
        // Permission denied, but app can still work
        AppUtils.showSnackBar(
          context, 
          TranslationService.tr('location_permission_message'),
          isError: true,
        );
      }
    }
    
    // Mark as not first time user
    await StorageService.setBool('is_first_time', false);
    
    // Navigate to home
    _navigateToHome();
  }

  void _navigateToHome() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => HomeScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: Duration(milliseconds: 500),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}