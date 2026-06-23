import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:planejamento_urbano/config/api_constants.dart';
import 'package:planejamento_urbano/models/official_response_feed_model.dart';
import 'package:planejamento_urbano/storage/storage_city_prefs.dart';
import 'dart:convert';

class OfficialResponsesFeedController extends ChangeNotifier {
  bool isLoading = false;
  bool isError = false;
  bool noCitySelected = false;
  int pageNumber = 1;
  final int pageSize = 5;
  List<OfficialResponseFeedModel> officialResponses = [];
  String? cityLabel;
  int? _ibgeId;
  int _requestId = 0;

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

  Future<List<OfficialResponseFeedModel>> _filterForCity(
    List<OfficialResponseFeedModel> raw,
    int cityIbgeId,
  ) async {
    if (raw.isEmpty) return raw;

    final hasIbgeField = raw.any((r) => r.suggestionIbgeId != null);
    if (hasIbgeField) {
      return raw.where((r) => r.suggestionIbgeId == cityIbgeId).toList();
    }

    final allowed = await _fetchSuggestionNumbersForIbge(cityIbgeId);
    return raw
        .where((r) => allowed.contains(r.numberSuggestion))
        .toList();
  }

  Future<void> loadOfficialResponses({bool loadMore = false}) async {
    if (loadMore) {
      if (isLoading || _ibgeId == null || officialResponses.isEmpty) return;
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
        officialResponses = [];
        isLoading = false;
        isError = false;
        notifyListeners();
        return;
      }

      _ibgeId = newIbgeId;
      pageNumber = 1;
      officialResponses = [];
      notifyListeners();
    }

    if (_ibgeId == null) return;

    isLoading = true;
    isError = false;
    notifyListeners();

    final pageToFetch = pageNumber;
    final cityIbgeId = _ibgeId!;

    try {
      final uri = Uri.parse('$baseUrl/official-responses/feed').replace(
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
        var items = data
            .map((json) => OfficialResponseFeedModel.fromJson(json))
            .toList();

        items = await _filterForCity(items, cityIbgeId);
        if (requestId != _requestId) return;

        if (loadMore) {
          officialResponses.addAll(items);
        } else {
          officialResponses = items;
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
