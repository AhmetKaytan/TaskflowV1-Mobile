import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/task.dart';

// Görev kartı widget'ı, bir görevin detaylarını gösterir.
class TaskCard extends StatelessWidget {
  final Task task;

  // Düzenleme ve silme işlemleri için callback'ler
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const TaskCard({
    super.key,
    required this.task,
    required this.onEdit,
    required this.onDelete,
    required this.onTap,
  });

  //Durum rengine göre renk döndüren yardımcı fonksiyon
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

  //Öncelik rengine göre renk döndüren yardımcı fonksiyon
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

  // Teslim tarihine göre renk belirler.
  // Geçmiş ise kırmızı, bugün ise turuncu, diğer durumlarda gri renk döndürür.
  Color _getDueDateColor() {
    final dueDate = DateTime.parse(task.dueDate);
    final today = DateTime.now();

    final normalizedDueDate = DateTime(
      dueDate.year,
      dueDate.month,
      dueDate.day,
    );

    final normalizedToday = DateTime(today.year, today.month, today.day);

    if (normalizedDueDate.isBefore(normalizedToday)) {
      return Colors.red;
    }

    if (normalizedDueDate.isAtSameMomentAs(normalizedToday)) {
      return Colors.orange;
    }

    return Colors.grey.shade700;
  }

  // Tarihi kullanıcıya okunabilir biçimde gösterir.
  String _formatDueDate() {
    final dueDate = DateTime.parse(task.dueDate);
    return DateFormat('dd MMM yyyy').format(dueDate);
  }

  // Kartlara badge eklemek için yardımcı fonksiyon
  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // Kartın kendisini oluşturan build metodu
  @override
  Widget build(BuildContext context) {
    return Card(
      // z koordinatı
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      // InkWell ile kart tıklanabilir hale getirildi, tıklanınca onTap callback'i çalışır.
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Görev başlığı ve işlem menüsü
              Row(
                children: [
                  Expanded(
                    child: Text(
                      task.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // Görev işlemleri menüsü
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert),
                    tooltip: 'Task options',
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
                            Icon(
                              Icons.delete_outline,
                              size: 20,
                              color: Colors.red,
                            ),
                            SizedBox(width: 10),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Görev açıklaması
              Text(
                task.description,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),

              const SizedBox(height: 14),

              // Görev durumu ve öncelik badge'leri
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

              const SizedBox(height: 14),

              // Teslim tarihi
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 16,
                    color: _getDueDateColor(),
                  ),
                  const SizedBox(width: 7),
                  Text(
                    'Due: ${_formatDueDate()}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _getDueDateColor(),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Görev atanan kişi ve ID bilgisi
              Row(
                children: [
                  Icon(
                    Icons.person_outline,
                    size: 17,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      task.assignee,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                  Text(
                    '#${task.id}',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
