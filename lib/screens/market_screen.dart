// // screens/market_screen.dart
// import 'package:flutter/material.dart';
// import '../services/api_service.dart';
// import '../services/tts_service.dart';
// import '../services/translation_service.dart';
// import '../services/storage_service.dart';
// import '../models/market.dart';
// import '../widgets/loading_spinner.dart';
// import '../main.dart';


// class MarketScreen extends StatefulWidget {
//   @override
//   _MarketScreenState createState() => _MarketScreenState();
// }

// class _MarketScreenState extends State<MarketScreen> {
//   List<MarketItem> _marketItems = [];
//   bool _isLoading = true;
//   bool _isFromCache = false;

//   @override
//   void initState() {
//     super.initState();
//     _loadMarketData();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       TTSService.speak('ਮੰਡੀ ਦੇ ਭਾਅ ਦੇਖੋ');
//     });
//   }

//   Future<void> _loadMarketData() async {
//     try {
//       final items = await ApiService.getMarketPrices();
      
//       setState(() {
//         _marketItems = items;
//         _isLoading = false;
//         _isFromCache = false;
//       });
      
//       await StorageService.cacheMarketItems(items);
      
//     } catch (e) {
//       final cachedItems = await StorageService.getCachedMarketItems();
      
//       setState(() {
//         _marketItems = cachedItems;
//         _isLoading = false;
//         _isFromCache = true;
//       });
      
//       if (cachedItems.isNotEmpty) {
//         await TTSService.speak(TranslationService.tr('no_network'));
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(TranslationService.tr('market')),
//         actions: [
//           IconButton(
//             onPressed: () => TTSService.speak('ਮੰਡੀ ਦੇ ਭਾਅ ਦੇਖੋ'),
//             icon: Icon(Icons.volume_up),
//           ),
//           IconButton(
//             onPressed: _refreshMarket,
//             icon: Icon(Icons.refresh),
//           ),
//         ],
//       ),
//       body: _isLoading ? _buildLoading() : _buildMarketContent(),
//     );
//   }

//   Widget _buildLoading() {
//     return Center(child: LoadingSpinner());
//   }

//   Widget _buildMarketContent() {
//     if (_marketItems.isEmpty) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.store_outlined, size: 64, color: Colors.grey),
//             SizedBox(height: 16),
//             Text(
//               'ਕੋਈ ਮੰਡੀ ਦਾ ਡਾਟਾ ਨਹੀਂ ਮਿਲਿਆ',
//               style: Theme.of(context).textTheme.headlineMedium,
//             ),
//             SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: _refreshMarket,
//               child: Text('ਦੁਬਾਰਾ ਕੋਸ਼ਿਸ਼'),
//             ),
//           ],
//         ),
//       );
//     }

