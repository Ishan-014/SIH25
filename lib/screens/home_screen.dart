// screens/home_screen.dart (Updated)
import 'package:flutter/material.dart';
import '../services/tts_service.dart';
import '../services/translation_service.dart';
import '../widgets/voice_button.dart';
import '../widgets/icon_tile.dart';
import '../main.dart';
import 'advice_screen.dart';
import 'weather_screen.dart';
import 'market_screen.dart';
import 'camera_screen.dart';
import 'settings_screen.dart';
import 'history_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  bool _isListening = false;
  bool _showVoiceHints = false;
  late AnimationController _hintAnimationController;
  late Animation<double> _hintOpacityAnimation;
  late Animation<Offset> _arrowAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _speakGreeting();
    });
    
    // Listen for language changes
    TranslationService.addLanguageChangeListener(_onLanguageChanged);
  }

  void _initializeAnimations() {
    _hintAnimationController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _hintOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _hintAnimationController,
      curve: Curves.easeInOut,
    ));
    
    _arrowAnimation = Tween<Offset>(
      begin: Offset(0, -0.1),
      end: Offset(0, 0.1),
    ).animate(CurvedAnimation(
      parent: _hintAnimationController,
      curve: Curves.elasticInOut,
    ));
    
    _hintAnimationController.repeat(reverse: true);
  }

  void _onLanguageChanged() {
    if (mounted) {
      setState(() {
        // Trigger rebuild with new language
      });
    }
  }

  Future<void> _speakGreeting() async {
    await TTSService.speak(TranslationService.tr('greeting'));
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
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildGreetingCard(),
                      _buildMainActions(),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              _buildVoiceSection(),
              SizedBox(height: 16),
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
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SettingsScreen()),
            ),
            child: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.settings,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                TranslationService.tr('app_name'),
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
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HistoryScreen()),
            ),
            child: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.history,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGreetingCard() {
    return Container(
      margin: EdgeInsets.all(20),
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppConstants.primaryGreen.withOpacity(0.2),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: AppConstants.primaryGradient,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  Icons.waving_hand,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      TranslationService.tr('greeting'),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppConstants.primaryText,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: _speakGreeting,
                child: Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppConstants.primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.volume_up,
                    color: AppConstants.primaryGreen,
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

  Widget _buildMainActions() {
    final actions = [
      {
        'icon': Icons.lightbulb,
        'label': TranslationService.tr('advice'),
        'gradient': AppConstants.primaryGradient,
        'screen': () => AdviceScreen(),
      },
      {
        'icon': Icons.wb_cloudy,
        'label': TranslationService.tr('weather'),
        'gradient': AppConstants.skyGradient,
        'screen': () => WeatherScreen(),
      },
      {
        'icon': Icons.store,
        'label': TranslationService.tr('market'),
        'gradient': AppConstants.sunsetGradient,
        'screen': () => MarketScreen(),
      },
      {
        'icon': Icons.camera_alt,
        'label': TranslationService.tr('pest_photo'),
        'gradient': AppConstants.earthGradient,
        'screen': () => CameraScreen(),
      },
    ];

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: actions.length,
        itemBuilder: (context, index) {
          final action = actions[index];
          return _buildActionTile(
            action['icon'] as IconData,
            action['label'] as String,
            action['gradient'] as LinearGradient,
            action['screen'] as Widget Function(),
          );
        },
      ),
    );
  }

  Widget _buildActionTile(IconData icon, String label, LinearGradient gradient, Widget Function() screenBuilder) {
    return GestureDetector(
      onTap: () {
        TTSService.speak(label);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => screenBuilder()),
        );
      },
      onLongPress: () => TTSService.speak(label),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background pattern
            Positioned(
              right: -20,
              top: -20,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            // Content
            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 5,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      icon,
                      color: AppConstants.primaryGreen,
                      size: 30,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black26,
                          offset: Offset(1, 1),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            // Voice hint arrows
            if (_showVoiceHints)
              Positioned(
                top: 10,
                right: 10,
                child: FadeTransition(
                  opacity: _hintOpacityAnimation,
                  child: SlideTransition(
                    position: _arrowAnimation,
                    child: Icon(
                      Icons.touch_app,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildVoiceSection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // Voice help button
          GestureDetector(
            onTap: _showVoiceHelp,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppConstants.accentYellow.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppConstants.accentYellow,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.help_outline,
                    color: AppConstants.primaryGreen,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    TranslationService.tr('voice_help_title'),
                    style: TextStyle(
                      color: AppConstants.primaryGreen,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),
          // Voice button
          Stack(
            children: [
              VoiceButton(
                isListening: _isListening,
                onPressed: _handleVoiceInput,
              ),
              // Hint overlay
              if (_showVoiceHints)
                Positioned.fill(
                  child: FadeTransition(
                    opacity: _hintOpacityAnimation,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(32),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SlideTransition(
                              position: _arrowAnimation,
                              child: Icon(
                                Icons.keyboard_arrow_down,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                            Text(
                              TranslationService.tr('tap_here_to_speak'),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _showVoiceHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.mic, color: AppConstants.primaryGreen),
            SizedBox(width: 8),
            Text(TranslationService.tr('voice_help_title')),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(TranslationService.tr('voice_command_help')),
            SizedBox(height: 16),
            Text(
              TranslationService.tr('voice_instruction'),
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(TranslationService.tr('close')),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _showVoiceHints = true;
              });
              // Hide hints after 5 seconds
              Future.delayed(Duration(seconds: 5), () {
                if (mounted) {
                  setState(() {
                    _showVoiceHints = false;
                  });
                }
              });
            },
            child: Text(TranslationService.tr('voice_instruction')),
          ),
        ],
      ),
    );
  }

  Future<void> _handleVoiceInput() async {
    setState(() => _isListening = true);
    
    try {
      // First check if speech recognition is available
      if (!TTSService.isSpeechAvailable) {
        AppUtils.showSnackBar(
          context, 
          TranslationService.getCurrentLanguage() == 'pa'
            ? 'ਮਾਈਕ ਦੀ ਇਜਾਜ਼ਤ ਦਰਕਾਰ ਹੈ'
            : TranslationService.getCurrentLanguage() == 'hi'
              ? 'माइक की अनुमति आवश्यक है'
              : 'Microphone permission required',
          isError: true,
        );
        return;
      }
      
      await TTSService.speak(TranslationService.tr('listening_prompt'));
      
      // Wait a moment for TTS to finish
      await Future.delayed(Duration(milliseconds: 1000));
      
      final result = await TTSService.listen();
      
      if (result != null && result.trim().isNotEmpty) {
        print('Voice input received: $result');
        _processVoiceCommand(result.toLowerCase().trim());
      } else {
        AppUtils.showSnackBar(
          context, 
          TranslationService.tr('command_not_understood'),
          isError: true,
        );
        // Show voice help after failed recognition
        Future.delayed(Duration(milliseconds: 500), () {
          _showVoiceHelp();
        });
      }
    } catch (e) {
      print('Voice input error: $e');
      AppUtils.showSnackBar(
        context, 
        TranslationService.tr('error_generic'), 
        isError: true,
      );
    } finally {
      setState(() => _isListening = false);
    }
  }

  void _processVoiceCommand(String command) {
    Widget? targetScreen;
    String commandLower = command.toLowerCase();
    
    // Enhanced voice command processing for multiple languages
    if (commandLower.contains('सलाह') || commandLower.contains('ਸਲਾਹ') || 
        commandLower.contains('advice') || commandLower.contains('salah')) {
      targetScreen = AdviceScreen();
    } else if (commandLower.contains('मौसम') || commandLower.contains('ਮੌਸਮ') || 
               commandLower.contains('weather') || commandLower.contains('mausam')) {
      targetScreen = WeatherScreen();
    } else if (commandLower.contains('मंडी') || commandLower.contains('ਮੰਡੀ') || 
               commandLower.contains('market') || commandLower.contains('बाज़ार') || 
               commandLower.contains('mandi') || commandLower.contains('bazaar')) {
      targetScreen = MarketScreen();
    } else if (commandLower.contains('फोटो') || commandLower.contains('ਫੋਟੋ') || 
               commandLower.contains('camera') || commandLower.contains('कीट') || 
               commandLower.contains('photo') || commandLower.contains('pest')) {
      targetScreen = CameraScreen();
    } else if (commandLower.contains('इतिहास') || commandLower.contains('ਇਤਿਹਾਸ') || 
               commandLower.contains('history') || commandLower.contains('itihas')) {
      targetScreen = HistoryScreen();
    } else if (commandLower.contains('सेटिंग') || commandLower.contains('ਸੈਟਿੰਗ') || 
               commandLower.contains('settings') || commandLower.contains('setting')) {
      targetScreen = SettingsScreen();
    }
    
    if (targetScreen != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => targetScreen!),
      );
    } else {
      AppUtils.showSnackBar(
        context, 
        TranslationService.tr('command_not_understood'),
        isError: true,
      );
      // Show voice help with examples
      Future.delayed(Duration(milliseconds: 500), () {
        _showVoiceHelp();
      });
    }
  }

  @override
  void dispose() {
    _hintAnimationController.dispose();
    TranslationService.removeLanguageChangeListener(_onLanguageChanged);
    super.dispose();
  }
}