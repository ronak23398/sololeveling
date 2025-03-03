import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class SharedPrefs {
  late SharedPreferences _prefs;
  bool _initialized = false;

  // Initialize shared preferences
  Future<void> init() async {
    if (!_initialized) {
      _prefs = await SharedPreferences.getInstance();
      _initialized = true;
    }
  }

  // Save a string value
  Future<bool> saveString(String key, String value) async {
    await _ensureInitialized();
    return await _prefs.setString(key, value);
  }

  // Get a string value
  Future<String?> getString(String key) async {
    await _ensureInitialized();
    return _prefs.getString(key);
  }

  // Save an integer value
  Future<bool> saveInt(String key, int value) async {
    await _ensureInitialized();
    return await _prefs.setInt(key, value);
  }

  // Get an integer value
  Future<int?> getInt(String key) async {
    await _ensureInitialized();
    return _prefs.getInt(key);
  }

  // Save a double value
  Future<bool> saveDouble(String key, double value) async {
    await _ensureInitialized();
    return await _prefs.setDouble(key, value);
  }

  // Get a double value
  Future<double?> getDouble(String key) async {
    await _ensureInitialized();
    return _prefs.getDouble(key);
  }

  // Save a boolean value
  Future<bool> saveBool(String key, bool value) async {
    await _ensureInitialized();
    return await _prefs.setBool(key, value);
  }

  // Get a boolean value
  Future<bool?> getBool(String key) async {
    await _ensureInitialized();
    return _prefs.getBool(key);
  }

  // Save a list of strings
  Future<bool> saveStringList(String key, List<String> value) async {
    await _ensureInitialized();
    return await _prefs.setStringList(key, value);
  }

  // Get a list of strings
  Future<List<String>?> getStringList(String key) async {
    await _ensureInitialized();
    return _prefs.getStringList(key);
  }

  // Save a map by converting it to JSON
  Future<bool> saveMap(String key, Map<String, dynamic> value) async {
    await _ensureInitialized();
    return await _prefs.setString(key, jsonEncode(value));
  }

  // Get a map from JSON
  Future<Map<String, dynamic>?> getMap(String key) async {
    await _ensureInitialized();
    final jsonString = _prefs.getString(key);
    if (jsonString == null) return null;

    try {
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Error decoding JSON from preferences: $e');
      return null;
    }
  }

  // Save an object that has a toJson method
  Future<bool> saveObject(String key, dynamic object) async {
    await _ensureInitialized();
    if (object == null) return false;

    try {
      final jsonData = jsonEncode(object);
      return await _prefs.setString(key, jsonData);
    } catch (e) {
      debugPrint('Error saving object to preferences: $e');
      return false;
    }
  }

  // Get an object using a fromJson constructor
  Future<T?> getObject<T>(
      String key, T Function(Map<String, dynamic>) fromJson) async {
    await _ensureInitialized();
    final jsonString = _prefs.getString(key);
    if (jsonString == null) return null;

    try {
      final map = jsonDecode(jsonString) as Map<String, dynamic>;
      return fromJson(map);
    } catch (e) {
      debugPrint('Error getting object from preferences: $e');
      return null;
    }
  }

  // Remove a value
  Future<bool> remove(String key) async {
    await _ensureInitialized();
    return await _prefs.remove(key);
  }

  // Clear all values
  Future<bool> clear() async {
    await _ensureInitialized();
    return await _prefs.clear();
  }

  // Check if a key exists
  Future<bool> containsKey(String key) async {
    await _ensureInitialized();
    return _prefs.containsKey(key);
  }

  // Get all keys
  Future<Set<String>> getKeys() async {
    await _ensureInitialized();
    return _prefs.getKeys();
  }

  // Ensure shared preferences is initialized
  Future<void> _ensureInitialized() async {
    if (!_initialized) {
      await init();
    }
  }
}