//     return Column(
//       children: [
//         if (_isFromCache) _buildCacheNotice(),
//         Expanded(
//           child: ListView.builder(
//             padding: EdgeInsets.all(16),
//             itemCount: _marketItems.length,
//             itemBuilder: (context, index) {
//               return _buildMarketItemCard(_marketItems[index]);
//             },
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildCacheNotice() {
//     return Container(
//       width: double.infinity,
//       color: AppConstants.accentYellow,
//       padding: EdgeInsets.all(12),
//       child: Row(
//         children: [
//           Icon(Icons.warning, color: Colors.black87),
//           SizedBox(width: 8),
//           Expanded(
//             child: Text(
//               TranslationService.tr('no_network'),
//               style: TextStyle(color: Colors.black87, fontSize: 14),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildMarketItemCard(MarketItem item) {
//     return Card(
//       margin: EdgeInsets.symmetric(vertical: 8),
//       child: ListTile(
//         contentPadding: EdgeInsets.all(16),
//         leading: CircleAvatar(
//           backgroundColor: AppConstants.primaryGreen,
//           leading: CircleAvatar(
//           backgroundColor: AppConstants.primaryGreen,
//           child: Icon(Icons.store, color: Colors.white),
//         ),
//         title: Text(
//           item.mandiName,
//           style: Theme.of(context).textTheme.headlineMedium,
//         ),
//         subtitle: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             SizedBox(height: 4),
//             Text(
//               '${item.commodity}: ₹${item.price.toStringAsFixed(0)}/${item.unit}',
//               style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
//             ),
//             SizedBox(height: 4),
//             Row(
//               children: [
//                 Icon(
//                   item.trendIcon,
//                   size: 16,
//                   color: item.trendColor,
//                 ),
//                 SizedBox(width: 4),
//                 Text(
//                   item.trendText,
//                   style: TextStyle(
//                     color: item.trendColor,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//         trailing: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             IconButton(
//               onPressed: () => _speakMarketInfo(item),
//               icon: Icon(Icons.volume_up),
//               color: AppConstants.primaryGreen,
//             ),
//             IconButton(
//               onPressed: () => _showNotificationDialog(item),
//               icon: Icon(Icons.notifications_outlined),
//             ),
//           ],
//         ),
//         onTap: () => _speakMarketInfo(item),
//       ),
//       )
//     );
//   }

//   Future<void> _speakMarketInfo(MarketItem item) async {
//     String text = TranslationService.tr('market_info', params: {
//       'mandi': item.mandiName,
//       'commodity': item.commodity,
//       'price': item.price.toStringAsFixed(0),
//     });
//     text += ' ${item.trendText}';
    
//     await TTSService.speak(text);
//   }

//   void _showNotificationDialog(MarketItem item) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text('ਮੰਡੀ ਦੀ ਜਾਣਕਾਰੀ'),
//         content: Text('${item.commodity} ਦੇ ਭਾਅ ਬਦਲਣ ਤੇ ਜਾਣਕਾਰੀ ਚਾਹੀਦੀ?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text('ਨਹੀਂ'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               Navigator.pop(context);
//               AppUtils.showSnackBar(context, 'ਜਾਣਕਾਰੀ ਸੈੱਟ ਹੋ ਗਈ');
//             },
//             child: Text('ਹਾਂ'),
//           ),
//         ],
//       ),
//     );
//   }

//   Future<void> _refreshMarket() async {
//     setState(() => _isLoading = true);
//     await _loadMarketData();
//   }
// }






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
      TTSService.speak('ਮੰਡੀ ਦੇ ਭਾਅ ਦੇਖੋ');
    });
  }

  Future<void> _loadMarketData() async {
    try {
      final items = await ApiService.getMarketPrices();

      setState(() {
        _marketItems = items;
        _isLoading = false;
        _isFromCache = false;
      });

      await StorageService.cacheMarketItems(items);
    } catch (e) {
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
      appBar: AppBar(
        title: Text(TranslationService.tr('market')),
        actions: [
          IconButton(
            onPressed: () => TTSService.speak('ਮੰਡੀ ਦੇ ਭਾਅ ਦੇਖੋ'),
            icon: Icon(Icons.volume_up),
          ),
          IconButton(
            onPressed: _refreshMarket,
            icon: Icon(Icons.refresh),
          ),
        ],
      ),
      body: _isLoading ? _buildLoading() : _buildMarketContent(),
    );
  }

  Widget _buildLoading() {
    return Center(child: LoadingSpinner());
  }

  Widget _buildMarketContent() {
    if (_marketItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.store_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'ਕੋਈ ਮੰਡੀ ਦਾ ਡਾਟਾ ਨਹੀਂ ਮਿਲਿਆ',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _refreshMarket,
              child: Text('ਦੁਬਾਰਾ ਕੋਸ਼ਿਸ਼'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        if (_isFromCache) _buildCacheNotice(),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: _marketItems.length,
            itemBuilder: (context, index) {
              return _buildMarketItemCard(_marketItems[index]);
            },
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
    );
  }

  Widget _buildMarketItemCard(MarketItem item) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: AppConstants.primaryGreen,
          child: Icon(Icons.store, color: Colors.white),
        ),
        title: Text(
          item.mandiName,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4),
            Text(
              '${item.commodity}: ₹${item.price.toStringAsFixed(0)}/${item.unit}',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 4),
            Row(
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
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () => _speakMarketInfo(item),
              icon: Icon(Icons.volume_up),
              color: AppConstants.primaryGreen,
            ),
            IconButton(
              onPressed: () => _showNotificationDialog(item),
              icon: Icon(Icons.notifications_outlined),
            ),
          ],
        ),
        onTap: () => _speakMarketInfo(item),
      ),
    );
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
        title: Text('ਮੰਡੀ ਦੀ ਜਾਣਕਾਰੀ'),
        content: Text('${item.commodity} ਦੇ ਭਾਅ ਬਦਲਣ ਤੇ ਜਾਣਕਾਰੀ ਚਾਹੀਦੀ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('ਨਹੀਂ'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              AppUtils.showSnackBar(context, 'ਜਾਣਕਾਰੀ ਸੈੱਟ ਹੋ ਗਈ');
            },
            child: Text('ਹਾਂ'),
          ),
        ],
      ),
    );
  }

  Future<void> _refreshMarket() async {
    setState(() => _isLoading = true);
    await _loadMarketData();
  }
}
