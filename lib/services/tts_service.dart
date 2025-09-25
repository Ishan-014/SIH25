// services/tts_service.dart
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';
import 'translation_service.dart';

class TTSService {
  static FlutterTts _flutterTts = FlutterTts();
  static SpeechToText _speech = SpeechToText();
  static bool _isInitialized = false;
  static bool _speechInitialized = false;

  static Future<void> init() async {
    if (_isInitialized) return;
    
    try {
      // Initialize TTS
      await _flutterTts.setLanguage("hi-IN");
      await _flutterTts.setSpeechRate(0.7);
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);
      
      // Initialize speech recognition
      await _initializeSpeech();
      
      _isInitialized = true;
    } catch (e) {
      print('TTS Service initialization error: $e');
    }
  }

  static Future<void> _initializeSpeech() async {
    try {
      // Check and request microphone permission
      PermissionStatus permission = await Permission.microphone.status;
      
      if (permission.isDenied) {
        permission = await Permission.microphone.request();
      }
      
      if (permission.isGranted) {
        _speechInitialized = await _speech.initialize(
          onStatus: (status) => print('Speech status: $status'),
          onError: (error) => print('Speech error: $error'),
          debugLogging: true,
        );
        
        print('Speech initialized: $_speechInitialized');
      } else {
        print('Microphone permission denied');
      }
    } catch (e) {
      print('Speech initialization error: $e');
      _speechInitialized = false;
    }
  }

  static Future<void> speak(String text) async {
    if (!_isInitialized) await init();
    
    try {
      // Get current language
      String currentLang = TranslationService.getCurrentLanguage();
      String langCode = _getLanguageCode(currentLang);
      
      await _flutterTts.setLanguage(langCode);
      await _flutterTts.speak(text);
    } catch (e) {
      print('TTS speak error: $e');
    }
  }

  static Future<void> stop() async {
    try {
      await _flutterTts.stop();
    } catch (e) {
      print('TTS stop error: $e');
    }
  }

  static String _getLanguageCode(String language) {
    switch (language) {
      case 'pa':
        return 'pa-IN'; // Punjabi
      case 'hi':
        return 'hi-IN'; // Hindi
      case 'en':
        return 'en-US'; // English
      default:
        return 'hi-IN';
    }
  }

  // Enhanced Speech Recognition with proper error handling
  static Future<String?> listen({String? language}) async {
    if (!_isInitialized) await init();
    
    // Double check speech initialization
    if (!_speechInitialized) {
      await _initializeSpeech();
      if (!_speechInitialized) {
        print('Speech recognition not available');
        return null;
      }
    }

    // Check microphone permission again
    PermissionStatus permission = await Permission.microphone.status;
    if (!permission.isGranted) {
      permission = await Permission.microphone.request();
      if (!permission.isGranted) {
        print('Microphone permission required for voice input');
        return null;
      }
    }

    try {
      String langCode = _getLanguageCode(language ?? TranslationService.getCurrentLanguage());
      print('Listening with language: $langCode');
      
      String? recognizedText;
      bool isListening = false;
      
      await _speech.listen(
        onResult: (result) {
          recognizedText = result.recognizedWords;
          print('Recognized: $recognizedText');
        },
        listenFor: Duration(seconds: 5), // Listen for 5 seconds
        pauseFor: Duration(seconds: 2),  // Pause for 2 seconds of silence
        partialResults: true,
        onSoundLevelChange: (level) {
          // Optional: handle sound level changes
        },
        cancelOnError: true,
        listenMode: ListenMode.confirmation,
        localeId: langCode,
      );
      
      // Wait for listening to complete
      int attempts = 0;
      while (_speech.isListening && attempts < 50) { // Max 5 seconds wait
        await Future.delayed(Duration(milliseconds: 100));
        attempts++;
      }
      
      // Stop listening if still active
      if (_speech.isListening) {
        await _speech.stop();
      }
      
      print('Final recognized text: $recognizedText');
      return recognizedText?.isNotEmpty == true ? recognizedText : null;
      
    } catch (e) {
      print('Speech recognition error: $e');
      return null;
    }
  }

  static bool get isListening => _speech.isListening;
  
  static bool get isSpeechAvailable => _speechInitialized;
  
  static Future<void> stopListening() async {
    try {
      await _speech.stop();
    } catch (e) {
      print('Stop listening error: $e');
    }
  }
  
  // Get available locales for speech recognition
  static Future<List<String>> getAvailableLanguages() async {
    if (!_speechInitialized) await _initializeSpeech();
    
    try {
      var locales = await _speech.locales();
      return locales.map((locale) => locale.localeId).toList();
    } catch (e) {
      print('Get languages error: $e');
      return ['hi-IN', 'en-US', 'pa-IN'];
    }
  }
}