import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:planejamento_urbano/config/api_constants.dart';
import 'package:planejamento_urbano/storage/storage_refresh_token.dart';
import 'package:planejamento_urbano/storage/storage_token.dart';

/// Renovação de tokens e sessão (login, refresh, logout).
class AuthSession {
  AuthSession._();

  static Future<String?>? _refreshInFlight;

  static Future<void> persistLoginResponse(Map<String, dynamic> data) async {
    final access = data['token'] as String?;
    final refresh = data['refreshToken'] as String?;
    final expiresIn = (data['expiresIn'] as num?)?.toInt() ?? 3600;

    if (access == null || refresh == null) {
      throw Exception('Resposta de autenticação incompleta.');
    }

    await StorageToken.storageAuthTokenSave(access);
    await StorageRefreshToken.save(refresh, expiresIn);
  }

  static Future<void> clearSession() async {
    await StorageToken.storageAuthTokenRemove();
    await StorageRefreshToken.remove();
  }

  static Future<String?> getValidAccessToken() async {
    final access = await StorageToken.storageAuthTokenGet();
    if (access != null && !await StorageRefreshToken.isAccessTokenExpiringSoon()) {
      return access;
    }
    return refreshAccessToken();
  }

  static Future<String?> refreshAccessToken() async {
    if (_refreshInFlight != null) {
      return _refreshInFlight;
    }

    _refreshInFlight = _refreshInternal();
    try {
      return await _refreshInFlight;
    } finally {
      _refreshInFlight = null;
    }
  }

  static Future<String?> _refreshInternal() async {
    final refresh = await StorageRefreshToken.get();
    if (refresh == null) return null;

    final response = await http.post(
      Uri.parse('$baseUrl/refresh'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refreshToken': refresh}),
    );

    if (response.statusCode != 200) {
      await clearSession();
      return null;
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    await persistLoginResponse(data);
    return data['token'] as String?;
  }

  static Future<void> logoutRemote() async {
    final refresh = await StorageRefreshToken.get();
    if (refresh != null) {
      try {
        await http.post(
          Uri.parse('$baseUrl/logout'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'refreshToken': refresh}),
        );
      } catch (_) {
        // ignora falha remota
      }
    }
    await clearSession();
  }
}
