import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/task_provider.dart';

class FilterWidget extends StatelessWidget {
  // Form controller'ı ve arama değişikliklerini dinleyen callback fonksiyonu
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;

  const FilterWidget({
    super.key,
    required this.searchController,
    required this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    // TaskProvider'ı dinliyoruz. Bu sayede filtreler değiştiğinde ekran otomatik olarak yeniden çizilecek.
    final taskProvider = context.watch<TaskProvider>();

    return Column(
      children: [
        // Arama alanı
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: TextField(
            controller: searchController,
            onChanged: onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Search tasks...',
              prefixIcon: const Icon(Icons.search),
              // Arama alanı eğer boş değilse temizleme butonu gösteriyoruz
              suffixIcon: searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        searchController.clear();
                        onSearchChanged('');
                      },
                    )
                  : null,
              filled: true,
              fillColor: Colors.grey.withValues(alpha: 0.08),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),

        // Durum ve Öncelik filtreleri
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              // Durum filtresi
              Expanded(
                // DropdownButtonFormField ile status (durum) filtresi
                child: DropdownButtonFormField<String>(
                  //Başlangıçta seçili olan durum değeri
                  initialValue: taskProvider.selectedStatus,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: 'Status',
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  hint: const Text('All statuses'),
                  items: const [
                    // Status seçenekleri DropdownMenuItem ile tanımlanıyor
                    DropdownMenuItem(value: 'pending', child: Text('Pending')),
                    DropdownMenuItem(
                      value: 'in_progress',
                      child: Text('In Progress'),
                    ),
                    DropdownMenuItem(
                      value: 'completed',
                      child: Text('Completed'),
                    ),
                  ],
                  onChanged: (value) {
                    // Durum filtresi değiştiğinde arama alanını temizliyoruz
                    searchController.clear();

                    // TaskProvider'daki durum filtresini güncelliyoruz
                    context.read<TaskProvider>().setStatusFilter(value);
                  },
                ),
              ),

              const SizedBox(width: 12),

              // Öncelik filtresi (durum ile aynı yapıda)
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: taskProvider.selectedPriority,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: 'Priority',
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  hint: const Text('All priorities'),
                  items: const [
                    DropdownMenuItem(value: 'low', child: Text('Low')),
                    DropdownMenuItem(value: 'medium', child: Text('Medium')),
                    DropdownMenuItem(value: 'high', child: Text('High')),
                  ],
                  onChanged: (value) {
                    searchController.clear();

                    context.read<TaskProvider>().setPriorityFilter(value);
                  },
                ),
              ),
            ],
          ),
        ),

        // Filtreleri temizle butonu
        Padding(
          padding: const EdgeInsets.only(right: 16, top: 8),
          child: Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                // Arama alanı temizlenir
                searchController.clear();
                // TaskProvider'daki filtreler temizlenir
                context.read<TaskProvider>().clearFilters();
              },
              child: const Text('Clear filters'),
            ),
          ),
        ),
      ],
    );
  }
}
