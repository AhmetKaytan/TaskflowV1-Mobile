import 'dart:convert';

import 'package:http/http.dart' as http;

// API servis sınıfı, TÜM HTTP isteklerini yönetir.
// Doğrudan backend ile iletişim kuran yapıdır. Diğer servisler bu sınıf üzerinden HTTP isteklerini yapar.
class ApiService {
  //Backend'in temel URL'si (render.com üzerinde yayınlanıyor)
  static const String baseUrl = 'https://taskflowv1.onrender.com';

  final http.Client _client = http.Client();

  //HTTP istekleri için header'ları hazırlayan fonksiyon
  Map<String, String> _headers({String? token}) {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  //HTTP POST isteği
  Future<http.Response> post(
    String endpoint, {
    Map<String, dynamic>? body,
    String? token,
  }) async {
    final url = Uri.parse('$baseUrl$endpoint');

    return await _client.post(
      url,
      //Header'ları ekle (token)
      headers: _headers(token: token),
      //Body'yi JSON formatına çevirerek gönder
      body: body != null ? jsonEncode(body) : null,
    );
  }

  //HTTP GET isteği
  Future<http.Response> get(String endpoint, {String? token}) async {
    //Endpoint URL'sini oluştur(Uri.parse kullanılarak)
    final url = Uri.parse('$baseUrl$endpoint');

    return await _client.get(url, headers: _headers(token: token));
  }

  //HTTP PUT isteği
  Future<http.Response> put(
    String endpoint, {
    Map<String, dynamic>? body,
    String? token,
  }) async {
    final url = Uri.parse('$baseUrl$endpoint');

    return await _client.put(
      url,
      headers: _headers(token: token),
      body: body != null ? jsonEncode(body) : null,
    );
  }

  //HTTP DELETE isteği
  Future<http.Response> delete(String endpoint, {String? token}) async {
    final url = Uri.parse('$baseUrl$endpoint');

    return await _client.delete(url, headers: _headers(token: token));
  }

  //HTTP client'ı kapatan fonksiyon
  void dispose() {
    _client.close();
  }
}
