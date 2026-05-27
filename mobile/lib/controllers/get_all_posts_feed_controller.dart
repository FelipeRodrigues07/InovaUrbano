import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:planejamento_urbano/config/api_constants.dart';
import 'package:planejamento_urbano/models/get_all_post_feed_model.dart';
import 'package:planejamento_urbano/storage/storage_city_prefs.dart';
import 'dart:convert';

class GetAllPostsFeedController extends ChangeNotifier {
  bool isLoading = false;
  bool isError = false;
  bool noCitySelected = false;
  int pageNumber = 1;
  final int pageSize = 5;
  List<GetAllPostsFeedModel> posts = [];
  String? cityLabel;
  int? _ibgeId;
  int _requestId = 0;

  /// Números das sugestões do município (fallback quando a API de posts ignora ibgeId).
  Future<Set<int>> _fetchSuggestionNumbersForIbge(int ibgeId) async {
    final uri = Uri.parse('$baseUrl/suggestions/feed').replace(
      queryParameters: {
        'pageNumber': '1',
        'pageSize': '200',
        'ibgeId': '$ibgeId',
      },
    );

    final response = await http.get(uri);
    if (response.statusCode != 200) return {};

    final data = jsonDecode(response.body);
    if (data is! List) return {};

    final numbers = <int>{};
    for (final item in data) {
      if (item is! Map<String, dynamic>) continue;
      final number = item['number'];
      if (number is num) {
        numbers.add(number.toInt());
      }
    }
    return numbers;
  }

  Future<List<GetAllPostsFeedModel>> _filterPostsForCity(
    List<GetAllPostsFeedModel> raw,
    int cityIbgeId,
  ) async {
    if (raw.isEmpty) return raw;

    final hasIbgeField = raw.any((p) => p.suggestionIbgeId != null);
    if (hasIbgeField) {
      return raw.where((p) => p.suggestionIbgeId == cityIbgeId).toList();
    }

    // API de posts antiga: filtra pelos números das sugestões da cidade.
    final allowed = await _fetchSuggestionNumbersForIbge(cityIbgeId);
    return raw
        .where((p) => allowed.contains(p.numberSuggestion))
        .toList();
  }

  Future<void> getPosts({bool loadMore = false}) async {
    if (loadMore) {
      if (isLoading || _ibgeId == null || posts.isEmpty) return;
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
        posts = [];
        isLoading = false;
        isError = false;
        notifyListeners();
        return;
      }

      _ibgeId = newIbgeId;
      pageNumber = 1;
      posts = [];
      notifyListeners();
    }

    if (_ibgeId == null) return;

    isLoading = true;
    isError = false;
    notifyListeners();

    final pageToFetch = pageNumber;
    final cityIbgeId = _ibgeId!;

    try {
      final uri = Uri.parse('$baseUrl/posts/feed').replace(
        queryParameters: {
          'pageNumber': '$pageToFetch',
          'pageSize': '$pageSize',
          'ibgeId': '$cityIbgeId',
        },
      );

      final response = await http.get(uri);
      if (requestId != _requestId) return;

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        var newPosts =
            data.map((json) => GetAllPostsFeedModel.fromJson(json)).toList();

        newPosts = await _filterPostsForCity(newPosts, cityIbgeId);
        if (requestId != _requestId) return;

        if (loadMore) {
          posts.addAll(newPosts);
        } else {
          posts = newPosts;
        }
        pageNumber = pageToFetch + 1;
        isError = false;
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
