import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/task_provider.dart';
import '../models/task.dart';

class TaskFormScreen extends StatefulWidget {
  // Edit modunda mevcut görev gönderilecek.
  // Create modunda null kalacak.
  final Task? task;

  const TaskFormScreen({super.key, this.task});

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  // Global form anahtarı
  final _formKey = GlobalKey<FormState>();

  // Form alanlarının controller nesneleri
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _assigneeController = TextEditingController();

  // Seçim alanlarının varsayılan değerleri.
  String _selectedStatus = 'pending';
  String _selectedPriority = 'medium';

  // Görev bitiş tarihi. (varsayılan olarak bugünün tarihi)
  DateTime _selectedDueDate = DateTime.now();

  // Form gönderilirken kullanılacak yüklenme durumu.
  bool _isSubmitting = false;

  // Edit modunda başlangıç değerlerini mevcut görevle dolduruyoruz.
  @override
  void initState() {
    super.initState();

    final task = widget.task;

    if (task != null) {
      _titleController.text = task.title;
      _descriptionController.text = task.description;
      _assigneeController.text = task.assignee;
      _selectedStatus = task.status;
      _selectedPriority = task.priority;
      _selectedDueDate = DateTime.parse(task.dueDate);
    }
  }

  // Dispose işlemi
  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _assigneeController.dispose();
    super.dispose();
  }

  // Tarih seçici
  Future<void> _selectDueDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (selectedDate != null) {
      setState(() {
        _selectedDueDate = selectedDate;
      });
    }
  }

  // Form submit edildiğinde çalışacak metot
  Future<void> _submitForm() async {
    // Form doğrulaması
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    // Backend YYYY-MM-DD formatını bekliyor. O sebeple burada seçilen tarihi formatlıyoruz.
    final formattedDate =
        '${_selectedDueDate.year.toString().padLeft(4, '0')}-'
        '${_selectedDueDate.month.toString().padLeft(2, '0')}-'
        '${_selectedDueDate.day.toString().padLeft(2, '0')}';

    // Backend'in beklediği JSON verisini hazırlıyoruz.
    final taskData = {
      'title': _titleController.text.trim(),
      'description': _descriptionController.text.trim(),
      'assignee': _assigneeController.text.trim(),
      'status': _selectedStatus,
      'priority': _selectedPriority,
      'dueDate': formattedDate,
    };

    // Formun hangi modda olduğunu kontrol ediyoruz. (Edit/Create)
    final isEditing = widget.task != null;

    // Provider
    final taskProvider = context.read<TaskProvider>();

    // Edit veya Create işlemine göre ilgili metodu çağırıyoruz.
    // updateTask veya createTask
    final success = isEditing
        ? await taskProvider.updateTask(
            taskId: widget.task!.id,
            taskData: taskData,
          )
        : await taskProvider.createTask(taskData);

    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
    });

    if (success) {
      // İşlem başarılıysa önceki ekrana dönüyoruz.
      // True ile dönmemizi TaskScreen bekliyor!!!!
      Navigator.pop(context, true);
    } else {
      final errorMessage =
          taskProvider.errorMessage ?? 'Task operation failed.';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    //Form hangi modda? Edit/Create
    final isEditing = widget.task != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Task' : 'Create Task')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Başlık alanı.
              _buildTextField(
                controller: _titleController,
                label: 'Title',
                hint: 'Enter task title',
                maxLength: 100,
              ),

              const SizedBox(height: 18),

              // Açıklama alanı.
              _buildTextField(
                controller: _descriptionController,
                label: 'Description',
                hint: 'Describe your task',
                maxLength: 500,
                maxLines: 4,
              ),

              const SizedBox(height: 18),

              // Atanan kişi alanı.
              _buildTextField(
                controller: _assigneeController,
                label: 'Assignee',
                hint: 'Enter assignee name',
                maxLength: 50,
              ),

              const SizedBox(height: 24),

              // status ve priority seçimleri.
              Row(
                children: [
                  Expanded(child: _buildStatusDropdown()),
                  const SizedBox(width: 12),
                  Expanded(child: _buildPriorityDropdown()),
                ],
              ),

              const SizedBox(height: 24),

              // Bitiş tarihi seçimi.
              const Text(
                'Due Date',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),

              const SizedBox(height: 8),

              // Seçilen bitiş tarihi
              OutlinedButton.icon(
                onPressed: _selectDueDate,
                icon: const Icon(Icons.calendar_today),
                label: Text(
                  '${_selectedDueDate.day.toString().padLeft(2, '0')}/'
                  '${_selectedDueDate.month.toString().padLeft(2, '0')}/'
                  '${_selectedDueDate.year}',
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  alignment: Alignment.centerLeft,
                ),
              ),

              const SizedBox(height: 32),

              // Form gönderme butonu.
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitForm,
                  //Submit esnasında buton devre dışı bırakılıyor ve yükleniyor göstergesi gösteriliyor.
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          isEditing ? 'Update Task' : 'Create Task',
                          style: const TextStyle(fontSize: 16),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Tekrarlanan metin alanlarını oluşturan yardımcı widget. (Başlık, Açıklama ve Asignee için kullanıldı)
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required int maxLength,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLength: maxLength,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        alignLabelWithHint: maxLines > 1,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return '$label is required.';
        }

        return null;
      },
    );
  }

  // Status seçimi için dropdown
  Widget _buildStatusDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedStatus,
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'Status',
        border: OutlineInputBorder(),
      ),
      items: const [
        DropdownMenuItem(value: 'pending', child: Text('Pending')),
        DropdownMenuItem(value: 'in_progress', child: Text('In Progress')),
        DropdownMenuItem(value: 'completed', child: Text('Completed')),
      ],
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _selectedStatus = value;
          });
        }
      },
    );
  }

  // Priority seçimi için dropdown
  Widget _buildPriorityDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedPriority,
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'Priority',
        border: OutlineInputBorder(),
      ),
      items: const [
        DropdownMenuItem(value: 'low', child: Text('Low')),
        DropdownMenuItem(value: 'medium', child: Text('Medium')),
        DropdownMenuItem(value: 'high', child: Text('High')),
      ],
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _selectedPriority = value;
          });
        }
      },
    );
  }
}
