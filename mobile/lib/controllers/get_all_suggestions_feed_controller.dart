import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:planejamento_urbano/config/api_constants.dart';
import 'package:planejamento_urbano/models/get_all_suggestions_feed_model.dart';
import 'package:planejamento_urbano/storage/storage_city_prefs.dart';
import 'dart:convert';

class GetAllSuggestionsFeedController extends ChangeNotifier {
  bool isLoading = false;
  bool isError = false;
  bool noCitySelected = false;
  int pageNumber = 1;
  final int pageSize = 5;
  List<GetAllSuggestionsFeedModel> suggestions = [];
  String? cityLabel;
  int? _ibgeId;
  int _requestId = 0;

  Future<void> getSuggestions({bool loadMore = false}) async {
    if (loadMore) {
      if (isLoading || _ibgeId == null || suggestions.isEmpty) return;
    }

    final requestId = ++_requestId;

    if (!loadMore) {
      final city = await StorageCityPrefs.getLastCity();
      if (requestId != _requestId) return;

      final newIbgeId = city?.ibgeId;
      cityLabel = city?.label;
      noCitySelected = newIbgeId == null;

      if (noCitySelected) {
        _ibgeId = null;
        pageNumber = 1;
        suggestions = [];
        isLoading = false;
        isError = false;
        notifyListeners();
        return;
      }

      _ibgeId = newIbgeId;
      pageNumber = 1;
      suggestions = [];
      notifyListeners();
    }

    if (_ibgeId == null) return;

    isLoading = true;
    isError = false;
    notifyListeners();

    final pageToFetch = pageNumber;

    try {
      final uri = Uri.parse('$baseUrl/suggestions/feed').replace(
        queryParameters: {
          'pageNumber': '$pageToFetch',
          'pageSize': '$pageSize',
          'ibgeId': '$_ibgeId',
        },
      );

      final response = await http.get(uri);
      if (requestId != _requestId) return;

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final newSuggestions = data
            .map((json) => GetAllSuggestionsFeedModel.fromJson(json))
            .toList();

        if (loadMore) {
          suggestions.addAll(newSuggestions);
        } else {
          suggestions = newSuggestions;
        }
        pageNumber = pageToFetch + 1;
      } else {
        isError = true;
      }
    } catch (error) {
      if (requestId == _requestId) {
        isError = true;
      }
    } finally {
      if (requestId == _requestId) {
        isLoading = false;
        notifyListeners();
      }
    }
  }
}
