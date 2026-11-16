import 'package:flutter/material.dart';

import '../models/task.dart';
import '../services/auth_service.dart';
import '../services/task_service.dart';

class TaskProvider extends ChangeNotifier {
  // TaskService ve AuthService nesneleri
  final TaskService _taskService = TaskService();
  final AuthService _authService = AuthService();

  // Görevler, yüklenme durumu ve hata mesajı için değişkenler
  List<Task> _tasks = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Seçili filtreler ve arama sorgusu için değişkenler
  // Filtreler opsiyoneldir, arama sorgusu ise boş string ile başlar.
  String? _selectedStatus;
  String? _selectedPriority;
  String _searchQuery = '';

  // Getter metotları ile dışarıya erişim sağlıyoruz.
  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Seçili filtreleri ve arama sorgusunu güncelleyen metotlar
  String? get selectedStatus => _selectedStatus;
  String? get selectedPriority => _selectedPriority;
  String get searchQuery => _searchQuery;

  //Servis üzerinden token'ı kontrol edip döndüren metot
  Future<String> _getToken() async {
    final token = await _authService.getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Authentication token not found.');
    }

    return token;
  }

  // Görevleri servis üzerinden çekip state'i güncelleyen metot
  Future<void> fetchTasks() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Token'ı alıp doğruluyoruz.
      final token = await _getToken();

      // Görevleri servis üzerinden çekiyoruz.
      _tasks = await _taskService.getTasks(
        token: token,
        status: _selectedStatus,
        priority: _selectedPriority,
      );
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Görevlerde genel arama yap
  Future<void> searchTasks(String keyword) async {
    // Arama sorgusu
    _searchQuery = keyword;

    // Eğer arama sorgusu boşsa tüm görevleri getir.
    if (keyword.trim().isEmpty) {
      await fetchTasks();
      return;
    }

    //Arama yaparken filtreleri sıfırla
    _selectedStatus = null;
    _selectedPriority = null;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final token = await _getToken();

      //Servisteki arama metodu ile görevleri çekiyoruz.
      _tasks = await _taskService.searchTasks(
        token: token,
        keyword: keyword.trim(),
      );
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Durum filtresini değiştir.
  Future<void> setStatusFilter(String? status) async {
    _selectedStatus = status;
    _searchQuery = '';
    await fetchTasks();
  }

  // Öncelik filtresini değiştir.
  Future<void> setPriorityFilter(String? priority) async {
    _selectedPriority = priority;
    _searchQuery = '';
    await fetchTasks();
  }

  // Yeni görev oluşturma metodu
  Future<bool> createTask(Map<String, dynamic> taskData) async {
    // Önceki hata mesajını temizliyoruz.
    _errorMessage = null;

    _isLoading = true;
    notifyListeners();

    try {
      final token = await _getToken();

      // TaskService üzerinden POST isteği
      final newTask = await _taskService.createTask(
        token: token,
        taskData: taskData,
      );

      // Backend'den dönen yeni görevi mevcut listeye ekliyoruz.(insert ile en başa ekliyoruz)
      _tasks.insert(0, newTask);

      return true;
    } catch (e) {
      // Hata mesajını kaydediyoruz.
      _errorMessage = e.toString().replaceFirst('Exception: ', '');

      // İşlem başarısız.
      return false;
    } finally {
      // Yüklenme durumunu kapatıyoruz.
      _isLoading = false;
      notifyListeners();
    }
  }

  // Mevcut görevi güncelleme metodu
  Future<bool> updateTask({
    // Güncellenecek görevin ID değeri.
    required int taskId,

    // Güncellenmiş görev bilgileri.
    required Map<String, dynamic> taskData,
  }) async {
    _errorMessage = null;

    _isLoading = true;
    notifyListeners();

    try {
      final token = await _getToken();

      // TaskService üzerinden PUT isteğini gerçekleştiriyoruz.
      final updatedTask = await _taskService.updateTask(
        token: token,
        taskId: taskId,
        taskData: taskData,
      );

      // Güncellenen görevin listedeki mevcut konumunu buluyoruz
      // Liste üzerinde indexWhere() kullanıyoruz. Bize int tipinde index döner.
      final taskIndex = _tasks.indexWhere((task) => task.id == taskId);

      // Görev listede bulunuyorsa (index -1 değilse) eski görevle yenisini değiştiriyoruz.
      if (taskIndex != -1) {
        _tasks[taskIndex] = updatedTask;
      }
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');

      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Mevcut görevi silme metodu
  Future<bool> deleteTask({required int taskId}) async {
    _errorMessage = null;
    _isLoading = true;
    notifyListeners();

    try {
      final token = await _getToken();

      await _taskService.deleteTask(token: token, taskId: taskId);

      // Silinen görevi mevcut listeden kaldırıyoruz.
      // Böylece tekrar API çağrısı yapmadan liste güncelleniyor.
      _tasks.removeWhere((task) => task.id == taskId);

      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Filtreleri sıfırla.
  Future<void> clearFilters() async {
    _selectedStatus = null;
    _selectedPriority = null;
    _searchQuery = '';

    await fetchTasks();
  }
}
