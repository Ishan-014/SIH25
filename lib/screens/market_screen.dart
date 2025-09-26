// screens/market_screen.dart
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/tts_service.dart';
import '../services/translation_service.dart';
import '../services/storage_service.dart';
import '../models/market.dart';
import '../widgets/loading_spinner.dart';
import '../main.dart';

class MarketScreen extends StatefulWidget {
  @override
  _MarketScreenState createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  List<MarketItem> _marketItems = [];
  bool _isLoading = true;
  bool _isFromCache = false;

  @override
  void initState() {
    super.initState();
    _loadMarketData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      TTSService.speak(TranslationService.tr('market_prices'));
    });
    
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

  Future<void> _loadMarketData() async {
    try {
      // Fetch market items from API with Punjab as default state
      final items = await ApiService.getMarketPrices(state: 'Punjab');

      print('Fetched ${items.length} market items');
      for (var item in items) {
        print('Item: ${item.commodity} at ${item.mandiName} - Price: ₹${item.price}');
      }

      setState(() {
        _marketItems = items;
        _isLoading = false;
        _isFromCache = false;
      });

      // Cache the items locally
      await StorageService.cacheMarketItems(items);
    } catch (e) {
      print('Market API Error: $e');

      // Try to load cached data
      final cachedItems = await StorageService.getCachedMarketItems();

      setState(() {
        _marketItems = cachedItems;
        _isLoading = false;
        _isFromCache = true;
      });

      if (cachedItems.isNotEmpty) {
        await TTSService.speak(TranslationService.tr('no_network'));
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
                child: _isLoading ? _buildLoading() : _buildMarketContent(),
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
                TranslationService.tr('market'),
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
                onTap: () => TTSService.speak(TranslationService.tr('market_prices')),
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
                onTap: _refreshMarket,
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
          LoadingSpinner(),
          SizedBox(height: 16),
                      Text(
            TranslationService.getCurrentLanguage() == 'pa' 
              ? 'ਮੰਡੀ ਦੇ ਭਾਅ ਲੋਡ ਹੋ ਰਹੇ ਹਨ...'
              : TranslationService.getCurrentLanguage() == 'hi'
                ? 'मंडी के भाव लोड हो रहे हैं...'
                : 'Loading market prices...',
            style: TextStyle(
              color: AppConstants.primaryText,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarketContent() {
    if (_marketItems.isEmpty) {
      return Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.store_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              TranslationService.tr('no_market_data'),
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _refreshMarket,
              icon: Icon(Icons.refresh),
              label: Text(TranslationService.tr('retry')),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        if (_isFromCache) _buildCacheNotice(),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _refreshMarket,
            child: ListView.builder(
              padding: EdgeInsets.all(20),
              itemCount: _marketItems.length,
              itemBuilder: (context, index) {
                return _buildMarketItemCard(_marketItems[index]);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCacheNotice() {
    return Container(
      width: double.infinity,
      color: AppConstants.accentYellow,
      padding: EdgeInsets.all(12),
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

  Widget _buildMarketItemCard(MarketItem item) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      padding: EdgeInsets.all(20),
      decoration: AppUtils.agriculturalCardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with market name and trend
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: AppConstants.sunsetGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.store,
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
                      item.mandiName,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppConstants.primaryText,
                      ),
                    ),
                    Text(
                      item.location,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppConstants.mutedText,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: item.trendColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      item.trendIcon,
                      size: 16,
                      color: item.trendColor,
                    ),
                    SizedBox(width: 4),
                    Text(
                      item.trendText,
                      style: TextStyle(
                        color: item.trendColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          SizedBox(height: 16),
          
          // Commodity and price section
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppConstants.primaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppConstants.primaryGreen.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.commodity,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppConstants.primaryGreen,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '${TranslationService.getCurrentLanguage() == 'pa' ? 'ਪ੍ਰਤੀ' : TranslationService.getCurrentLanguage() == 'hi' ? 'प्रति' : 'per'} ${item.unit}',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppConstants.mutedText,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₹${item.price.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppConstants.primaryGreen,
                      ),
                    ),
                    if (item.trend != 0)
                      Text(
                        '${item.trend > 0 ? '+' : ''}${item.trend.toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 12,
                          color: item.trendColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          
          SizedBox(height: 12),
          
          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _speakMarketInfo(item),
                  icon: Icon(Icons.volume_up, size: 16),
                  label: Text(
                    TranslationService.tr('listen'),
                    style: TextStyle(fontSize: 12),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppConstants.primaryGreen,
                    side: BorderSide(color: AppConstants.primaryGreen),
                    padding: EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showNotificationDialog(item),
                  icon: Icon(Icons.notifications, size: 16),
                  label: Text(
                    TranslationService.getCurrentLanguage() == 'pa' 
                      ? 'ਅਲਰਟ' 
                      : TranslationService.getCurrentLanguage() == 'hi'
                        ? 'अलर्ट'
                        : 'Alert',
                    style: TextStyle(fontSize: 12),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.accentYellow,
                    foregroundColor: Colors.black87,
                    padding: EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
            ],
          ),
          
          // Last updated info
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.access_time,
                size: 12,
                color: AppConstants.mutedText,
              ),
              SizedBox(width: 4),
              Text(
                '${TranslationService.getCurrentLanguage() == 'pa' ? 'ਅਪਡੇਟ:' : TranslationService.getCurrentLanguage() == 'hi' ? 'अपडेट:' : 'Updated:'} ${_formatDate(item.lastUpdated)}',
                style: TextStyle(
                  fontSize: 10,
                  color: AppConstants.mutedText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _speakMarketInfo(MarketItem item) async {
    String text = TranslationService.tr('market_info', params: {
      'mandi': item.mandiName,
      'commodity': item.commodity,
      'price': item.price.toStringAsFixed(0),
    });
    text += ' ${item.trendText}';

    await TTSService.speak(text);
  }

  void _showNotificationDialog(MarketItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.notifications_active, color: AppConstants.accentYellow),
            SizedBox(width: 8),
            Text(TranslationService.tr('market_notification')),
          ],
        ),
        content: Text(
          TranslationService.tr('price_notification_ask', params: {
            'commodity': item.commodity,
          }),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(TranslationService.tr('no')),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              AppUtils.showSnackBar(context, TranslationService.tr('notification_set'));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryGreen,
            ),
            child: Text(TranslationService.tr('yes')),
          ),
        ],
      ),
    );
  }

  Future<void> _refreshMarket() async {
    setState(() => _isLoading = true);
    await _loadMarketData();
  }

  @override
  void dispose() {
    TranslationService.removeLanguageChangeListener(_onLanguageChanged);
    super.dispose();
  }
}