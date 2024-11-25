import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import '../common/custom_text.dart';
import '../../providers/task_provider.dart';
import 'package:intl/intl.dart';
import '../../screens/task_edit_screen.dart';
import '../../providers/completed_task_provider.dart';
import '../common/custom_button_effect.dart';

// 添加颜色常量
const taskColors = [
  Color(0xFF958C83),
  Color(0xFFC7B2AD),
  Color(0xFFA8A98F),
  Color(0xFF9B9EAC),
  Color(0xFFE0D3BC),
  Color(0xFF7A8897),
  Color(0xFFA99DAD),
  Color(0xFF968E75),
];

class TasksPanel extends StatefulWidget {
  final PanelController? panelController;
  final double slideProgress;

  const TasksPanel({
    super.key,
    this.panelController,
    this.slideProgress = 0.0,
  });

  @override
  State<TasksPanel> createState() => _TasksPanelState();
}

class _TasksPanelState extends State<TasksPanel>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _titleSizeAnimation;
  late Animation<double> _cardOpacityAnimation;
  late Animation<double> _buttonScaleAnimation;

  // 添加 ScaffoldMessengerState 的全局引用
  late ScaffoldMessengerState _scaffoldMessenger;
  Task? _lastRemovedTask;
  int? _lastRemovedTaskIndex;
  bool _isAlarmMode = true; // 添加提醒模式状态

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _titleSizeAnimation = Tween<double>(
      begin: 18,
      end: 24,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _cardOpacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    ));

    _buttonScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.5, 1.0, curve: Curves.elasticOut),
    ));

    // 初始化时设置动画状态为0，显示卡片
    _animationController.value = 0.0;
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(TasksPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 根据滑动进度控制动画
    if (widget.slideProgress > 0.5) {
      // panel在顶部时
      _animationController.reverse(); // 显示卡片和reminder按钮
    } else {
      // panel在底部时
      _animationController.forward(); // 显示文字和数字按钮
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scaffoldMessenger = ScaffoldMessenger.of(context);
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars() // 立即清除当前显示的所有 SnackBar
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2), // 减少显示时间
        ),
      );
  }

  Widget _buildReminderButton(int taskCount) {
    final buttonWidth = widget.slideProgress > 0.5 ? 110.0 : 50.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: buttonWidth,
      height: 36,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Reminders 按钮
          if (widget.slideProgress > 0.5) // 使用条件渲染而不是透明度
            CustomButtonEffect(
              isBlack: _isAlarmMode,
              onTap: () {
                setState(() {
                  _isAlarmMode = !_isAlarmMode;
                });
                _showSnackBar(
                  'Reminder mode changed to ${_isAlarmMode ? 'Alarm' : 'Notification'}',
                );
              },
              child: Container(
                width: 110,
                height: 36,
                decoration: BoxDecoration(
                  color: _isAlarmMode ? Colors.black : Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: Colors.black,
                    width: 1,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Reminders',
                  style: TextStyle(
                    color: _isAlarmMode ? Colors.white : Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          // 任务数量按钮
          if (widget.slideProgress <= 0.5) // 使用条件渲染而不是透明度
            CustomButtonEffect(
              onTap: () {
                widget.panelController?.open();
              },
              child: Container(
                width: 50,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(18),
                ),
                alignment: Alignment.center,
                child: Text(
                  '$taskCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tasks = context.watch<TaskProvider>().todayTasks;
    final uncompletedTasks = tasks.length;

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AnimatedBuilder(
                animation: _titleSizeAnimation,
                builder: (context, child) {
                  return Text(
                    "Today's Tasks",
                    style: TextStyle(
                      fontSize: _titleSizeAnimation.value,
                      fontWeight: FontWeight.w600,
                      fontFamily:
                          Theme.of(context).textTheme.bodyLarge?.fontFamily,
                    ),
                  );
                },
              ),
              _buildReminderButton(uncompletedTasks),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Stack(
              children: [
                if (tasks.isEmpty)
                  const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.coffee,
                          size: 48,
                          color: Color(0x80000000),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'All tasks completed\nTake a break',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            color: Color(0x80000000),
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                // 任务列表
                FadeTransition(
                  opacity: _cardOpacityAnimation,
                  child: ListView.builder(
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      return _buildTaskCard(task);
                    },
                  ),
                ),
                // "今日事，今日毕" 文字
                FadeTransition(
                  opacity: Tween<double>(begin: 0.0, end: 1.0)
                      .animate(_animationController),
                  child: Container(
                    alignment: Alignment.topLeft,
                    child: const Text(
                      '今日事，今日毕',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Color(0x80000000),
                        letterSpacing: 4,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(Task task) {
    return Dismissible(
      key: ValueKey(task.id),
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        child: const Icon(
          Icons.check,
          color: Colors.green,
          size: 30,
        ),
      ),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(
          Icons.delete_outline,
          color: Colors.red,
          size: 30,
        ),
      ),
      onDismissed: (direction) {
        final taskIndex = context.read<TaskProvider>().tasks.indexOf(task);
        _lastRemovedTask = task;
        _lastRemovedTaskIndex = taskIndex;

        if (direction == DismissDirection.startToEnd) {
          context.read<TaskProvider>().deleteTask(task.id);
          context.read<CompletedTaskProvider>().addCompletedTask(task);
          _showSnackBar('Task completed');
        } else {
          context.read<TaskProvider>().deleteTask(task.id);
          _showSnackBar('Task deleted');
        }
      },
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TaskEditScreen(
                id: task.id,
                title: task.title,
                date: task.date,
                startTime: task.startTime,
                endTime: task.endTime,
                colorIndex: task.colorIndex,
                isImportant: task.isImportant,
                hasReminder: task.hasReminder,
                repeatType: task.repeatType,
              ),
            ),
          );
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 15),
          padding: const EdgeInsets.all(15),
          height: MediaQuery.of(context).size.height / 4,
          decoration: BoxDecoration(
            color: taskColors[task.colorIndex].withOpacity(0.8),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Stack(
            children: [
              Positioned(
                top: 10,
                left: 0,
                right: 0,
                child: SizedBox(
                  height: MediaQuery.of(context).size.height / 8,
                  child: Text(
                    task.title,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: Row(
                  children: [
                    if (task.isImportant)
                      const Icon(
                        Icons.push_pin,
                        color: Colors.white,
                        size: 24,
                      ),
                    if (task.hasReminder)
                      Padding(
                        padding:
                            EdgeInsets.only(left: task.isImportant ? 8 : 0),
                        child: const Icon(
                          Icons.alarm,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                  ],
                ),
              ),
              Positioned(
                bottom: 10,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormat('HH:mm').format(task.startTime),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${task.endTime.difference(task.startTime).inHours}h '
                        '${task.endTime.difference(task.startTime).inMinutes % 60}m',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Text(
                      DateFormat('HH:mm').format(task.endTime),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
