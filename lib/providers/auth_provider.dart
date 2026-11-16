import 'package:flutter/foundation.dart';

import '../services/auth_service.dart';

// AuthProvider, kullanıcı kimlik doğrulama durumunu yönetir ve değişiklikleri dinleyicilere bildirir.
// Bu yüzden ChangeNotifier'dan türetilmiştir.
// Provider mimarisi kurduğum için, tüm dinleyicilere değişiklikleri bildirmek için notifyListeners() metodunu kullanıyorum.
class AuthProvider extends ChangeNotifier {
  // AuthService nesnesini oluşturuyoruz.
  final AuthService _authService = AuthService();

  // Kullanıcının kimlik doğrulama durumu ve yüklenme durumu için değişkenler.
  bool _isAuthenticated = false;
  bool _isLoading = false;

  // Kullanıcı bilgisi ve hata mesajı için değişkenler.
  Map<String, dynamic>? _user;
  String? _errorMessage;

  // Getter metodları, özel değişkenlerin dışarıdan okunmasını sağlar.
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  Map<String, dynamic>? get user => _user;
  String? get errorMessage => _errorMessage;

  // Uygulama açıldığında kayıtlı token'ı kontrol ediyoruz.
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await _authService.getToken();
      _isAuthenticated = token != null && token.isNotEmpty;
    } catch (e) {
      _isAuthenticated = false;
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Kullanıcı girişi
  Future<bool> login({
    required String username,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // AuthService üzerinden login işlemi yapıyoruz.
      final response = await _authService.login(
        username: username,
        password: password,
      );
      // Login başarılı ise kullanıcı bilgilerini güncelliyoruz.
      _user = response['user'];
      _isAuthenticated = true;

      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Kullanıcı kaydı
  Future<bool> register({
    required String username,
    required String password,
    String? email,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // AuthService üzerinden register işlemi yapıyoruz.
      await _authService.register(
        username: username,
        password: password,
        email: email,
      );

      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Kullanıcı çıkışı
  Future<bool> logout() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // AuthService üzerinden logout işlemi yapıyoruz.
      await _authService.logout();

      _isAuthenticated = false;
      _user = null;

      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Hata mesajını temizleme
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
