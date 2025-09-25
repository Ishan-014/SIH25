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
    
    await _db!.insert(
      'advice',
      {
        'id': advice.id,
        'data': jsonEncode(advice.toJson()),
        'timestamp': advice.timestamp.millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<Advice>> getCachedAdvice() async {
    if (_db == null) return [];
    
    final List<Map<String, dynamic>> maps = await _db!.query(
      'advice',
      orderBy: 'timestamp DESC',
    );

    return List.generate(maps.length, (i) {
      return Advice.fromJson(jsonDecode(maps[i]['data']));
    });
  }

  // Cache weather
  static Future<void> cacheWeather(Weather weather) async {
    if (_db == null) return;
    
    await _db!.insert(
      'weather',
      {
        'id': 'current',
        'data': jsonEncode(weather.toJson()),
        'timestamp': weather.timestamp.millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<Weather?> getCachedWeather() async {
    if (_db == null) return null;
    
    final List<Map<String, dynamic>> maps = await _db!.query(
      'weather',
      where: 'id = ?',
      whereArgs: ['current'],
    );

    if (maps.isNotEmpty) {
      return Weather.fromJson(jsonDecode(maps.first['data']));
    }
    return null;
  }

  // Cache market data
  static Future<void> cacheMarketItems(List<MarketItem> items) async {
    if (_db == null) return;
    
    // Clear old data
    await _db!.delete('market');
    
    // Insert new data
    for (MarketItem item in items) {
      await _db!.insert('market', {
        'id': item.id,
        'data': jsonEncode(item.toJson()),
        'timestamp': item.lastUpdated.millisecondsSinceEpoch,
      });
    }
  }

  static Future<List<MarketItem>> getCachedMarketItems() async {
    if (_db == null) return [];
    
    final List<Map<String, dynamic>> maps = await _db!.query(
      'market',
      orderBy: 'timestamp DESC',
    );

    return List.generate(maps.length, (i) {
      return MarketItem.fromJson(jsonDecode(maps[i]['data']));
    });
  }

  // Pest reports
  static Future<void> savePestReport(PestReport report) async {
    if (_db == null) return;
    
    await _db!.insert(
      'pest_reports',
      {
        'id': report.id,
        'data': jsonEncode(report.toJson()),
        'timestamp': report.timestamp.millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<PestReport>> getPestReports() async {
    if (_db == null) return [];
    
    final List<Map<String, dynamic>> maps = await _db!.query(
      'pest_reports',
      orderBy: 'timestamp DESC',
    );

    return List.generate(maps.length, (i) {
      return PestReport.fromJson(jsonDecode(maps[i]['data']));
    });
  }
}