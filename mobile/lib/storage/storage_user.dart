import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageUser {
  static const String _userDataKey = 'userData'; // Chave para armazenar os dados do usuário

 
  static Future<void> storageUserDataSave(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    String jsonString = jsonEncode(userData); // Use jsonEncode aqui
    await prefs.setString(_userDataKey, jsonString);
  }

  static Future<Map<String, dynamic>?> storageUserDataGet() async {
    final prefs = await SharedPreferences.getInstance();
    String? jsonString = prefs.getString(_userDataKey);
    if (jsonString != null) {
      return jsonDecode(jsonString);
    }
    return null;
  }

  // Método para remover dados do usuário
  static Future<void> storageUserDataRemove() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userDataKey);
  }
}