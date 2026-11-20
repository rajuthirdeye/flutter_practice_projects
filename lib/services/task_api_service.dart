import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/task_model.dart';

class TaskApiService {
  static const String baseUrl = 'https://jsonplaceholder.typicode.com/todos';

  Future<List<TaskModel>> fetchTasks() async {
    final response = await http.get(Uri.parse('$baseUrl?_limit=20'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);

      return data.map((item) {
        return TaskModel(
          id: item['id'],
          title: item['title'],
          description: 'Task loaded from API',
          category: 'General',
          priority: 'Medium',
          dueDate: DateTime.now().add(Duration(days: item['id'] % 7)),
          isCompleted: item['completed'],
        );
      }).toList();
    } else {
      throw Exception('Failed to load tasks');
    }
  }
}
