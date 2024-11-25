import 'package:flutter/material.dart';
import 'task_provider.dart';

class CompletedTaskProvider extends ChangeNotifier {
  final List<Task> _completedTasks = [];

  List<Task> get completedTasks => _completedTasks;

  void addCompletedTask(Task task) {
    _completedTasks.add(task);
    notifyListeners();
  }

  void removeCompletedTask(String id) {
    _completedTasks.removeWhere((task) => task.id == id);
    notifyListeners();
  }
}
