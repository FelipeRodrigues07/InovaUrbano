import 'package:flutter/material.dart';
import 'package:planejamento_urbano/config/api_constants.dart';
import 'package:planejamento_urbano/models/create_sugestion_model.dart';
import 'package:http/http.dart' as http;
// import 'dart:convert';
import 'dart:io';

class CreateSuggestionController extends ChangeNotifier {
  bool isLoading = false;
  bool isError = false;

  Future<void> createSuggestion(
    CreateSugestionModel suggestion,
    File? imageFile, {
    required String authToken,
  }) async {
    isLoading = true;
    isError = false;
    notifyListeners();

    final url = Uri.parse('$baseUrl/createSuggestion');

    try {
      final request = http.MultipartRequest('POST', url);
      request.headers['Authorization'] = 'Bearer $authToken';

      // Adiciona os campos de texto
      request.fields['type'] = suggestion.type;
      request.fields['description'] = suggestion.description;
      request.fields['latitude'] = suggestion.latitude.toString().replaceAll('.', ',');
      request.fields['longitude'] = suggestion.longitude.toString().replaceAll('.', ',');
      request.fields['ibgeId'] = suggestion.ibgeId.toString();
      request.fields['userId'] = suggestion.userId;

      // Adiciona o arquivo de imagem se ele existir
      if (imageFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'file', // Nome do campo que o backend espera (file no seu caso)
            imageFile.path,
          ),
        );
      }

      // Envia a requisição
      final response = await request.send();
      if (response.statusCode == 201) {
        // print('Sugestão enviada com sucesso!');
      } else {
        isError = true;
        // print('Erro ao enviar sugestão: ${response.statusCode}');
      }
    } catch (error) {
      isError = true;
      // print('Erro na requisição: $error');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
