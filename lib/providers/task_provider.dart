import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../services/task_api_service.dart';

class TaskProvider extends ChangeNotifier {
  final TaskApiService _apiService = TaskApiService();

  List<TaskModel> _tasks = [];
  bool _isLoading = false;
  String? _error;

  String _filter = 'All';
  String _search = '';

  List<TaskModel> get tasks => _tasks;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get filter => _filter;

  int get totalTasks => _tasks.length;

  int get completedTasks => _tasks.where((task) => task.isCompleted).length;

  int get pendingTasks => _tasks.where((task) => !task.isCompleted).length;

  double get progress => totalTasks == 0 ? 0 : completedTasks / totalTasks;

  List<TaskModel> get filteredTasks {
    return _tasks.where((task) {
      final matchesSearch = task.title.toLowerCase().contains(
        _search.toLowerCase(),
      );

      final matchesFilter =
          _filter == 'All' ||
          (_filter == 'Pending' && !task.isCompleted) ||
          (_filter == 'Completed' && task.isCompleted);

      return matchesSearch && matchesFilter;
    }).toList();
  }

  Future<void> fetchTasks() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _tasks = await _apiService.fetchTasks();
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  void addTask(TaskModel task) {
    _tasks.insert(0, task);
    notifyListeners();
  }

  void updateTask(TaskModel updatedTask) {
    final index = _tasks.indexWhere((task) => task.id == updatedTask.id);

    if (index != -1) {
      _tasks[index] = updatedTask;
      notifyListeners();
    }
  }

  void deleteTask(int id) {
    _tasks.removeWhere((task) => task.id == id);
    notifyListeners();
  }

  void toggleTask(int id) {
    final task = _tasks.firstWhere((task) => task.id == id);
    task.isCompleted = !task.isCompleted;
    notifyListeners();
  }

  void setFilter(String filter) {
    _filter = filter;
    notifyListeners();
  }

  void setSearch(String value) {
    _search = value;
    notifyListeners();
  }
}
