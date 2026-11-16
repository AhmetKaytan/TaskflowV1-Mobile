import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/task_provider.dart';
import '../widgets/task_card.dart';

import '../providers/auth_provider.dart';
import 'home_screen.dart';

import '../widgets/filter_widget.dart';

import 'task_form_screen.dart';
import '../models/task.dart';
import 'task_detail_screen.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  //Task ekranı state'i
  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  // Arama alanı için kullanılan TextEditingController
  final TextEditingController _searchController = TextEditingController();

  // Görevleri aramak için kullanılan debounce mekanizması
  Timer? _debounce;

  //Başlangıçta görevleri çekiyoruz.
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskProvider>().fetchTasks();
    });
  }

  // Dispose işlemi
  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  // Arama alanı değiştiğinde debounce mekanizması ile arama işlemini tetikliyoruz.
  // Kullanıcı arama alanına yazarken her değişiklikte bu fonksiyon tetiklenir.
  // 500ms gecikme yaptırır
  // Böylece kullanıcı yazmaya başlar başlamaz her tuş vuruşunda arama yapılmaz
  void _onSearchChanged(String value) {
    _debounce?.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (!mounted) return;

      //En son arama işlemini gerçekleştiriyoruz.
      context.read<TaskProvider>().searchTasks(value);
    });

    setState(() {});
  }

  //AppBar'daki çıkış işlemi için kullanılan yardımcı fonksiyon
  // Login'deki işlemlere benzer işlemler
  Future<void> _logout() async {
    final authProvider = context.read<AuthProvider>();

    final success = await authProvider.logout();

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Logout failed.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Görev detay ekranını açar.
  void _openTaskDetails(Task task) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TaskDetailsScreen(
          task: task,

          // Düzenleme seçildiğinde detay ekranını kapatıp formu açıyoruz.
          onEdit: () {
            Navigator.pop(context);
            _editTask(task);
          },

          // Silme seçildiğinde detay ekranını kapatıp onay istiyoruz.
          onDelete: () {
            Navigator.pop(context);
            _confirmDeleteTask(task);
          },
        ),
      ),
    );
  }

  // Mevcut görevi düzenleme formunu açar.
  Future<void> _editTask(Task task) async {
    final taskProvider = context.read<TaskProvider>();

    final result = await Navigator.push(
      context,
      //Task nesnesini TaskFormScreen'e gönderiyoruz. (Böylece form edit modunda açılır)
      MaterialPageRoute(builder: (_) => TaskFormScreen(task: task)),
    );

    if (!mounted) return;

    if (result == true) {
      _searchController.clear();
      _debounce?.cancel();

      await taskProvider.clearFilters();
    }
  }

  // Görevi silme
  Future<void> _confirmDeleteTask(Task task) async {
    // Diyalog ile kullanıcıdan onay alıyoruz.
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Task'),
          content: Text('Are you sure you want to delete "${task.title}"?'),
          actions: [
            TextButton(
              onPressed: () {
                // İptal işlemi false döner
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Onay işlemi true döner
                Navigator.pop(dialogContext, true);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    // Kullanıcı silme işlemini onaylamadıysa devam etmiyoruz.
    if (shouldDelete != true || !mounted) return;

    final taskProvider = context.read<TaskProvider>();

    // Silme işlemi
    final success = await taskProvider.deleteTask(taskId: task.id);

    if (!mounted) return;

    // İşlem sonucu mesajı (Snackbar ile gösteriliyor)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Task deleted successfully.'
              : taskProvider.errorMessage ?? 'Failed to delete task.',
        ),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  //Ekran yeniden çizildiğinde görevleri güncelliyoruz.
  @override
  Widget build(BuildContext context) {
    // TaskProvider'ı dinliyoruz. Bu sayede görevler güncellendiğinde ekran otomatik olarak yeniden çizilecek.
    final taskProvider = context.watch<TaskProvider>();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Tasks'),
        actions: [
          // Popup Menü
          PopupMenuButton<String>(
            icon: const Icon(Icons.account_circle_outlined),
            onSelected: (value) async {
              if (value == 'logout') {
                // Çıkış işlemi
                await _logout();
              }
            },
            itemBuilder: (context) => [
              //Çıkış butonu
              PopupMenuItem<String>(
                value: 'logout',
                child: const Row(
                  children: [
                    Icon(Icons.logout, size: 20),
                    SizedBox(width: 10),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Arama ve filtreleme bölümü
          FilterWidget(
            searchController: _searchController,
            onSearchChanged: _onSearchChanged,
          ),

          // Görev listesi başlığı (Görevlerin sayısını gösterir)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Your Tasks',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${taskProvider.tasks.length} tasks',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),

          // Görev listesi ayrı bir widget'tan oluşturuluyor
          Expanded(child: _buildTaskList(taskProvider)),
        ],
      ),
      // Yeni görev oluşturma butonu
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          // Provider referansı
          final taskProvider = context.read<TaskProvider>();

          // Butona basıldığında görev oluşturma ekranına geçiyoruz.
          // Görev oluşturma ekranından bir DÖNÜŞ değeri bekliyoruz!!!!
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TaskFormScreen()),
          );

          if (!mounted) return;

          //Dönüş değeri (beklediğimiz gibi) true ise listeyi güncelliyoruz.
          if (result == true) {
            _searchController.clear();
            _debounce?.cancel();

            await taskProvider.clearFilters();
          }
        },

        icon: const Icon(Icons.add),
        label: const Text('New Task'),
      ),
    );
  }

  Widget _buildTaskList(TaskProvider taskProvider) {
    // Yükleme durumundaysak bir yükleme göstergesi göster
    if (taskProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Hata durumundaysa bir hata mesajı göster
    if (taskProvider.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(taskProvider.errorMessage!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              // Tekrar deneme butonu
              ElevatedButton(
                onPressed: () {
                  if (taskProvider.searchQuery.isNotEmpty) {
                    taskProvider.searchTasks(taskProvider.searchQuery);
                  } else {
                    taskProvider.fetchTasks();
                  }
                },
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    // Arama sonucunda eşleşen görev yoksa veya görev listesi boşsa bir mesaj göster
    if (taskProvider.tasks.isEmpty) {
      return Center(
        child: Text(
          taskProvider.searchQuery.isNotEmpty
              ? 'No matching tasks found.'
              : 'No tasks found.',
        ),
      );
    }

    // Görev listesi mevcutsa RefreshIndicator ile listeyi göster
    // RefreshIndicator, listeyi yukarı kaydırarak yenileme özelliği sağlıyor
    return RefreshIndicator(
      // Yenileme işlemi
      onRefresh: () {
        if (taskProvider.searchQuery.isNotEmpty) {
          return taskProvider.searchTasks(taskProvider.searchQuery);
        }

        return taskProvider.fetchTasks();
      },
      // Listeyi oluştur
      child: ListView.builder(
        // Listeyi kaydırılabilir yap
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
        itemCount: taskProvider.tasks.length,
        itemBuilder: (context, index) {
          final task = taskProvider.tasks[index];

          return TaskCard(
            task: task,
            onTap: () => _openTaskDetails(task),
            onEdit: () => _editTask(task),
            onDelete: () => _confirmDeleteTask(task),
          );
        },
      ),
    );
  }
}
