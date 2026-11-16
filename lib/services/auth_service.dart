import 'dart:convert';

//Token'ı saklamak için FlutterSecureStorage kullanıyoruz.
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// API servis sınıfını içe aktarıyoruz.
import 'api_service.dart';

/// Auth servis sınıfı, kullanıcı kimlik doğrulama işlemlerini yönetir.
class AuthService {
  /// API servis nesnesi
  final ApiService _apiService = ApiService();

  // FlutterSecureStorage nesnesi(_storage), token'ı güvenli bir şekilde saklamak için kullanılır.
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  // **************************************************
  // Login fonksiyonu, kullanıcı adı ve şifre ile giriş yapar ve token'ı saklar.
  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    // API servisine login isteği gönderiyoruz.
    final response = await _apiService.post(
      '/auth/login',
      body: {'username': username, 'password': password},
    );

    // Gelen yanıtı JSON formatına çeviriyoruz.
    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      // Token'ı yanıt verisinden alıyoruz.
      final token = data['token'];

      if (token == null || token is! String) {
        throw Exception('Invalid authentication response.');
      }
      // Token'ı güvenli bir şekilde saklıyoruz.
      await _storage.write(key: 'auth_token', value: token);

      return data;
    }

    throw Exception(data['message'] ?? 'Login failed.');
  }
  // **************************************************

  // **************************************************
  // Register fonksiyonu, yeni kullanıcı kaydı yapar.
  Future<Map<String, dynamic>> register({
    required String username,
    required String password,
    String? email,
  }) async {
    final body = <String, dynamic>{
      'username': username,
      'password': password,
      // Email alanı isteğe bağlıdır ve boş değilse body'ye eklenir.
      if (email != null && email.trim().isNotEmpty) 'email': email.trim(),
    };

    final response = await _apiService.post('/auth/register', body: body);
    // Gelen yanıtı JSON formatına çeviriyoruz.
    final data = jsonDecode(response.body);

    if (response.statusCode == 201) {
      return data;
    }

    throw Exception(data['message'] ?? 'Registration failed.');
  }
  // **************************************************

  // **************************************************
  // Logout fonksiyonu, kullanıcıyı çıkış yapar ve token'ı siler.
  Future<void> logout() async {
    // Mevcut token'ı alıyoruz. (logout yapabilmek için token gereklidir)
    final token = await getToken();

    try {
      if (token != null) {
        final response = await _apiService.post('/auth/logout', token: token);

        if (response.statusCode != 200) {
          final data = jsonDecode(response.body);

          throw Exception(data['message'] ?? 'Logout failed.');
        }
      }
    } finally {
      await _storage.delete(key: 'auth_token');
    }
  }
  // **************************************************

  // getToken fonksiyonu, saklanan token'ı döner.
  Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }

  // clearToken fonksiyonu, saklanan token'ı siler ve güvenli depolamadan kaldırır.
  Future<void> clearToken() async {
    await _storage.delete(key: 'auth_token');
  }
}
