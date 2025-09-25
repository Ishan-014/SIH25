// services/translation_service.dart
import 'storage_service.dart';

class TranslationService {
  static String _currentLanguage = 'pa'; // Default to Punjabi
  static Map<String, Map<String, String>> _translations = {};
  static List<Function()> _languageChangeListeners = [];

  static Future<void> init() async {
    await _loadTranslations();
    _currentLanguage = StorageService.getCurrentLanguage();
  }

  static void addLanguageChangeListener(Function() listener) {
    _languageChangeListeners.add(listener);
  }

  static void removeLanguageChangeListener(Function() listener) {
    _languageChangeListeners.remove(listener);
  }

  static void _notifyLanguageChange() {
    for (var listener in _languageChangeListeners) {
      listener();
    }
  }

  static Future<void> _loadTranslations() async {
    _translations = {
      // Main App
      'app_name': {
        'pa': 'ਕਿਸਾਨ ਮਿੱਤਰ',
        'hi': 'किसान मित्र',
        'en': 'Farmer Friend'
      },
      'greeting': {
        'pa': 'ਸਤ ਸ੍ਰੀ ਅਕਾਲ ਕਿਸਾਨ ਮਿੱਤਰ! ਸਲਾਹ ਚਾਹੀਦੀ ਜਾਂ ਮੰਡੀ ਦੇਖਣੀ?',
        'hi': 'नमस्ते किसान मित्र! सलाह चाहिए या बाज़ार देखना है?',
        'en': 'Hello farmer friend! Need advice or check market prices?'
      },
      
      // Navigation Labels
      'advice': {
        'pa': 'ਸਲਾਹ',
        'hi': 'सलाह',
        'en': 'Advice'
      },
      'weather': {
        'pa': 'ਮੌਸਮ',
        'hi': 'मौसम',
        'en': 'Weather'
      },
      'market': {
        'pa': 'ਮੰਡੀ',
        'hi': 'बाज़ार',
        'en': 'Market'
      },
      'pest_photo': {
        'pa': 'ਕੀਟ ਫੋਟੋ',
        'hi': 'कीट फोटो',
        'en': 'Pest Photo'
      },
      'call_expert': {
        'pa': 'ਮਾਹਿਰ ਨੂੰ ਕਾਲ',
        'hi': 'विशेषज्ञ को कॉल',
        'en': 'Call Expert'
      },
      'history': {
        'pa': 'ਇਤਿਹਾਸ',
        'hi': 'इतिहास',
        'en': 'History'
      },
      'settings': {
        'pa': 'ਸੈਟਿੰਗ',
        'hi': 'सेटिंग',
        'en': 'Settings'
      },
      
      // Action Buttons
      'speak': {
        'pa': 'ਬੋਲੋ',
        'hi': 'बोलें',
        'en': 'Speak'
      },
      'get_advice': {
        'pa': 'ਸਲਾਹ ਲਓ',
        'hi': 'सलाह लें',
        'en': 'Get Advice'
      },
      'save': {
        'pa': 'ਸੇਵ ਕਰੋ',
        'hi': 'सहेजें',
        'en': 'Save'
      },
      'upload': {
        'pa': 'ਅਪਲੋਡ ਕਰੋ',
        'hi': 'अपलोड करें',
        'en': 'Upload'
      },
      'take_photo': {
        'pa': 'ਫੋਟੋ ਲਓ',
        'hi': 'फोटो लें',
        'en': 'Take Photo'
      },
      'retry': {
        'pa': 'ਦੁਬਾਰਾ ਕੋਸ਼ਿਸ਼',
        'hi': 'पुनः प्रयास',
        'en': 'Try Again'
      },
      'refresh': {
        'pa': 'ਤਾਜ਼ਾ ਕਰੋ',
        'hi': 'रिफ्रेश करें',
        'en': 'Refresh'
      },
      'new': {
        'pa': 'ਨਵਾਂ',
        'hi': 'नया',
        'en': 'New'
      },
      'gallery': {
        'pa': 'ਗੈਲਰੀ',
        'hi': 'गैलरी',
        'en': 'Gallery'
      },
      'yes': {
        'pa': 'ਹਾਂ',
        'hi': 'हाँ',
        'en': 'Yes'
      },
      'no': {
        'pa': 'ਨਹੀਂ',
        'hi': 'नहीं',
        'en': 'No'
      },
      'ok': {
        'pa': 'ਠੀਕ ਹੈ',
        'hi': 'ठीक है',
        'en': 'OK'
      },
      'close': {
        'pa': 'ਬੰਦ ਕਰੋ',
        'hi': 'बंद करें',
        'en': 'Close'
      },
      'delete': {
        'pa': 'ਡਿਲੀਟ ਕਰੋ',
        'hi': 'डिलीट करें',
        'en': 'Delete'
      },
      'share': {
        'pa': 'ਸ਼ੇਅਰ ਕਰੋ',
        'hi': 'शेयर करें',
        'en': 'Share'
      },
      'listen': {
        'pa': 'ਸੁਣੋ',
        'hi': 'सुनें',
        'en': 'Listen'
      },
      
      // Advice Screen
      'advice_prompt': {
        'pa': 'ਕਿਰਪਾ ਕਰਕੇ ਆਪਣੀ ਫਸਲ ਚੁਣੋ',
        'hi': 'कृपया अपनी फसल चुनें',
        'en': 'Please select your crop'
      },
      'select_crop': {
        'pa': 'ਫਸਲ ਚੁਣੋ:',
        'hi': 'फसल चुनें:',
        'en': 'Select Crop:'
      },
      'soil_type': {
        'pa': 'ਮਿੱਟੀ ਦੀ ਕਿਸਮ:',
        'hi': 'मिट्टी का प्रकार:',
        'en': 'Soil Type:'
      },
      'wheat': {
        'pa': 'ਕਣਕ',
        'hi': 'गेहूँ',
        'en': 'Wheat'
      },
      'rice': {
        'pa': 'ਚਾਵਲ',
        'hi': 'चावल',
        'en': 'Rice'
      },
      'maize': {
        'pa': 'ਮੱਕੀ',
        'hi': 'मक्का',
        'en': 'Maize'
      },
      'loamy_soil': {
        'pa': 'ਮਿਸ਼ਰਤ',
        'hi': 'दोमट',
        'en': 'Loamy'
      },
      'sandy_soil': {
        'pa': 'ਰੇਤਲੀ',
        'hi': 'बलुई',
        'en': 'Sandy'
      },
      'clay_soil': {
        'pa': 'ਮਿੱਟੀ',
        'hi': 'चिकनी',
        'en': 'Clay'
      },
      'expected_yield': {
        'pa': 'ਅਨੁਮਾਨਿਤ ਉਤਪਾਦਨ',
        'hi': 'अनुमानित उत्पादन',
        'en': 'Expected Yield'
      },
      'fertilizer': {
        'pa': 'ਖਾਦ',
        'hi': 'खाद',
        'en': 'Fertilizer'
      },
      'steps': {
        'pa': 'ਕਦਮ:',
        'hi': 'कदम:',
        'en': 'Steps:'
      },
      'advice_saved': {
        'pa': 'ਸਲਾਹ ਸੇਵ ਹੋ ਗਈ',
        'hi': 'सलाह सहेजी गई',
        'en': 'Advice saved'
      },
      
      // Weather Screen
      'temperature': {
        'pa': 'ਤਾਪਮਾਨ',
        'hi': 'तापमान',
        'en': 'Temperature'
      },
      'humidity': {
        'pa': 'ਨਮੀ',
        'hi': 'नमी',
        'en': 'Humidity'
      },
      'irrigation_yes': {
        'pa': 'ਸਿੰਚਾਈ ਕਰੋ',
        'hi': 'सिंचाई करें',
        'en': 'Do Irrigation'
      },
      'irrigation_no': {
        'pa': 'ਸਿੰਚਾਈ ਨਾ ਕਰੋ',
        'hi': 'सिंचाई न करें',
        'en': 'Don\'t Irrigate'
      },
      'weather_advice_good': {
        'pa': 'ਅੱਜ ਸਿੰਚਾਈ ਕਰਨਾ ਚੰਗਾ ਰਹੇਗਾ',
        'hi': 'आज सिंचाई करना अच्छा रहेगा',
        'en': 'Today is good for irrigation'
      },
      'weather_advice_bad': {
        'pa': 'ਅੱਜ ਸਿੰਚਾਈ ਦੀ ਜ਼ਰੂਰਤ ਨਹੀਂ',
        'hi': 'आज सिंचाई की जरूरत नहीं',
        'en': 'No need for irrigation today'
      },
      
      // Market Screen
      'market_prices': {
        'pa': 'ਮੰਡੀ ਦੇ ਭਾਅ ਦੇਖੋ',
        'hi': 'मंडी के भाव देखें',
        'en': 'Check Market Prices'
      },
      'market_notification': {
        'pa': 'ਮੰਡੀ ਦੀ ਜਾਣਕਾਰੀ',
        'hi': 'मंडी की जानकारी',
        'en': 'Market Information'
      },
      'price_notification_ask': {
        'pa': '{commodity} ਦੇ ਭਾਅ ਬਦਲਣ ਤੇ ਜਾਣਕਾਰੀ ਚਾਹੀਦੀ?',
        'hi': '{commodity} के भाव बदलने पर जानकारी चाहिए?',
        'en': 'Want notifications when {commodity} price changes?'
      },
      'notification_set': {
        'pa': 'ਜਾਣਕਾਰੀ ਸੈੱਟ ਹੋ ਗਈ',
        'hi': 'सूचना सेट हो गई',
        'en': 'Notification set'
      },
      'no_market_data': {
        'pa': 'ਕੋਈ ਮੰਡੀ ਦਾ ਡਾਟਾ ਨਹੀਂ ਮਿਲਿਆ',
        'hi': 'कोई मंडी का डेटा नहीं मिला',
        'en': 'No market data found'
      },
      'price_increased': {
        'pa': 'ਬੜ੍ਹਾ',
        'hi': 'बढ़ा',
        'en': 'Increased'
      },
      'price_decreased': {
        'pa': 'ਘਟਾ',
        'hi': 'घटा',
        'en': 'Decreased'
      },
      'price_stable': {
        'pa': 'ਸਥਿਰ',
        'hi': 'स्थिर',
        'en': 'Stable'
      },
      
      // Camera/Pest Screen
      'take_plant_photo': {
        'pa': 'ਪੱਤੇ ਜਾਂ ਪੌਧੇ ਦਾ ਫੋਟੋ ਲਓ',
        'hi': 'पत्ते या पौधे की फोटो लें',
        'en': 'Take photo of leaf or plant'
      },
      'photo_analysis_complete': {
        'pa': 'ਫੋਟੋ ਦਾ ਵਿਸ਼ਲੇਸ਼ਣ ਪੂਰਾ',
        'hi': 'फोटो का विश्लेषण पूरा',
        'en': 'Photo analysis complete'
      },
      'pest_detected': {
        'pa': 'ਪਾਇਆ ਗਿਆ:',
        'hi': 'पाया गया:',
        'en': 'Detected:'
      },
      'remedy_steps': {
        'pa': 'ਇਲਾਜ ਦੇ ਕਦਮ:',
        'hi': 'इलाज के कदम:',
        'en': 'Treatment Steps:'
      },
      'photo_taken': {
        'pa': 'ਫੋਟੋ ਲਿਆ ਗਿਆ',
        'hi': 'फोटो लिया गया',
        'en': 'Photo taken'
      },
      'report_saved': {
        'pa': 'ਰਿਪੋਰਟ ਸੇਵ ਹੋ ਗਈ',
        'hi': 'रिपोर्ट सेव हो गई',
        'en': 'Report saved'
      },
      'new_photo': {
        'pa': 'ਨਵਾਂ ਫੋਟੋ',
        'hi': 'नई फोटो',
        'en': 'New Photo'
      },
      
      // Settings Screen
      'language_settings': {
        'pa': 'ਭਾਸ਼ਾ / भाषा / Language',
        'hi': 'ਭਾਸ਼ਾ / भाषा / Language',
        'en': 'ਭਾਸ਼ਾ / भाषा / Language'
      },
      'app_info': {
        'pa': 'ਐਪ ਬਾਰੇ',
        'hi': 'ऐप के बारे में',
        'en': 'About App'
      },
      'version': {
        'pa': 'ਵਰਜਨ: 1.0.0',
        'hi': 'संस्करण: 1.0.0',
        'en': 'Version: 1.0.0'
      },
      'for_farmers': {
        'pa': 'ਛੋਟੇ ਤੇ ਸੀਮਾਂਤ ਕਿਸਾਨਾਂ ਲਈ',
        'hi': 'छोटे और सीमांत किसानों के लिए',
        'en': 'For small and marginal farmers'
      },
      'more_info': {
        'pa': 'ਵਧੇਰੇ ਜਾਣਕਾਰੀ',
        'hi': 'अधिक जानकारी',
        'en': 'More Information'
      },
      'app_description': {
        'pa': 'ਇਹ ਐਪ ਛੋਟੇ ਤੇ ਸੀਮਾਂਤ ਕਿਸਾਨਾਂ ਦੀ ਮਦਦ ਲਈ ਬਣਾਇਆ ਗਿਆ ਹੈ।\n\nਖੇਤੀ ਦੀ ਸਲਾਹ, ਮੌਸਮ ਦੀ ਜਾਣਕਾਰੀ, ਮੰਡੀ ਦੇ ਭਾਅ ਅਤੇ ਪੇਸਟ ਦੀ ਪਛਾਣ ਕਰਨ ਲਈ ਵਰਤੋ।',
        'hi': 'यह ऐप छोटे और सीमांत किसानों की सहायता के लिए बनाया गया है।\n\nखेती की सलाह, मौसम की जानकारी, मंडी के भाव और कीट पहचान के लिए उपयोग करें।',
        'en': 'This app is designed to help small and marginal farmers.\n\nUse it for farming advice, weather information, market prices and pest identification.'
      },
      'language_changed': {
        'pa': 'ਭਾਸ਼ਾ ਬਦਲੀ ਗਈ',
        'hi': 'भाषा बदली गई',
        'en': 'Language changed'
      },
      
      // History Screen
      'advice_history': {
        'pa': 'ਸਲਾਹ',
        'hi': 'सलाह',
        'en': 'Advice'
      },
      'pest_reports': {
        'pa': 'ਪੇਸਟ ਰਿਪੋਰਟ',
        'hi': 'कीट रिपोर्ट',
        'en': 'Pest Reports'
      },
      'no_saved_advice': {
        'pa': 'ਕੋਈ ਸੇਵ ਕੀਤੀ ਸਲਾਹ ਨਹੀਂ',
        'hi': 'कोई सहेजी गई सलाह नहीं',
        'en': 'No saved advice'
      },
      'no_pest_reports': {
        'pa': 'ਕੋਈ ਪੇਸਟ ਰਿਪੋਰਟ ਨਹੀਂ',
        'hi': 'कोई कीट रिपोर्ट नहीं',
        'en': 'No pest reports'
      },
      'delete_advice_confirm': {
        'pa': 'ਕੀ ਤੁਸੀਂ ਇਸ ਸਲਾਹ ਨੂੰ ਡਿਲੀਟ ਕਰਨਾ ਚਾਹੁੰਦੇ ਹੋ?',
        'hi': 'क्या आप इस सलाह को डिलीट करना चाहते हैं?',
        'en': 'Do you want to delete this advice?'
      },
      'delete_report_confirm': {
        'pa': 'ਕੀ ਤੁਸੀਂ ਇਸ ਰਿਪੋਰਟ ਨੂੰ ਡਿਲੀਟ ਕਰਨਾ ਚਾਹੁੰਦੇ ਹੋ?',
        'hi': 'क्या आप इस रिपोर्ट को डिलीट करना चाहते हैं?',
        'en': 'Do you want to delete this report?'
      },
      'advice_deleted': {
        'pa': 'ਸਲਾਹ ਡਿਲੀਟ ਹੋ ਗਈ',
        'hi': 'सलाह डिलीट हो गई',
        'en': 'Advice deleted'
      },
      'report_deleted': {
        'pa': 'ਰਿਪੋਰਟ ਡਿਲੀਟ ਹੋ ਗਈ',
        'hi': 'रिपोर्ट डिलीट हो गई',
        'en': 'Report deleted'
      },
      'share_feature_coming': {
        'pa': 'ਸ਼ੇਅਰ ਫੀਚਰ ਜਲਦੀ ਆਏਗਾ',
        'hi': 'शेयर फीचर जल्दी आएगा',
        'en': 'Share feature coming soon'
      },
      
      // Voice & System Messages
      'listening_prompt': {
        'pa': 'ਦੱਸੋ, ਮੈਂ ਸੁਣ ਰਿਹਾ ਹਾਂ',
        'hi': 'कहें, मैं सुन रहा हूँ',
        'en': 'Speak, I\'m listening'
      },
      'voice_command_help': {
        'pa': 'ਆਵਾਜ਼ ਦੀ ਮਦਦ ਨਾਲ ਨੈਵੀਗੇਟ ਕਰਨ ਲਈ:\n• "ਸਲਾਹ" - ਫਸਲ ਦੀ ਸਲਾਹ\n• "ਮੌਸਮ" - ਮੌਸਮ ਦੀ ਜਾਣਕਾਰੀ\n• "ਮੰਡੀ" - ਮਾਰਕੀਟ ਦੇ ਭਾਅ\n• "ਫੋਟੋ" - ਕੀਟ ਪਛਾਣ',
        'hi': 'आवाज की मदद से नेविगेट करने के लिए:\n• "सलाह" - फसल की सलाह\n• "मौसम" - मौसम की जानकारी\n• "मंडी" - बाज़ार के भाव\n• "फोटो" - कीट पहचान',
        'en': 'To navigate using voice:\n• "Advice" - Crop advice\n• "Weather" - Weather info\n• "Market" - Market prices\n• "Photo" - Pest detection'
      },
      'command_not_understood': {
        'pa': 'ਸਮਝ ਨਹੀਂ ਆਇਆ। ਦੁਬਾਰਾ ਕੋਸ਼ਿਸ਼ ਕਰੋ।',
        'hi': 'समझ नहीं आया। पुनः प्रयास करें।',
        'en': 'Could not understand. Please try again.'
      },
      'no_network': {
        'pa': 'ਨੈੱਟਵਰਕ ਨਹੀਂ ਮਿਲਿਆ - ਪੁਰਾਣਾ ਡਾਟਾ ਦਿਖਾ ਰਿਹਾ ਹਾਂ',
        'hi': 'नेटवर्क नहीं मिला - पुराना डेटा दिखा रहा हूँ',
        'en': 'No network - showing cached data'
      },
      'error_generic': {
        'pa': 'ਕੁਝ ਗਲਤ ਹੋਇਆ, ਦੁਬਾਰਾ ਕੋਸ਼ਿਸ਼ ਕਰੋ',
        'hi': 'कुछ गड़बड़ हुआ, पुनः प्रयास करें',
        'en': 'Something went wrong, try again'
      },
      'confirm_upload': {
        'pa': 'ਫੋਟੋ ਸਫਲਤਾ ਨਾਲ ਅਪਲੋਡ ਹੋਇਆ',
        'hi': 'फोटो सफलतापूर्वक अपलोड हुआ',
        'en': 'Photo uploaded successfully'
      },
      'location_permission_title': {
        'pa': 'ਸਥਾਨ ਦੀ ਇजਾਜ਼ਤ',
        'hi': 'स्थान की अनुमति',
        'en': 'Location Permission'
      },
      'location_permission_message': {
        'pa': 'ਮੌਸਮ ਅਤੇ ਮੰਡੀ ਦੀ ਸਹੀ ਜਾਣਕਾਰੀ ਲਈ ਆਪਣਾ ਸਥਾਨ ਸਾਂਝਾ ਕਰੋ।',
        'hi': 'मौसम और मंडी की सही जानकारी के लिए अपना स्थान साझा करें।',
        'en': 'Share your location for accurate weather and market information.'
      },
      'location_permission_allow': {
        'pa': 'ਇਜਾਜ਼ਤ ਦਿਓ',
        'hi': 'अनुमति दें',
        'en': 'Allow'
      },
      'location_permission_deny': {
        'pa': 'ਬਾਅਦ ਵਿੱਚ',
        'hi': 'बाद में',
        'en': 'Later'
      },
      'market_info': {
        'pa': '{mandi} ਵਿੱਚ {commodity} ਦਾ ਰੇਟ ₹{price} ਹੈ',
        'hi': '{mandi} में {commodity} का भाव ₹{price} है',
        'en': '{commodity} at {mandi} is ₹{price}'
      },
      'weather_alert': {
        'pa': '24 ਘੰਟਿਆਂ ਵਿੱਚ ਬਰਸਾਤ ਦੀ ਸੰਭਾਵਨਾ',
        'hi': '24 घंटे में बारिश की संभावना',
        'en': 'Rain expected in next 24 hours'
      },
      'help': {
        'pa': 'ਮਦਦ',
        'hi': 'सहायता',
        'en': 'Help'
      },
      'tips': {
        'pa': 'ਸੁਝਾਅ:',
        'hi': 'सुझाव:',
        'en': 'Tips:'
      },
      'replay': {
        'pa': 'ਦੁਬਾਰਾ ਸੁਣੋ',
        'hi': 'दोबारा सुनें',
        'en': 'Listen Again'
      },
      'voice_help_title': {
        'pa': 'ਆਵਾਜ਼ ਦੀ ਮਦਦ',
        'hi': 'आवाज़ की सहायता',
        'en': 'Voice Help'
      },
      'voice_instruction': {
        'pa': 'ਮਾਈਕ ਬਟਨ ਦਬਾਓ ਅਤੇ ਬੋਲੋ',
        'hi': 'माइक बटन दबाएं और बोलें',
        'en': 'Press mic button and speak'
      },
      'tap_here_to_speak': {
        'pa': 'ਇੱਥੇ ਦਬਾਓ ਤੇ ਬੋਲੋ',
        'hi': 'यहाँ दबाएं और बोलें',
        'en': 'Tap here and speak'
      }
    };
  }

  static String tr(String key, {Map<String, String>? params}) {
    String text = _translations[key]?[_currentLanguage] ?? 
                  _translations[key]?['en'] ?? 
                  key;
    
    // Replace parameters if provided
    if (params != null) {
      params.forEach((key, value) {
        text = text.replaceAll('{$key}', value);
      });
    }
    
    return text;
  }

  static Future<void> setLanguage(String language) async {
    _currentLanguage = language;
    await StorageService.setCurrentLanguage(language);
    _notifyLanguageChange();
  }

  static String getCurrentLanguage() => _currentLanguage;
  
  static List<String> getSupportedLanguages() => ['pa', 'hi', 'en'];
}