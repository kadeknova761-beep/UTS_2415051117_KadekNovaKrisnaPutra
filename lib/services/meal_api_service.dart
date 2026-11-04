import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/exceptions.dart';

/// Lapisan paling bawah untuk TheMealDB: hanya HTTP GET dan decode JSON.
///
/// Service mengembalikan JSON mentah. Pengubahan ke model dilakukan oleh
/// repository. Semua kegagalan jaringan dipetakan ke [AppException] dengan
/// pesan yang aman ditampilkan.
class MealApiService {
  MealApiService({
    http.Client? client,
    this.timeout = const Duration(seconds: 10),
  }) : _client = client ?? http.Client();

  /// Key `1` adalah key uji publik TheMealDB (bukan rahasia).
  static const String baseUrl = 'https://www.themealdb.com/api/json/v1/1';

  final http.Client _client;
  final Duration timeout;

  Future<List<Map<String, dynamic>>> fetchCategories() {
    return _getList('categories.php', 'categories');
  }

  Future<List<Map<String, dynamic>>> fetchMealsByCategory(String category) {
    return _getList('filter.php', 'meals', {'c': category});
  }

  Future<List<Map<String, dynamic>>> searchMealsByName(String query) {
    return _getList('search.php', 'meals', {'s': query});
  }

  Future<List<Map<String, dynamic>>> searchMealsByLetter(String letter) {
    return _getList('search.php', 'meals', {'f': letter});
  }

  /// Detail lengkap satu resep, atau null bila id tidak ditemukan.
  Future<Map<String, dynamic>?> lookupMeal(String id) async {
    final list = await _getList('lookup.php', 'meals', {'i': id});
    return list.isEmpty ? null : list.first;
  }

  /// Satu resep acak (versi gratis hanya mengembalikan satu).
  Future<Map<String, dynamic>?> fetchRandomMeal() async {
    final list = await _getList('random.php', 'meals');
    return list.isEmpty ? null : list.first;
  }

  void close() => _client.close();

  Future<List<Map<String, dynamic>>> _getList(
    String endpoint,
    String key, [
    Map<String, String>? params,
  ]) async {
    final uri = Uri.parse('$baseUrl/$endpoint')
        .replace(queryParameters: params);

    final http.Response response;
    try {
      response = await _client.get(uri).timeout(timeout);
    } on TimeoutException {
      throw const AppException(
        'Koneksi terlalu lama. Periksa jaringan lalu coba lagi.',
      );
    } on http.ClientException {
      throw const AppException(
        'Tidak dapat terhubung ke server. Periksa koneksi internet.',
      );
    }

    if (response.statusCode != 200) {
      throw AppException(
        'Server bermasalah (kode ${response.statusCode}). Coba lagi nanti.',
      );
    }

    final Object? body;
    try {
      body = jsonDecode(utf8.decode(response.bodyBytes));
    } on FormatException {
      throw const AppException('Respons server tidak valid.');
    }

    if (body is! Map<String, dynamic>) {
      throw const AppException('Respons server tidak valid.');
    }

    // Hasil kosong dikirim sebagai null (atau bukan list): anggap kosong.
    final items = body[key];
    if (items is! List) return const [];
    return items.whereType<Map<String, dynamic>>().toList();
  }
}
