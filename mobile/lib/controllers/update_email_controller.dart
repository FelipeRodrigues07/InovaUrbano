import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:planejamento_urbano/config/api_constants.dart';

class UpdateEmailController extends ChangeNotifier {
  bool isLoading = false;
  bool isError = false;
  String? errorMessage;

  Future<void> updateEmail( String newEmail, String token ) async {
    isLoading = true;
    isError = false;
    errorMessage = null;
    notifyListeners();
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/update/email'),
         headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', 
        },
         body: jsonEncode({
          'newEmail': newEmail, 
        }),
      );

        if (response.statusCode == 200) {
        print('Senha atualizada com sucesso!');
      } else {
    
        isError = true;
        final responseBody = jsonDecode(response.body);
        errorMessage = responseBody['message'] ?? 'Erro ao atualizar o email. Tente novamente.';
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
