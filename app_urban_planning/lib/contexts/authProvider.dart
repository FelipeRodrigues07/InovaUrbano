import 'dart:convert'; // Importa o pacote json
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // Importa o pacote http
import 'package:planejamento_urbano/config/api_constants.dart';
import 'package:planejamento_urbano/models/user_profile.dart';
import 'package:planejamento_urbano/storage/storage_token.dart';
import 'package:planejamento_urbano/storage/storage_user.dart';

class AuthProvider with ChangeNotifier {
  String? _token;
  UserProfile? _userProfile;
  bool _isLoadingUserStorageData = true;

  String? get token => _token;
  UserProfile? get userProfile => _userProfile;
  bool get isLoadingUserStorageData => _isLoadingUserStorageData;

  Future<void> signIn(String email, String password) async {
    try {
      final url =
          Uri.parse('$baseUrl/authenticate'); // Endpoint da API
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password
        }), // Envia as credenciais como JSON
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['token'] != null) {
          String token = responseData['token'];
          print('Token recebido: $token');
          await StorageToken.storageAuthTokenSave(token);
          _token = token;
          await fetchProfile();
          notifyListeners();
        }
      } else {
        throw Exception('Falha na autenticação: ${response.reasonPhrase}');
      }
    } catch (error) {
      throw error; // Trate o erro depois
    }
  }

  Future<void> loadUserData() async {
    try {
      _isLoadingUserStorageData = true;
      final token = await StorageToken
          .storageAuthTokenGet(); // Recupera o token do armazenamento
      final userData = await StorageUser.storageUserDataGet();
      if (token != null) {
        _token = token; // Armazena o token na variável
      }
      if (userData != null) {
        _userProfile = UserProfile.fromJson(userData);
      }
      print("Token após carregar: $_token");
      print("Perfil carregado: $_userProfile");
    } catch (error) {
      throw error; 
    } finally {
      _isLoadingUserStorageData = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    try {
      _isLoadingUserStorageData = true;
      _token = null; 
      _userProfile = null; 
      print("Token após limpeza: $_token");
      await StorageToken.storageAuthTokenRemove();
      await StorageUser.storageUserDataRemove();
      notifyListeners();
    } catch (error) {
      throw error;
    } finally {
      _isLoadingUserStorageData = false;
    }
  }

  Future<void> initialize() async {
    print("Iniciando a inicialização do usuário...");
    await loadUserData();
    print("Token carregado: $_token");

    // if (_token != null) {
    //   print("Buscando o perfil do usuário...");
    //   await fetchProfile();
    //   print("Perfil carregado com sucesso!");
    // } else {
    //   print("Token é nulo, não foi possível buscar o perfil.");
    // }
  }

  Future<Map<String, dynamic>> fetchProfile() async {
    if (_token == null) {
      throw Exception('Usuário não autenticado');
    }

    try {
      final url = Uri.parse('$baseUrl/profile');
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $_token', 
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final profileData = jsonDecode(response.body);
        print('Dados do perfil recebidos: $profileData');
        _userProfile = UserProfile.fromJson(profileData);
        await StorageUser.storageUserDataSave(profileData);
        notifyListeners();
        return profileData;
      } else {
        throw Exception('Erro ao buscar o perfil: ${response.reasonPhrase}');
      }
    } catch (error) {
      throw error;
    }
  }
}
