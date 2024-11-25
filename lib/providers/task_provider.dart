import 'package:flutter/foundation.dart';
import '../database/database_helper.dart';

enum RepeatType {
  none,
  daily,
  weekly,
  monthly;

  String get displayName {
    switch (this) {
      case RepeatType.none:
        return '不重复';
      case RepeatType.daily:
        return '每天';
      case RepeatType.weekly:
        return '每周';
      case RepeatType.monthly:
        return '每月';
    }
  }
}

class Task {
  final String id;
  final String title;
  final DateTime date;
  final DateTime startTime;
  final DateTime endTime;
  final int colorIndex;
  final bool isImportant;
  final bool hasReminder;
  final RepeatType repeatType;

  Task({
    required this.id,
    required this.title,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.colorIndex,
    required this.isImportant,
    this.hasReminder = false,
    this.repeatType = RepeatType.none,
  });

  @override
  String toString() {
    return 'Task{id: $id, title: $title, isImportant: $isImportant}';
  }
}

class TaskProvider extends ChangeNotifier {
  final List<Task> _tasks = [];
  DateTime? _lastLoadedDate;

  TaskProvider() {
    debugPrint('=== TaskProvider initialized ===');
    _loadInitialTasks();
  }

  Future<void> _loadInitialTasks() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateStr = '${today.year}-'
        '${today.month.toString().padLeft(2, '0')}-'
        '${today.day.toString().padLeft(2, '0')}';

    debugPrint('TaskProvider: 加载初始数据，日期: $dateStr');

