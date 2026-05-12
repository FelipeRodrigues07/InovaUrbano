import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:planejamento_urbano/config/api_constants.dart';
import 'package:planejamento_urbano/models/get_all_suggestions_feed_model.dart';
import 'dart:convert';

class GetAllSuggestionsFeedController extends ChangeNotifier {
  bool isLoading = false;
  bool isError = false;
  int pageNumber = 1;  // Página inicial
  final int pageSize = 5;  // Quantidade de itens 
  List<GetAllSuggestionsFeedModel> suggestions = [];

  Future<void> getSuggestions({bool loadMore = false}) async {
    if (isLoading) return;  // Evita carregamento duplicado

    isLoading = true;
    isError = false;
    notifyListeners();
    // await Future.delayed(const Duration(seconds: 1));

    try {
      final response = await http.get(
        Uri.parse(
            '$baseUrl/suggestions/feed?pageNumber=$pageNumber&pageSize=$pageSize'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final newSuggestions = data
            .map((json) => GetAllSuggestionsFeedModel.fromJson(json))
            .toList();

        if (loadMore) {
          suggestions.addAll(newSuggestions);  // Adiciona os novos dados
        } else {
          suggestions = newSuggestions;
        }
        pageNumber++;  // Incrementa a página
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