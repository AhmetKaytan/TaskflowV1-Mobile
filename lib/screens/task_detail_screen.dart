import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/task.dart';

// Task Kartlarına benzer yapıdadır, ancak detaylı bilgi gösterir, edit ve delete işlemlerine izin verir.
class TaskDetailsScreen extends StatelessWidget {
  final Task task;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TaskDetailsScreen({
    super.key,
    required this.task,
    required this.onEdit,
    required this.onDelete,
  });

  // Tarihleri okunabilir biçimde gösterir.
  String _formatDate(String date) {
    final parsedDate = DateTime.parse(date);
    return DateFormat('dd MMMM yyyy').format(parsedDate);
  }

  // Durum için renk belirler.
  Color _getStatusColor() {
    switch (task.status) {
      case 'completed':
        return Colors.green;
      case 'in_progress':
        return Colors.blue;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  // Öncelik için renk belirler.
  Color _getPriorityColor() {
    switch (task.priority) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  // Detay satırlarını oluşturan yardımcı widget.
  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Başlık ve değer gösteren bilgi kartı.
  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Details'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'edit') {
                onEdit();
              } else if (value == 'delete') {
                onDelete();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined, size: 20),
                    SizedBox(width: 10),
                    Text('Edit'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, color: Colors.red, size: 20),
                    SizedBox(width: 10),
                    Text('Delete', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Görev başlığı
            Text(
              task.title,
              style: const TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            // Görev durumu ve önceliği
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildBadge(
                  task.status.replaceAll('_', ' '),
                  _getStatusColor(),
                ),
                _buildBadge(
                  '${task.priority.toUpperCase()} PRIORITY',
                  _getPriorityColor(),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // Açıklama bölümü
            const Text(
              'Description',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Text(
              task.description,
              style: TextStyle(
                fontSize: 14,
                height: 1.6,
                color: Colors.grey.shade700,
              ),
            ),

            const SizedBox(height: 28),

            // Görev bilgileri
            const Text(
              'Task Information',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Card(
              elevation: 0,
              color: Colors.grey.withValues(alpha: 0.06),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Column(
                  children: [
                    _buildInfoRow(
                      icon: Icons.person_outline,
                      label: 'Assignee',
                      value: task.assignee,
                    ),
                    const Divider(height: 1),
                    _buildInfoRow(
                      icon: Icons.calendar_today_outlined,
                      label: 'Due Date',
                      value: _formatDate(task.dueDate),
                    ),
                    const Divider(height: 1),
                    _buildInfoRow(
                      icon: Icons.tag,
                      label: 'Task ID',
                      value: '#${task.id}',
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 28),

            // Oluşturulma ve güncellenme bilgileri
            const Text(
              'Activity Information',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Card(
              elevation: 0,
              color: Colors.grey.withValues(alpha: 0.06),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Column(
                  children: [
                    _buildInfoRow(
                      icon: Icons.add_circle_outline,
                      label: 'Created At',
                      value: _formatDate(task.createdAt),
                    ),
                    const Divider(height: 1),
                    _buildInfoRow(
                      icon: Icons.update,
                      label: 'Last Updated',
                      value: _formatDate(task.updatedAt),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 28),

            // Düzenleme ve silme butonları
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Edit Task'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Delete'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
