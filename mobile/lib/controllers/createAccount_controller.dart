import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:planejamento_urbano/config/api_constants.dart';
import 'package:planejamento_urbano/models/createAccount_model.dart';

class CreateaccountController extends ChangeNotifier {
  bool isLoading = false;
  bool isError = false;

  Future<void> createAccount(CreateAccountModel createAccont) async {
    isLoading = true;
    isError = false;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(createAccont.toJson()),
      );

        if (response.statusCode == 201) {
        print('CreateAccount send sucessfully!');
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
