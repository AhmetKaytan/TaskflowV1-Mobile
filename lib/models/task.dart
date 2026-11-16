// Task sınıfı, bir görevin özelliklerini temsil eder.
class Task {
  final int id;
  final String title;
  final String description;
  final String status;
  final String priority;
  final String assignee;
  final String dueDate;
  final String createdAt;
  final String updatedAt;

  // Constructor
  const Task({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    required this.assignee,
    required this.dueDate,
    required this.createdAt,
    required this.updatedAt,
  });

  // JSON verisinden Task nesnesi oluşturmak için factory metodu tanımlıyoruz.
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      status: json['status'],
      priority: json['priority'],
      assignee: json['assignee'],
      dueDate: json['dueDate'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }
}
