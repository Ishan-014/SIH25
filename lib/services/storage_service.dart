// services/storage_service.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';
import '../models/advice.dart';
import '../models/weather.dart';
import '../models/market.dart';
import '../models/pest_report.dart';

class StorageService {
  static SharedPreferences? _prefs;
  static Database? _db;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    await _initDatabase();
  }

  static Future<void> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'farmer_app.db');
    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE advice(
            id TEXT PRIMARY KEY,
            data TEXT NOT NULL,
            timestamp INTEGER NOT NULL
          )
        ''');
        
        await db.execute('''
          CREATE TABLE weather(
            id TEXT PRIMARY KEY,
            data TEXT NOT NULL,
            timestamp INTEGER NOT NULL
          )
        ''');
        
        await db.execute('''
          CREATE TABLE market(
            id TEXT PRIMARY KEY,
            data TEXT NOT NULL,
            timestamp INTEGER NOT NULL
          )
        ''');
        
        await db.execute('''
          CREATE TABLE pest_reports(
            id TEXT PRIMARY KEY,
            data TEXT NOT NULL,
            timestamp INTEGER NOT NULL
          )
        ''');
        
        await db.execute('''
          CREATE TABLE pending_uploads(
            id TEXT PRIMARY KEY,
            type TEXT NOT NULL,
            data TEXT NOT NULL,
            file_path TEXT,
            timestamp INTEGER NOT NULL,
            retry_count INTEGER DEFAULT 0
          )
        ''');
      },
    );
  }

  // Simple key-value storage
  static Future<void> setString(String key, String value) async {
    await _prefs?.setString(key, value);
  }

  static String? getString(String key, {String? defaultValue}) {
    return _prefs?.getString(key) ?? defaultValue;
  }

  static Future<void> setBool(String key, bool value) async {
    await _prefs?.setBool(key, value);
  }

  static bool getBool(String key, {bool defaultValue = false}) {
    return _prefs?.getBool(key) ?? defaultValue;
  }

  // Current language
  static Future<void> setCurrentLanguage(String language) async {
    await setString('current_language', language);
  }

  static String getCurrentLanguage() {
    return getString('current_language', defaultValue: 'pa') ?? 'pa';
  }

  // Cache advice
  static Future<void> cacheAdvice(Advice advice) async {
    if (_db == null) return;
    
    try {
      await _db!.insert(
        'advice',
        {
          'id': advice.id,
          'data': jsonEncode(advice.toJson()),
          'timestamp': advice.timestamp.millisecondsSinceEpoch,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      print('Error caching advice: $e');
    }
  }

  static Future<List<Advice>> getCachedAdvice() async {
    if (_db == null) return [];
    
    try {
      final List<Map<String, dynamic>> maps = await _db!.query(
        'advice',
        orderBy: 'timestamp DESC',
      );

      return List.generate(maps.length, (i) {
        return Advice.fromJson(jsonDecode(maps[i]['data']));
      });
    } catch (e) {
      print('Error getting cached advice: $e');
      return [];
    }
  }

  // Cache weather
  static Future<void> cacheWeather(Weather weather) async {
    if (_db == null) return;
    
    try {
      await _db!.insert(
        'weather',
        {
          'id': 'current',
          'data': jsonEncode(weather.toJson()),
          'timestamp': weather.timestamp.millisecondsSinceEpoch,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      print('Error caching weather: $e');
    }
  }

  static Future<Weather?> getCachedWeather() async {
    if (_db == null) return null;
    
    try {
      final List<Map<String, dynamic>> maps = await _db!.query(
        'weather',
        where: 'id = ?',
        whereArgs: ['current'],
      );

      if (maps.isNotEmpty) {
        return Weather.fromJson(jsonDecode(maps.first['data']));
      }
      return null;
    } catch (e) {
      print('Error getting cached weather: $e');
      return null;
    }
  }

  // Cache market data - FIXED VERSION
  static Future<void> cacheMarketItems(List<MarketItem> items) async {
    if (_db == null || items.isEmpty) return;
    
    try {
      // Use a transaction to ensure data consistency
      await _db!.transaction((txn) async {
        // Clear old market data
        await txn.delete('market');
        
        // Create a map to track unique IDs and avoid duplicates
        Map<String, MarketItem> uniqueItems = {};
        
        // Filter out duplicates, keeping the latest one
        for (MarketItem item in items) {
          String uniqueId = item.id;
          
          // If item has duplicate ID, create a unique one
          int counter = 1;
          String originalId = uniqueId;
          while (uniqueItems.containsKey(uniqueId)) {
            uniqueId = '${originalId}_$counter';
            counter++;
          }
          
          // Create a new item with unique ID if needed
          MarketItem uniqueItem = uniqueId != item.id 
            ? MarketItem(
                id: uniqueId,
                mandiName: item.mandiName,
                commodity: item.commodity,
                price: item.price,
                unit: item.unit,
                trend: item.trend,
                lastUpdated: item.lastUpdated,
                location: item.location,
              )
            : item;
            
          uniqueItems[uniqueId] = uniqueItem;
        }
        
        // Insert all unique items
        for (MarketItem item in uniqueItems.values) {
          await txn.insert(
            'market',
            {
              'id': item.id,
              'data': jsonEncode(item.toJson()),
              'timestamp': item.lastUpdated.millisecondsSinceEpoch,
            },
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
        
        print('Successfully cached ${uniqueItems.length} unique market items');
      });
    } catch (e) {
      print('Error caching market items: $e');
      // Don't rethrow - let the app continue with API data
    }
  }

  static Future<List<MarketItem>> getCachedMarketItems() async {
    if (_db == null) return [];
    
    try {
      final List<Map<String, dynamic>> maps = await _db!.query(
        'market',
        orderBy: 'timestamp DESC',
      );

      return List.generate(maps.length, (i) {
        return MarketItem.fromJson(jsonDecode(maps[i]['data']));
      });
    } catch (e) {
      print('Error getting cached market items: $e');
      return [];
    }
  }

  // Pest reports
  static Future<void> savePestReport(PestReport report) async {
    if (_db == null) return;
    
    try {
      await _db!.insert(
        'pest_reports',
        {
          'id': report.id,
          'data': jsonEncode(report.toJson()),
          'timestamp': report.timestamp.millisecondsSinceEpoch,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      print('Error saving pest report: $e');
    }
  }

  static Future<List<PestReport>> getPestReports() async {
    if (_db == null) return [];
    
    try {
      final List<Map<String, dynamic>> maps = await _db!.query(
        'pest_reports',
        orderBy: 'timestamp DESC',
      );

      return List.generate(maps.length, (i) {
        return PestReport.fromJson(jsonDecode(maps[i]['data']));
      });
    } catch (e) {
      print('Error getting pest reports: $e');
      return [];
    }
  }

  // Clear all cached data (useful for debugging)
  static Future<void> clearAllCache() async {
    if (_db == null) return;
    
    try {
      await _db!.delete('market');
      await _db!.delete('weather');
      await _db!.delete('advice');
      print('All cache cleared successfully');
    } catch (e) {
      print('Error clearing cache: $e');
    }
  }

  // Get database info for debugging
  static Future<void> debugDatabaseInfo() async {
    if (_db == null) return;
    
    try {
      var marketCount = await _db!.rawQuery('SELECT COUNT(*) as count FROM market');
      var weatherCount = await _db!.rawQuery('SELECT COUNT(*) as count FROM weather');
      var adviceCount = await _db!.rawQuery('SELECT COUNT(*) as count FROM advice');
      
      print('Database Info:');
      print('Market items: ${marketCount.first['count']}');
      print('Weather entries: ${weatherCount.first['count']}');
      print('Advice entries: ${adviceCount.first['count']}');
    } catch (e) {
      print('Error getting database info: $e');
    }
  }
}