    try {
      final events = await DatabaseHelper.instance.getEvents(dateStr);
      debugPrint('TaskProvider: 初始数据加载结果: $events');

      final tasks = events.map((event) {
        final eventDate = DateTime.parse(event['date']);
        return Task(
          id: event['id'].toString(),
          title: event['title'],
          date: eventDate,
          startTime: eventDate,
          endTime: eventDate.add(const Duration(hours: 1)),
          colorIndex: event['color'] ?? 0,
          isImportant: false,
          hasReminder: false,
          repeatType: RepeatType.none,
        );
      }).toList();

      _tasks.clear();
      _tasks.addAll(tasks);
      notifyListeners();

      debugPrint('TaskProvider: 初始数据加载完成，任务数: ${_tasks.length}');
    } catch (e) {
      debugPrint('TaskProvider: 初始数据加载失败: $e');
    }
  }

  List<Task> get tasks => _tasks;

  List<Task> get todayTasks {
    final now = DateTime.now();
    return _tasks.where((task) {
      return task.date.year == now.year &&
          task.date.month == now.month &&
          task.date.day == now.day;
    }).toList();
  }

  void reorderTask(int oldIndex, int newIndex) {
    final todayTasksList = todayTasks;

    final task = todayTasksList[oldIndex];

    final originalOldIndex = _tasks.indexOf(task);

    _tasks.removeAt(originalOldIndex);

    final todayTasksBefore = _tasks.where((t) {
      final now = DateTime.now();
      return t.date.year == now.year &&
          t.date.month == now.month &&
          t.date.day == now.day;
    }).toList();

    final insertIndex = newIndex < todayTasksBefore.length
        ? _tasks.indexOf(todayTasksBefore[newIndex])
        : _tasks.length;

    _tasks.insert(insertIndex, task);

    notifyListeners();
  }

  // 获取指定日期的任务（用于日历视图）
  List<Task> getTasksForDate(DateTime date) {
    final dateStr =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    print('TaskProvider: 获取日期 $dateStr 的任务');
    print('TaskProvider: 当前总任务数: ${_tasks.length}');

    final tasks = _tasks.where((task) {
      final taskStr =
          '${task.date.year}-${task.date.month.toString().padLeft(2, '0')}-${task.date.day.toString().padLeft(2, '0')}';
      final isSameDay = taskStr == dateStr;
      print(
          'TaskProvider: 任务 ${task.title} ($taskStr) 比较 ($dateStr) = $isSameDay');
      return isSameDay;
    }).toList();

    print('TaskProvider: 返回任务数: ${tasks.length}');
    return tasks;
  }

  // 修改更新任务列表的方法
  void updateTasks(List<Task> newTasks) async {
    print('TaskProvider: 开始更新任务');
    print('TaskProvider: 更新前的任务数: ${_tasks.length}');

    if (newTasks.isEmpty) {
      print('TaskProvider: 新任务列表为空，跳过更新');
      return;
    }

    final updateDate = newTasks.first.date;
    _lastLoadedDate = updateDate;

    // 移除同一天的旧任务
    _tasks.removeWhere((task) {
      final isSameDay = task.date.year == updateDate.year &&
          task.date.month == updateDate.month &&
          task.date.day == updateDate.day;
      if (isSameDay) {
        print('TaskProvider: 移除旧任务: ${task.title}');
      }
      return isSameDay;
    });

    // 添加新任务
    _tasks.addAll(newTasks);
    print('TaskProvider: 添加新任务数: ${newTasks.length}');
    print('TaskProvider: 更新后的总任务数: ${_tasks.length}');

    // 检查并删除重复任务
    await _removeDuplicateTasks();

    notifyListeners();
  }

  // 添加一个方法来检查和删除重复任务
  Future<void> _removeDuplicateTasks() async {
    print('TaskProvider: 开始检查重复任务');
    final tasksToRemove = <String>[];

    // 按日期分组检查任务
    for (int i = 0; i < _tasks.length; i++) {
      for (int j = i + 1; j < _tasks.length; j++) {
        final task1 = _tasks[i];
        final task2 = _tasks[j];

        // 检查两个任务是否完全相同
        if (task1.title == task2.title &&
            task1.date.year == task2.date.year &&
            task1.date.month == task2.date.month &&
            task1.date.day == task2.date.day &&
            task1.startTime.hour == task2.startTime.hour &&
            task1.startTime.minute == task2.startTime.minute &&
            task1.colorIndex == task2.colorIndex) {
          // 保留ID较小的任务（较早创建的）
          final taskToRemove =
              int.parse(task1.id) > int.parse(task2.id) ? task1 : task2;
          tasksToRemove.add(taskToRemove.id);
          print(
              'TaskProvider: 发现重复任务: ${taskToRemove.title}，ID: ${taskToRemove.id}');
        }
      }
    }

    // 删除重复任务
    for (final id in tasksToRemove) {
      try {
        await DatabaseHelper.instance.deleteEvent(int.parse(id));
        _tasks.removeWhere((task) => task.id == id);
        print('TaskProvider: 删除重复任务 ID: $id');
      } catch (e) {
        print('TaskProvider: 删除重复任务失败: $e');
      }
    }

    if (tasksToRemove.isNotEmpty) {
      notifyListeners();
    }
  }

  // 检查任务是否应该在指定日期显示
  bool shouldShowOnDate(Task task, DateTime date) {
    if (task.repeatType == RepeatType.none) {
      return isSameDay(task.date, date);
    }

    final difference = date.difference(task.date).inDays;
    if (difference < 0) return false;

    switch (task.repeatType) {
      case RepeatType.daily:
        return true;
      case RepeatType.weekly:
        return difference % 7 == 0;
      case RepeatType.monthly:
        return date.day == task.date.day;
      case RepeatType.none:
        return false;
    }
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  void addTask(Task task) async {
    try {
      // 检查是否已存在相同的任务
      final dateStr = '${task.date.year}-'
          '${task.date.month.toString().padLeft(2, '0')}-'
          '${task.date.day.toString().padLeft(2, '0')}';

      final existingTasks = await DatabaseHelper.instance.getEvents(dateStr);
      final isDuplicate = existingTasks.any((event) =>
          event['title'] == task.title &&
          event['date'] == task.date.toString());

      if (isDuplicate) {
        print('TaskProvider: 跳过添加重复任务: ${task.title}');
        return;
      }

      // 先保存到数据库
      final eventData = {
        'title': task.title,
        'description': '',
        'date': task.date.toString(),
        'color': task.colorIndex,
      };
      final id = await DatabaseHelper.instance.insertEvent(eventData);
      print('TaskProvider: 保存任务到数据库，ID: $id');

      // 使用数据库返回的ID创建新的Task
      final newTask = Task(
        id: id.toString(),
        title: task.title,
        date: task.date,
        startTime: task.startTime,
        endTime: task.endTime,
        colorIndex: task.colorIndex,
        isImportant: task.isImportant,
        hasReminder: task.hasReminder,
        repeatType: task.repeatType,
      );

      // 添加到内存
      _tasks.add(newTask);
      print('TaskProvider: 添加任务到内存，总数: ${_tasks.length}');

      notifyListeners();
    } catch (e) {
      print('TaskProvider: 添加任务失败: $e');
    }
  }

  void updateTask(String id, Task newTask) {
    final index = _tasks.indexWhere((task) => task.id == id);
    if (index != -1) {
      _tasks[index] = newTask;
      notifyListeners();
    }
  }

  void deleteTask(String id) async {
    // 先找到要删除的任务，以获取其日期
    final taskToDelete = _tasks.firstWhere((task) => task.id == id);
    final taskDate = taskToDelete.date;

    try {
      // 从数据库中删除
      await DatabaseHelper.instance.deleteEvent(int.parse(id));
      print('TaskProvider: 从数据库删除任务 ID: $id');

      // 从内存中删除
      _tasks.removeWhere((task) => task.id == id);
      print('TaskProvider: 从内存删除任务 ID: $id');

      // 重新加载该日期的任务
      final dateStr = '${taskDate.year}-'
          '${taskDate.month.toString().padLeft(2, '0')}-'
          '${taskDate.day.toString().padLeft(2, '0')}';
      final events = await DatabaseHelper.instance.getEvents(dateStr);
      print('TaskProvider: 重新加载日期 $dateStr 的任务: ${events.length}个');

      // 更新UI
      notifyListeners();
    } catch (e) {
      print('TaskProvider: 删除任务失败: $e');
    }
  }

  void addTaskAt(Task task, int index) {
    _tasks.insert(index, task);
    notifyListeners();
  }

  // 添加清除指定日期的任务方法
  void clearTasksForDate(DateTime date) {
    print('TaskProvider: 清除日期 ${date.toString().split(' ')[0]} 的任务');
    _tasks.removeWhere((task) =>
        task.date.year == date.year &&
        task.date.month == date.month &&
        task.date.day == date.day);
    notifyListeners();
  }
}
