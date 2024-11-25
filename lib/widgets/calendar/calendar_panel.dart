import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import '../../providers/calendar_provider.dart';
import '../../providers/task_provider.dart';
import '../../screens/task_edit_screen.dart';
import 'package:intl/intl.dart';
import '../../database/database_helper.dart';

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

class CalendarPanel extends StatefulWidget {
  const CalendarPanel({super.key});

  @override
  State<CalendarPanel> createState() => _CalendarPanelState();
}

class _CalendarPanelState extends State<CalendarPanel> {
  late ScrollController _dateScrollController;
  late CalendarController _calendarController;
  final List<DateTime> _dates = List.generate(
    14,
    (index) => DateTime.now().add(Duration(days: index - 7)),
  );

  double _timeIntervalHeight = 60.0;
  static const double _minTimeIntervalHeight = 40.0;
  static const double _maxTimeIntervalHeight = 120.0;

  @override
  void initState() {
    super.initState();
    print('CalendarPanel initState 开始');
    _dateScrollController = ScrollController();
    _calendarController = CalendarController();

    // 设置初始日期
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // 立即设置日期和控制器
    _calendarController.displayDate = today;
    context.read<CalendarProvider>().setSelectedDate(today);

    // 立即加载数据
    _loadEvents(_formatDate(today));

    // 滚动到正确位置
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _dateScrollController.animateTo(
        7 * 68.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _dateScrollController.dispose();
    _calendarController.dispose();
    super.dispose();
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  void _onDateSelected(DateTime date) {
    if (!mounted) return;

    setState(() {
      context.read<CalendarProvider>().setSelectedDate(date);
      _calendarController.displayDate = date;
      final now = DateTime.now();
      _calendarController.selectedDate = DateTime(
        date.year,
        date.month,
        date.day,
        now.hour,
        now.minute,
      );
    });

    // 使用日期的 0 点时间作为查询条件
    final queryDate =
        DateTime(date.year, date.month, date.day).toString().split(' ')[0];
    _loadEvents(queryDate);
  }

  void _openTaskEditor(Appointment appointment) async {
    print('开始编辑事件');
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaskEditScreen(
          id: appointment.id as String?,
          title: appointment.subject,
          date: appointment.startTime,
          startTime: appointment.startTime,
          endTime: appointment.endTime,
          colorIndex: taskColors.indexOf(appointment.color),
          isImportant: appointment.isAllDay,
        ),
      ),
    );

    print('编辑结果: $result');
    if (result != null) {
      try {
        // 使用 TaskProvider 的 addTask 方法
        final task = Task(
          id: appointment.id?.toString() ?? DateTime.now().toString(),
          title: result.title,
          date: result.date,
          startTime: result.startTime,
          endTime: result.endTime,
          colorIndex: result.colorIndex,
          isImportant: result.isImportant ?? false,
          hasReminder: result.hasReminder ?? false,
          repeatType: result.repeatType ?? RepeatType.none,
        );

        context.read<TaskProvider>().addTask(task);
        print('事件更新成功');
      } catch (e) {
        print('更新事件时出错: $e');
      }
    }
  }

  String _getHoliday(DateTime date) {
    final holidays = {
      '01-01': '元旦',
      '02-14': '情人节',
      '05-01': '劳动节',
      '06-01': '儿童节',
      '10-01': '国庆节',
      '12-25': '圣诞节',
    };

    final key =
        '${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    return holidays[key] ?? '';
  }

  void _jumpToToday() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    print('跳转到今天: ${_formatDate(today)}');

    // 先更新控制器
    _calendarController.displayDate = today;

    // 延迟更新 Provider
    Future.microtask(() {
      if (mounted) {
        context.read<CalendarProvider>().setSelectedDate(today);
      }
    });

    _dateScrollController.animateTo(
      7 * 68.0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );

