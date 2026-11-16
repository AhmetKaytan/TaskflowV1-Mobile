import 'dart:convert';

//Api Servisi
import 'api_service.dart';
// Task modeli
import '../models/task.dart';

class TaskService {
  // ApiService nesnesi ile HTTP isteklerini yapıyoruz.
  // Veri akışı (Backend -> ApiService -> TaskService -> TasksScreen)
  final ApiService _apiService = ApiService();

  // Tüm görevleri getiren ve isteğe bağlı filtreleme yapabilen metot
  Future<List<Task>> getTasks({
    //Token gereklidir
    required String token,
    // İsteğe bağlı filtreleme parametreleri
    String? status,
    String? priority,
    String? assignee,
    String? title,
  }) async {
    // Filtreleme parametrelerini query string olarak hazırlıyoruz
    final filters = <String, String>{
      'status': ?status,
      'priority': ?priority,
      'assignee': ?assignee,
      'title': ?title,
    };

    //Eğer filtre yoksa query string boş olacak, aksi halde filtreleri ekliyoruz
    final query = filters.isEmpty
        ? ''
        : '?${Uri(queryParameters: filters).query}';

    // Token ile birlikte görevleri getirme isteği yapıyoruz. (ApiService üzerinden)
    //Eğer filtre varsa uri'ye query string eklenmiş olacak
    final response = await _apiService.get('/tasks$query', token: token);

    // Dönen data'yı body üzerinden alıp JSON formatına çeviriyoruz.
    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      // Backend'den gelen veri tasks alanında dönüyor.
      final List<dynamic> tasksJson = data['tasks'];
      // liste halinde döndürüyoruz.
      return tasksJson.map((task) => Task.fromJson(task)).toList();
    }

    throw Exception(data['message'] ?? 'Failed to fetch tasks.');
  }

  // Genel görev araması.
  Future<List<Task>> searchTasks({
    // Token ve arama anahtar kelimesi gereklidir
    required String token,
    required String keyword,
  }) async {
    // Arama query string olarak hazırlanıyor
    final query = Uri(queryParameters: {'keyword': keyword}).query;

    // Arama isteği yapılıyor (tasks/search? endpoint'ine query string ile)
    final response = await _apiService.get(
      '/tasks/search?$query',
      token: token,
    );

    //Dönen yanıt
    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      final List<dynamic> tasksJson = data['tasks'];

      return tasksJson.map((task) => Task.fromJson(task)).toList();
    }

    throw Exception(data['message'] ?? 'Failed to search tasks.');
  }

  // Yeni görev oluşturma metodu
  Future<Task> createTask({
    // İstek için token gereklidir.
    required String token,
    // Backend'e gönderilecek olan Task
    required Map<String, dynamic> taskData,
  }) async {
    // ApiService üzerinden POST isteği
    final response = await _apiService.post(
      '/tasks',
      token: token,
      body: taskData,
    );

    // Backend'den dönen yanıtı JSON formatına çeviriyoruz.
    final data = jsonDecode(response.body);

    if (response.statusCode == 201) {
      // Gönderilebilecek olan başarılı cevap:
      //{"status": "success", "task": {...}, "message": "Task created successfully"}
      // JSON verisini Task nesnesine dönüştürerek döndürüyoruz.
      return Task.fromJson(data['task']);
    }

    // İstek başarısızsa backend'in hata mesajını iletiyoruz.
    throw Exception(data['message'] ?? 'Failed to create task.');
  }

  // Mevcut görevi güncelleme metodu
  Future<Task> updateTask({
    // İstek için token gereklidir.
    required String token,

    // Güncellenecek görevin ID değeri.
    required int taskId,

    // Güncellenmiş görev bilgileri.
    required Map<String, dynamic> taskData,
  }) async {
    // PUT isteği ile mevcut görevi güncelliyoruz. (ApiService üzerinden)
    final response = await _apiService.put(
      '/tasks/$taskId',
      token: token,
      body: taskData,
    );
    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return Task.fromJson(data['task']);
    }

    throw Exception(data['message'] ?? 'Failed to update task.');
  }

  // Mevcut görevi silme metodu
  Future<void> deleteTask({required String token, required int taskId}) async {
    final response = await _apiService.delete('/tasks/$taskId', token: token);

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return;
    }

    throw Exception(data['message'] ?? 'Failed to delete task.');
  }
}
