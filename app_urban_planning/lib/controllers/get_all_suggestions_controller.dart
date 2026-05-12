import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:planejamento_urbano/config/api_constants.dart';
import 'package:planejamento_urbano/models/get_all_suggestions_model.dart';
import 'dart:convert';

class GetAllSuggestionsController extends ChangeNotifier {
  bool isLoading = false;
  bool isError = false;
  List<GetAllSuggestionsModel> suggestions = [];

  Future<void> getSuggestions({
    required double latMin,
    required double latMax,
    required double lonMin,
    required double lonMax,
    required String status,
  }) async {
    isLoading = true;
    isError = false;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/suggestions/area?latMin=$latMin&latMax=$latMax&lonMin=$lonMin&lonMax=$lonMax&status=$status'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        suggestions = data.map((json) => GetAllSuggestionsModel.fromJson(json)).toList();
         print('Sugestões carregadas: $suggestions');
      } else {
        isError = true;
      }
    } catch (error) {
      isError = true;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}