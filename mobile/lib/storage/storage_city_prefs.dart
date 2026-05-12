import 'dart:convert';

import 'package:planejamento_urbano/models/br_city.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageCityPrefs {
  static const _recentKey = 'cities_recent_v1';
  static const _favKey = 'cities_favorites_v1';
  static const _lastKey = 'cities_last_v1';

  static Future<List<BrCity>> getRecent() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_recentKey);
    if (raw == null) return [];
    final decoded = jsonDecode(raw);
    if (decoded is! List) return [];
    return decoded
        .whereType<Map<String, dynamic>>()
        .map(BrCity.fromJson)
        .toList();
  }

  static Future<List<BrCity>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_favKey);
    if (raw == null) return [];
    final decoded = jsonDecode(raw);
    if (decoded is! List) return [];
    return decoded
        .whereType<Map<String, dynamic>>()
        .map(BrCity.fromJson)
        .toList();
  }

  static Future<BrCity?> getLastCity() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_lastKey);
    if (raw == null) return null;
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) return null;
    return BrCity.fromJson(decoded);
  }

  static Future<void> setLastCity(BrCity city) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastKey, jsonEncode(city.toJson()));
  }

  static Future<void> setRecent(List<BrCity> cities) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _recentKey,
      jsonEncode(cities.map((c) => c.toJson()).toList()),
    );
  }

  static Future<void> setFavorites(List<BrCity> cities) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _favKey,
      jsonEncode(cities.map((c) => c.toJson()).toList()),
    );
  }
}

