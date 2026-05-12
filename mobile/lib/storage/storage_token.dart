import 'package:shared_preferences/shared_preferences.dart';

class StorageToken {
  static const String _tokenKey = 'auth_token';

 
  static Future<void> storageAuthTokenSave(String token) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<String?> storageAuthTokenGet() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<void> storageAuthTokenRemove() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }
}