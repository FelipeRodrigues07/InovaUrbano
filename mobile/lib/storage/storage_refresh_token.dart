import 'package:shared_preferences/shared_preferences.dart';

/// Persistência local do refresh token e expiração do access token.
class StorageRefreshToken {
  static const _refreshKey = 'refresh_token';
  static const _accessExpiresAtKey = 'access_token_expires_at_ms';

  static Future<void> save(String refreshToken, int expiresInSeconds) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_refreshKey, refreshToken);
    final expiresAt = DateTime.now()
        .add(Duration(seconds: expiresInSeconds))
        .millisecondsSinceEpoch;
    await prefs.setInt(_accessExpiresAtKey, expiresAt);
  }

  static Future<String?> get() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshKey);
  }

  static Future<bool> isAccessTokenExpiringSoon({
    Duration buffer = const Duration(minutes: 1),
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final expiresAt = prefs.getInt(_accessExpiresAtKey);
    if (expiresAt == null) return true;
    return DateTime.now().millisecondsSinceEpoch >=
        expiresAt - buffer.inMilliseconds;
  }

  static Future<void> remove() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_refreshKey);
    await prefs.remove(_accessExpiresAtKey);
  }
}
