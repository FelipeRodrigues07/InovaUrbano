import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:planejamento_urbano/config/api_constants.dart';
import 'package:planejamento_urbano/models/get_all_post_feed_model.dart';
import 'dart:convert';

class GetAllPostsFeedController extends ChangeNotifier {
  bool isLoading = false;
  bool isError = false;
  int pageNumber = 1;  
  final int pageSize = 3;  
  List<GetAllPostsFeedModel> posts = [];

  Future<void> getPosts({bool loadMore = false}) async {
    if (isLoading) return;  // Evita carregamento duplicado

    isLoading = true;
    isError = false;
    notifyListeners();
    // await Future.delayed(const Duration(seconds: 1));

    try {
      final response = await http.get(
        Uri.parse(
            '$baseUrl/posts/feed?pageNumber=$pageNumber&pageSize=$pageSize'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final newPosts = data
            .map((json) => GetAllPostsFeedModel.fromJson(json))
            .toList();

        if (loadMore) {
          posts.addAll(newPosts);  // Adiciona os novos dados
        } else {
          posts = newPosts;
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