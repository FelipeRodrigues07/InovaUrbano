import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:planejamento_urbano/config/api_constants.dart';
import 'package:planejamento_urbano/models/user_profile.dart';
import 'package:planejamento_urbano/services/auth/auth_session.dart';
import 'package:planejamento_urbano/storage/storage_token.dart';
import 'package:planejamento_urbano/storage/storage_user.dart';

class AuthProvider with ChangeNotifier {
  String? _token;
  UserProfile? _userProfile;
  bool _isLoadingUserStorageData = true;

  String? get token => _token;
  UserProfile? get userProfile => _userProfile;
  bool get isLoadingUserStorageData => _isLoadingUserStorageData;

  /// Access token válido (renova com refresh se necessário).
  Future<String?> ensureAccessToken() async {
    final access = await AuthSession.getValidAccessToken();
    if (access != _token) {
      _token = access;
      notifyListeners();
    }
    return access;
  }

  Future<void> signIn(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/authenticate'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode != 200) {
      throw Exception('Falha na autenticação: ${response.reasonPhrase}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    await AuthSession.persistLoginResponse(data);
    _token = data['token'] as String;
    await fetchProfile();
    notifyListeners();
  }

  Future<void> loadUserData() async {
    try {
      _isLoadingUserStorageData = true;
      _token = await StorageToken.storageAuthTokenGet();
      final userData = await StorageUser.storageUserDataGet();
      if (userData != null) {
        _userProfile = UserProfile.fromJson(userData);
      }
    } finally {
      _isLoadingUserStorageData = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    try {
      _isLoadingUserStorageData = true;
      await AuthSession.logoutRemote();
      _token = null;
      _userProfile = null;
      await StorageUser.storageUserDataRemove();
      notifyListeners();
    } finally {
      _isLoadingUserStorageData = false;
      notifyListeners();
    }
  }

  Future<void> initialize() async {
    await loadUserData();
  }

  Future<Map<String, dynamic>> fetchProfile() async {
    final access = await ensureAccessToken();
    if (access == null) {
      throw Exception('Usuário não autenticado');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/profile'),
      headers: {
        'Authorization': 'Bearer $access',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final profileData = jsonDecode(response.body) as Map<String, dynamic>;
      _userProfile = UserProfile.fromJson(profileData);
      await StorageUser.storageUserDataSave(profileData);
      notifyListeners();
      return profileData;
    }

    if (response.statusCode == 401) {
      await signOut();
    }

    throw Exception('Erro ao buscar o perfil: ${response.reasonPhrase}');
  }
}