    // 加载今天的事件
    _loadEvents(_formatDate(today));
  }

  // 添加加载事件的方法
  Future<void> _loadEvents(String date) async {
    print('开始加载日期 $date 的事件');
    try {
      final events = await DatabaseHelper.instance.getEvents(date);
      print('数据库返回的事件: $events');

      if (!mounted) return;

      if (events.isEmpty) {
        context.read<TaskProvider>().clearTasksForDate(DateTime.parse(date));
        print('清除当前日期的任务');
        return;
      }

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

      print('成功转换为任务列表: $tasks');
      context.read<TaskProvider>().updateTasks(tasks);
    } catch (e) {
      print('加载事件时出错: $e');
      print('错误堆栈: ${StackTrace.current}');
    }
  }

  // 添加一个辅助方法来标准化日期
  String _formatDate(DateTime date) {
    final formattedDate = '${date.year}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
    print('格式化日期: $formattedDate');
    return formattedDate;
  }

  @override
  Widget build(BuildContext context) {
    final selectedDate = context.watch<CalendarProvider>().selectedDate;
    print('CalendarPanel: 当前选中日期: ${selectedDate.toString().split(' ')[0]}');

    final tasks = context.watch<TaskProvider>().getTasksForDate(selectedDate);
    print('CalendarPanel: 获取到的任务数: ${tasks.length}');

    final now = DateTime.now();
    final isToday = _isSameDay(selectedDate, now);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Stack(
        children: [
          Column(
            children: [
              // 日期选择器
              Container(
                height: 80,
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: ListView.builder(
                  controller: _dateScrollController,
                  scrollDirection: Axis.horizontal,
                  itemCount: _dates.length,
                  itemBuilder: (context, index) {
                    final date = _dates[index];
                    final isSelected = _isSameDay(date, selectedDate);

                    return GestureDetector(
                      onTap: () => _onDateSelected(date),
                      child: Container(
                        width: 60,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.black : Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              DateFormat('E').format(date),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color:
                                    isSelected ? Colors.white : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              DateFormat('d').format(date),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: isSelected ? Colors.white : Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              // 当前日期、节日和今天按钮
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Text(
                            DateFormat('yyyy年MM月dd日').format(selectedDate),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 10),
                          if (_getHoliday(selectedDate).isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red[50],
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                _getHoliday(selectedDate),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.red[700],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    // 添加今天按钮
                    if (!_isSameDay(selectedDate, DateTime.now()))
                      TextButton.icon(
                        onPressed: _jumpToToday,
                        icon: const Icon(Icons.today, size: 20),
                        label: const Text('今天'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.black87,
                        ),
                      ),
                  ],
                ),
              ),
              // 分隔线
              Container(
                height: 1,
                color: Colors.grey[200],
              ),
              // 日历视图
              Expanded(
                child: GestureDetector(
                  onScaleUpdate: (details) {
                    setState(() {
                      _timeIntervalHeight =
                          (_timeIntervalHeight * details.scale).clamp(
                              _minTimeIntervalHeight, _maxTimeIntervalHeight);
                    });
                  },
                  child: SfCalendar(
                    controller: _calendarController,
                    view: CalendarView.day,
                    initialDisplayDate: selectedDate,
                    headerHeight: 0,
                    viewHeaderHeight: 0,
                    onViewChanged: (ViewChangedDetails details) {
                      if (!mounted || details.visibleDates.isEmpty) return;

                      final newDate = details.visibleDates.first;
                      final normalizedDate = DateTime(
                        newDate.year,
                        newDate.month,
                        newDate.day,
                      );

                      print('视图切换到日期: ${_formatDate(normalizedDate)}');

                      // 立即更新控制器和选中日期
                      _calendarController.displayDate = normalizedDate;
                      context
                          .read<CalendarProvider>()
                          .setSelectedDate(normalizedDate);

                      // 立即加载数据
                      _loadEvents(_formatDate(normalizedDate));

                      // 更新滚动位置
                      final index = _dates.indexWhere(
                          (date) => _isSameDay(date, normalizedDate));
                      if (index != -1) {
                        _dateScrollController.animateTo(
                          index * 68.0,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    timeSlotViewSettings: TimeSlotViewSettings(
                      startHour: 0,
                      endHour: 24,
                      timeFormat: 'HH:mm',
                      timeIntervalHeight: _timeIntervalHeight,
                      timeTextStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    dataSource: _TaskDataSource(tasks),
                    onLongPress: (CalendarLongPressDetails details) async {
                      print('日历长按事件触发');
                      if (details.targetElement ==
                          CalendarElement.appointment) {
                        _openTaskEditor(details.appointments!.first);
                      } else if (details.targetElement ==
                          CalendarElement.calendarCell) {
                        print('准备创建新事件');
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TaskEditScreen(
                              date: details.date!,
                              startTime: details.date!,
                              endTime:
                                  details.date!.add(const Duration(hours: 1)),
                            ),
                          ),
                        );

                        print('新事件编辑结果: $result');
                        if (result != null) {
                          try {
                            // 直接使用数据库操作
                            final eventData = {
                              'title': result.title,
                              'description': '',
                              'date': result.date.toString(),
                              'color': result.colorIndex,
                            };
                            print('准备保存新事件: $eventData');

                            final id = await DatabaseHelper.instance
                                .insertEvent(eventData);
                            print('新事件保存成功，ID: $id');

                            // 重新加载当前日期的事件
                            await _loadEvents(_formatDate(result.date));
                          } catch (e) {
                            print('添加新事件时出错: $e');
                          }
                        }
                      }
                    },
                    appointmentBuilder: (context, calendarAppointmentDetails) {
                      final appointment =
                          calendarAppointmentDetails.appointments.first;
                      return Container(
                        decoration: BoxDecoration(
                          color: appointment.color.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.all(4),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  appointment.subject,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (constraints.maxHeight > 40)
                                  Flexible(
                                    child: Text(
                                      '${DateFormat('HH:mm').format(appointment.startTime)} - '
                                      '${DateFormat('HH:mm').format(appointment.endTime)}',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 10,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TaskDataSource extends CalendarDataSource {
  _TaskDataSource(List<Task> tasks) {
    appointments = tasks
        .map((task) => Appointment(
              startTime: task.startTime,
              endTime: task.endTime,
              subject: task.title,
              color: taskColors[task.colorIndex],
              isAllDay: task.isImportant,
              id: task.id,
            ))
        .toList();
  }
}
