// screens/settings_screen.dart
import 'package:flutter/material.dart';
import '../services/tts_service.dart';
import '../services/translation_service.dart';
import '../main.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with TickerProviderStateMixin {
  String _currentLanguage = 'pa';
  late AnimationController _languageChangeController;
  late Animation<double> _languageChangeAnimation;

  @override
  void initState() {
    super.initState();
    _currentLanguage = TranslationService.getCurrentLanguage();
    
    _languageChangeController = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );
    
    _languageChangeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _languageChangeController,
      curve: Curves.easeInOut,
    ));

    // Listen for language changes to rebuild UI
    TranslationService.addLanguageChangeListener(_onLanguageChanged);
  }

  void _onLanguageChanged() {
    setState(() {
      _currentLanguage = TranslationService.getCurrentLanguage();
    });
    
    // Animate language change
    _languageChangeController.forward().then((_) {
      _languageChangeController.reverse();
    });
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
              AppConstants.lightBackground,
            ],
            stops: [0.0, 0.3],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              Expanded(
                child: AnimatedBuilder(
                  animation: _languageChangeAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: 1.0 + (_languageChangeAnimation.value * 0.02),
                      child: Opacity(
                        opacity: 1.0 - (_languageChangeAnimation.value * 0.1),
                        child: SingleChildScrollView(
                          padding: EdgeInsets.all(20),
                          child: Column(
                            children: [
                              _buildLanguageSection(),
                              SizedBox(height: 24),
                              _buildAboutSection(),
                              SizedBox(height: 24),
                              _buildPrideMessage(),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
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
                TranslationService.tr('settings'),
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
          SizedBox(width: 48), // Balance the back button
        ],
      ),
    );
  }

  Widget _buildLanguageSection() {
    final languages = [
      {
        'code': 'pa',
        'name': 'ਪੰਜਾਬੀ',
        'englishName': 'Punjabi',
        'flag': '🇮🇳',
        'description': TranslationService.getCurrentLanguage() == 'pa' 
          ? 'ਮੁੱਖ ਭਾਸ਼ਾ' 
          : TranslationService.getCurrentLanguage() == 'hi'
            ? 'मुख्य भाषा'
            : 'Primary Language'
      },
      {
        'code': 'hi',
        'name': 'हिंदी',
        'englishName': 'Hindi',
        'flag': '🇮🇳',
        'description': TranslationService.getCurrentLanguage() == 'pa' 
          ? 'ਰਾਸ਼ਟਰੀ ਭਾਸ਼ਾ' 
          : TranslationService.getCurrentLanguage() == 'hi'
            ? 'राष्ट्रीय भाषा'
            : 'National Language'
      },
      {
        'code': 'en',
        'name': 'English',
        'englishName': 'English',
        'flag': '🇬🇧',
        'description': TranslationService.getCurrentLanguage() == 'pa' 
          ? 'ਅੰਤਰਰਾਸ਼ਟਰੀ' 
          : TranslationService.getCurrentLanguage() == 'hi'
            ? 'अंतर्राष्ट्रीय'
            : 'International'
      },
    ];

    return Container(
      padding: EdgeInsets.all(24),
      decoration: AppUtils.agriculturalCardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: AppConstants.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.language,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      TranslationService.tr('language_settings'),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppConstants.primaryText,
                      ),
                    ),
                    Text(
                      TranslationService.getCurrentLanguage() == 'pa'
                        ? 'ਆਪਣੀ ਪਸੰਦੀਦਾ ਭਾਸ਼ਾ ਚੁਣੋ'
                        : TranslationService.getCurrentLanguage() == 'hi'
                          ? 'अपनी पसंदीदा भाषा चुनें'
                          : 'Choose your preferred language',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppConstants.mutedText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          ...languages.map((lang) => _buildLanguageOption(
            lang['code']!,
            lang['name']!,
            lang['englishName']!,
            lang['flag']!,
            lang['description']!,
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildLanguageOption(String code, String name, String englishName, String flag, String description) {
    final isSelected = _currentLanguage == code;

    return Container(
      margin: EdgeInsets.symmetric(vertical: 6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _changeLanguage(code),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected 
                ? AppConstants.primaryGreen.withOpacity(0.1) 
                : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected 
                  ? AppConstants.primaryGreen 
                  : Colors.grey.shade300,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: isSelected 
                      ? AppConstants.primaryGreen 
                      : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      flag,
                      style: TextStyle(fontSize: 24),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isSelected 
                                ? AppConstants.primaryGreen 
                                : AppConstants.primaryText,
                            ),
                          ),
                          if (englishName != name) ...[
                            SizedBox(width: 8),
                            Text(
                              '($englishName)',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppConstants.mutedText,
                              ),
                            ),
                          ],
                        ],
                      ),
                      SizedBox(height: 4),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppConstants.mutedText,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () => _playLanguageSample(code),
                      icon: Icon(
                        Icons.volume_up,
                        color: AppConstants.primaryGreen,
                      ),
                    ),
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected 
                          ? AppConstants.primaryGreen 
                          : Colors.transparent,
                        border: Border.all(
                          color: isSelected 
                            ? AppConstants.primaryGreen 
                            : Colors.grey.shade400,
                          width: 2,
                        ),
                      ),
                      child: isSelected
                        ? Icon(
                            Icons.check,
                            size: 12,
                            color: Colors.white,
                          )
                        : null,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAboutSection() {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: AppUtils.agriculturalCardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: AppConstants.sunsetGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.info,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              SizedBox(width: 16),
              Text(
                TranslationService.tr('app_info'),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.primaryText,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          _buildInfoRow(Icons.apps, TranslationService.tr('app_name')),
          _buildInfoRow(Icons.info_outline, TranslationService.tr('version')),
          _buildInfoRow(Icons.people, TranslationService.tr('for_farmers')),
          SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _showAppInfo,
              icon: Icon(Icons.info_outline),
              label: Text(TranslationService.tr('more_info')),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.accentYellow,
                foregroundColor: AppConstants.primaryText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppConstants.primaryGreen,
            size: 20,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 16,
                color: AppConstants.primaryText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrideMessage() {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppConstants.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppConstants.primaryGreen.withOpacity(0.3),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.favorite,
            color: Colors.white,
            size: 40,
          ),
          SizedBox(height: 16),
          Text(
            TranslationService.getCurrentLanguage() == 'pa'
              ? 'ਭਾਰਤ ਆਪਣੇ ਕਿਸਾਨਾਂ ਤੇ ਗਰਵ ਕਰਦਾ ਹੈ'
              : TranslationService.getCurrentLanguage() == 'hi'
                ? 'भारत अपने किसानों पर गर्व करता है'
                : 'India is proud of its farmers',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text(
            TranslationService.getCurrentLanguage() == 'pa'
              ? 'ਅੰਨਦਾਤਾ ਸੁਖੀ ਭਵਃ'
              : TranslationService.getCurrentLanguage() == 'hi'
                ? 'अन्नदाता सुखी भवः'
                : 'May the food providers be happy',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.9),
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Future<void> _playLanguageSample(String code) async {
    String sampleText = code == 'pa' 
      ? 'ਸਤ ਸ੍ਰੀ ਅਕਾਲ ਕਿਸਾਨ ਮਿੱਤਰ'
      : code == 'hi' 
        ? 'नमस्ते किसान मित्र'
        : 'Hello farmer friend';
    
    // Temporarily change language for sample
    String currentLang = TranslationService.getCurrentLanguage();
    await TranslationService.setLanguage(code);
    await TTSService.speak(sampleText);
    await TranslationService.setLanguage(currentLang);
  }

  Future<void> _changeLanguage(String languageCode) async {
    if (languageCode != _currentLanguage) {
      await TranslationService.setLanguage(languageCode);
      
      AppUtils.showSnackBar(context, TranslationService.tr('language_changed'));
      await TTSService.speak(TranslationService.tr('language_changed'));
    }
  }

  void _showAppInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: AppConstants.primaryGradient,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.agriculture,
                color: Colors.white,
                size: 20,
              ),
            ),
            SizedBox(width: 12),
            Text(TranslationService.tr('app_name')),
          ],
        ),
        content: SingleChildScrollView(
          child: Text(
            TranslationService.tr('app_description'),
            style: TextStyle(
              fontSize: 16,
              height: 1.5,
            ),
          ),
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
    _languageChangeController.dispose();
    TranslationService.removeLanguageChangeListener(_onLanguageChanged);
    super.dispose();
  }
}