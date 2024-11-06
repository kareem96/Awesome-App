import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/photo_model.dart';

class PhotoService {
  final String _baseUrl = 'https://api.pexels.com/v1';
  final String apiKey = '563492ad6f91700001000001774e05c614f548d5a9a1f1b1ffb9889c';

  Future<List<Photo>> fetchPhotos({int page = 1, int perPage = 10}) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/curated?page=$page&per_page=$perPage'),
      headers: {'Authorization': apiKey},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['photos'] as List)
          .map((json) => Photo.fromJson(json))
          .toList();
    } else {
      throw Exception('Failed to load photos');
    }
  }
}