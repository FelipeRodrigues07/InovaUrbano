import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:planejamento_urbano/config/api_constants.dart';

class UpdateNameController extends ChangeNotifier {
  bool isLoading = false;
  bool isError = false;

  Future<void> updateName( String newName, String token ) async {
    isLoading = true;
    isError = false;
    notifyListeners();
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/update/name'),
         headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', 
        },
         body: jsonEncode({
          'newName': newName, 
        }),
      );

        if (response.statusCode == 200) {
        print('Senha atualizada com sucesso!');
      } else {
    
        isError = true;
        print('Erro ao enviar sugestão: ${response.statusCode}');
      }
    } catch (error) {
      isError = true;
      print('Erro na requisição: $error');
    }finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
