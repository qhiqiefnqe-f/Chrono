import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import 'package:intl/intl.dart';

class TaskEditScreen extends StatefulWidget {
  final String? id;
  final DateTime? date;
  final DateTime? startTime;
  final DateTime? endTime;
  final String? title;
  final int? colorIndex;
  final bool? isImportant;
  final bool? hasReminder;
  final RepeatType? repeatType;

  const TaskEditScreen({
    super.key,
    this.id,
    this.date,
    this.startTime,
    this.endTime,
    this.title,
    this.colorIndex,
    this.isImportant,
    this.hasReminder,
    this.repeatType,
  });

  @override
  State<TaskEditScreen> createState() => _TaskEditScreenState();
}

class _TaskEditScreenState extends State<TaskEditScreen> {
  late TextEditingController _titleController;
  late DateTime _date;
  late DateTime _startTime;
  late DateTime _endTime;
  late bool _isImportant;
  late bool _hasReminder;
  late RepeatType _repeatType;
  int _selectedColorIndex = 0;

  static const taskColors = [
    Color(0xFF958C83),
    Color(0xFFC7B2AD),
    Color(0xFFA8A98F),
    Color(0xFF9B9EAC),
    Color(0xFFE0D3BC),
    Color(0xFF7A8897),
    Color(0xFFA99DAD),
    Color(0xFF968E75),
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.title);
    _date = widget.date ?? DateTime.now();
    _startTime = widget.startTime ?? DateTime.now();
    _endTime = widget.endTime ?? _startTime.add(const Duration(hours: 1));
    _selectedColorIndex = widget.colorIndex ?? 0;
    _isImportant = widget.isImportant ?? false;
    _hasReminder = widget.hasReminder ?? false;
    _repeatType = widget.repeatType ?? RepeatType.none;
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _saveTask() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a task title'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final task = Task(
      id: widget.id ?? DateTime.now().toString(),
      title: title,
      date: _date,
      startTime: _startTime,
      endTime: _endTime,
      colorIndex: _selectedColorIndex,
      isImportant: _isImportant,
      hasReminder: _hasReminder,
      repeatType: _repeatType,
    );

    try {
      if (widget.id != null) {
        context.read<TaskProvider>().updateTask(widget.id!, task);
      } else {
        context.read<TaskProvider>().addTask(task);
      }
      Navigator.pop(context, task);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save task: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 186, 187, 190),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.chevron_left, size: 30),
                  ),
                  Text(
                    widget.title == null ? 'New Task' : 'Edit Task',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 30),
                ],
              ),
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextField(
                              controller: _titleController,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                              ),
                              decoration: const InputDecoration(
                                hintText: 'Task Title',
                                hintStyle: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black38,
                                ),
                                border: InputBorder.none,
                              ),
                            ),
                            const SizedBox(height: 30),
                            const Text(
                              'Date',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 15),
                            GestureDetector(
                              onTap: () async {
                                final DateTime? picked = await showDatePicker(
                                  context: context,
                                  initialDate: _date,
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime(2025),
                                );
                                if (picked != null) {
                                  setState(() {
                                    _date = picked;
                                  });
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      DateFormat('yyyy-MM-dd').format(_date),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const Icon(Icons.calendar_today, size: 20),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 30),
                            const Text(
                              'Time',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 15),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildTimeSelector(
                                    'Start',
                                    _startTime,
                                    (time) => setState(() => _startTime = time),
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: _buildTimeSelector(
                                    'End',
                                    _endTime,
                                    (time) => setState(() => _endTime = time),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 30),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Important',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Switch(
                                  value: _isImportant,
                                  onChanged: (value) =>
                                      setState(() => _isImportant = value),
                                  activeColor: Colors.black,
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Reminder',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Switch(
                                  value: _hasReminder,
                                  onChanged: (value) =>
                                      setState(() => _hasReminder = value),
                                  activeColor: Colors.black,
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Repeat',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                DropdownButton<RepeatType>(
                                  value: _repeatType,
                                  items: RepeatType.values.map((type) {
                                    return DropdownMenuItem(
                                      value: type,
                                      child: Text(type.displayName),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    if (value != null) {
                                      setState(() => _repeatType = value);
                                    }
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 30),
                            const Text(
                              'Color',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 15),
                            SizedBox(
                              height: 50,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: taskColors.length,
                                itemBuilder: (context, index) {
                                  return GestureDetector(
                                    onTap: () => setState(
                                        () => _selectedColorIndex = index),
                                    child: Container(
                                      width: 50,
                                      height: 50,
                                      margin: const EdgeInsets.only(right: 10),
                                      decoration: BoxDecoration(
                                        color: taskColors[index],
                                        shape: BoxShape.circle,
                                        border: _selectedColorIndex == index
                                            ? Border.all(
                                                color: Colors.black, width: 2)
                                            : null,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 30),
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: GestureDetector(
                                onTap: () {
                                  print('保存按钮被点击');
                                  _saveTask();
                                },
                                child: Container(
                                  width: double.infinity,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  child: const Center(
                                    child: Text(
                                      'Save',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSelector(
    String label,
    DateTime time,
    Function(DateTime) onTimeChanged,
  ) {
    return GestureDetector(
      onTap: () async {
        final TimeOfDay? newTime = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.fromDateTime(time),
        );
        if (newTime != null) {
          onTimeChanged(DateTime(
            time.year,
            time.month,
            time.day,
            newTime.hour,
            newTime.minute,
          ));
        }
      },
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 5),
            Text(
              TimeOfDay.fromDateTime(time).format(context),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
