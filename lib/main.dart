// main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'services/tts_service.dart';
import 'services/storage_service.dart';
import 'services/translation_service.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize services
  await StorageService.init();
  await TTSService.init();
  await TranslationService.init();
  
  // Set preferred orientations (portrait only for simplicity)
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  
  runApp(FarmerApp());
}

class FarmerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'किसान मित्र',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Enhanced Colors with Agricultural Theme
        primaryColor: AppConstants.primaryGreen,
        scaffoldBackgroundColor: AppConstants.lightBackground,
        fontFamily: 'Roboto',
        
        // Enhanced Color Scheme
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppConstants.primaryGreen,
          brightness: Brightness.light,
          primary: AppConstants.primaryGreen,
          secondary: AppConstants.earthyBrown,
          surface: Colors.white,
          background: AppConstants.lightBackground,
          error: AppConstants.dangerRed,
        ),
        
        // Enhanced Button theme
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppConstants.primaryGreen,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 64),
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 4,
            shadowColor: AppConstants.primaryGreen.withOpacity(0.3),
          ),
        ),
        
        // Enhanced App bar theme
        appBarTheme: AppBarTheme(
          backgroundColor: AppConstants.primaryGreen,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
        ),
        
        // Enhanced Card theme
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 6,
          shadowColor: Colors.black.withOpacity(0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        ),
        
        // Enhanced Text theme
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppConstants.primaryText,
            height: 1.2,
          ),
          headlineMedium: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: AppConstants.primaryText,
            height: 1.3,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            color: AppConstants.primaryText,
            height: 1.5,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            color: AppConstants.mutedText,
            height: 1.4,
          ),
        ),
        
        // Enhanced Input Decoration
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey.shade50,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppConstants.primaryGreen, width: 2),
          ),
        ),
        
        // Enhanced Dialog Theme
        dialogTheme: DialogThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 8,
        ),
      ),
      home: SplashScreen(),
    );
  }
}

// Enhanced App constants with agricultural theme
class AppConstants {
  static const String appName = 'किसान मित्र';
  static const double buttonHeight = 64.0;
  static const double iconSize = 88.0;
  static const double minTouchTarget = 60.0;
  static const double basePadding = 16.0;
  static const double cardPadding = 16.0;
  
  // Enhanced Agricultural Color Palette
  static const Color primaryGreen = Color(0xFF2E7D32);    // Forest Green
  static const Color lightGreen = Color(0xFF66BB6A);      // Light Green
  static const Color darkGreen = Color(0xFF1B5E20);       // Dark Green
  
  static const Color accentYellow = Color(0xFFFBC02D);    // Golden Yellow
  static const Color lightYellow = Color(0xFFFFF176);     // Light Yellow
  
  static const Color earthyBrown = Color(0xFF8D6E63);     // Earthy Brown
  static const Color lightBrown = Color(0xFFBCAAA4);      // Light Brown
  
  static const Color skyBlue = Color(0xFF42A5F5);         // Sky Blue
  static const Color dangerRed = Color(0xFFE53935);       // Red for errors
  
  // Background colors
  static const Color lightBackground = Color(0xFFF8F9FA); // Very light background
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  
  // Text colors
  static const Color primaryText = Color(0xFF1B5E20);     // Dark green for text
  static const Color mutedText = Color(0xFF616161);
  static const Color lightText = Color(0xFF757575);
  
  // Agricultural themed gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryGreen, lightGreen],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient sunsetGradient = LinearGradient(
    colors: [accentYellow, lightYellow],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient earthGradient = LinearGradient(
    colors: [earthyBrown, lightBrown],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient skyGradient = LinearGradient(
    colors: [skyBlue, Color(0xFF81C784)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

// Enhanced utility functions
class AppUtils {
  static void showSnackBar(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: isError ? AppConstants.dangerRed : AppConstants.primaryGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.all(16),
        duration: Duration(seconds: 3),
        action: SnackBarAction(
          label: TranslationService.tr('ok'),
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }
  
  static Future<void> speakAndDelay(String text, {int delayMs = 500}) async {
    await TTSService.speak(text);
    await Future.delayed(Duration(milliseconds: delayMs));
  }
  
  // Agricultural themed decorations
  static BoxDecoration get agriculturalCardDecoration => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: AppConstants.primaryGreen.withOpacity(0.1),
        blurRadius: 8,
        offset: Offset(0, 4),
      ),
    ],
    border: Border.all(
      color: AppConstants.lightGreen.withOpacity(0.3),
      width: 1,
    ),
  );
  
  static BoxDecoration get primaryGradientDecoration => BoxDecoration(
    gradient: AppConstants.primaryGradient,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: AppConstants.primaryGreen.withOpacity(0.3),
        blurRadius: 12,
        offset: Offset(0, 6),
      ),
    ],
  );
}