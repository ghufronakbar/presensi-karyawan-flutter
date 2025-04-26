import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageUtils {
  static final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  
  // Secure Storage Methods
  
  /// Set secure data with the given [key] and [value]
  static Future<void> setSecureData(String key, String value) async {
    await _secureStorage.write(key: key, value: value);
  }
  
  /// Get secure data for the given [key]
  static Future<String?> getSecureData(String key) async {
    return await _secureStorage.read(key: key);
  }
  
  /// Delete secure data for the given [key]
  static Future<void> deleteSecureData(String key) async {
    await _secureStorage.delete(key: key);
  }
  
  /// Clear all secure data
  static Future<void> clearSecureData() async {
    await _secureStorage.deleteAll();
  }
  
  // SharedPreferences Methods
  
  /// Set string data with the given [key] and [value]
  static Future<bool> setStringData(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setString(key, value);
  }
  
  /// Get string data for the given [key]
  static Future<String?> getStringData(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }
  
  /// Set int data with the given [key] and [value]
  static Future<bool> setIntData(String key, int value) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setInt(key, value);
  }
  
  /// Get int data for the given [key]
  static Future<int?> getIntData(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(key);
  }
  
  /// Set double data with the given [key] and [value]
  static Future<bool> setDoubleData(String key, double value) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setDouble(key, value);
  }
  
  /// Get double data for the given [key]
  static Future<double?> getDoubleData(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(key);
  }
  
  /// Set bool data with the given [key] and [value]
  static Future<bool> setBoolData(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setBool(key, value);
  }
  
  /// Get bool data for the given [key]
  static Future<bool?> getBoolData(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key);
  }
  
  /// Set object data with the given [key] and [value]
  static Future<bool> setObjectData(String key, Object value) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setString(key, jsonEncode(value));
  }
  
  /// Get object data for the given [key]
  static Future<Map<String, dynamic>?> getObjectData(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(key);
    if (jsonString == null) return null;
    return jsonDecode(jsonString) as Map<String, dynamic>;
  }
  
  /// Delete data for the given [key]
  static Future<bool> deleteData(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.remove(key);
  }
  
  /// Clear all data
  static Future<bool> clearData() async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.clear();
  }
} 