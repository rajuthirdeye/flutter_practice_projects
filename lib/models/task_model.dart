class TaskModel {
  final int id;
  final String title;
  final String description;
  final String category;
  final String priority;
  final DateTime dueDate;
  bool isCompleted;

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.priority,
    required this.dueDate,
    this.isCompleted = false,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? 'General',
      priority: json['priority'] ?? 'Medium',
      dueDate: DateTime.tryParse(json['dueDate'] ?? '') ?? DateTime.now(),
      isCompleted: json['completed'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'priority': priority,
      'dueDate': dueDate.toIso8601String(),
      'completed': isCompleted,
    };
  }
}
