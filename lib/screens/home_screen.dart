import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase/controllers/task_controller.dart';
import 'package:flutter_firebase/models/task_filter_counts.dart';
import 'package:flutter_firebase/providers/task_filter_provider.dart';
import 'package:flutter_firebase/screens/profile_screen.dart';
import 'package:flutter_firebase/services/messaging_service.dart';
import 'package:flutter_firebase/theme/app_colors.dart';
import 'package:flutter_firebase/theme/app_sizes.dart';
import 'package:flutter_firebase/widgets/add_task_sheet.dart';
import 'package:flutter_firebase/widgets/calendar_strip.dart';
import 'package:flutter_firebase/widgets/filter_chips_row.dart';
import 'package:flutter_firebase/widgets/task_header.dart';
import 'package:flutter_firebase/widgets/task_tile.dart';
import 'package:provider/provider.dart';

class TaskScreen extends StatefulWidget {
  final String userId;

  const TaskScreen({super.key, required this.userId});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  final TaskController _taskController = TaskController();
  final MessagingService _messagingService = MessagingService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      await _messagingService.initializeFCM(widget.userId, context);
      await _taskController.runStartupNotificationChecks(widget.userId);
    });
  }

  void _openAddTaskDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AddTaskSheet(
        onSave: (title, body) => _taskController.addTask(
          title: title,
          body: body,
          userId: widget.userId,
        ),
      ),
    );
  }

  void _openProfile() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ProfileScreen(userId: widget.userId)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width >= 600;
    final filterProvider = context.watch<TaskFilterProvider>();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            TaskHeader(
              title: 'Todo App',
              userId: widget.userId,
              isTablet: isTablet,
              onProfileTap: _openProfile,
            ),
            CalendarStrip(
              selectedDate: filterProvider.selectedDate,
              currentWeekStart: filterProvider.currentWeekStart,
              onDateSelected: filterProvider.setSelectedDate,
              onPreviousWeek: filterProvider.showPreviousWeek,
              onNextWeek: filterProvider.showNextWeek,
              isTablet: isTablet,
            ),
            const SizedBox(height: AppSizes.md),
            _TaskFilterBar(
              userId: widget.userId,
              selectedDate: filterProvider.selectedDate,
              taskController: _taskController,
              isTablet: isTablet,
            ),
            const SizedBox(height: AppSizes.md),
            Expanded(
              child: _TaskList(
                userId: widget.userId,
                selectedDate: filterProvider.selectedDate,
                taskController: _taskController,
                isTablet: isTablet,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddTaskDialog,
        child: const Icon(Icons.add, size: AppSizes.iconXl),
      ),
    );
  }
}

class _TaskFilterBar extends StatelessWidget {
  final String userId;
  final DateTime selectedDate;
  final TaskController taskController;
  final bool isTablet;

  const _TaskFilterBar({
    required this.userId,
    required this.selectedDate,
    required this.taskController,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    final filterProvider = context.watch<TaskFilterProvider>();

    return StreamBuilder<QuerySnapshot>(
      stream: taskController.watchTaskCounts(
        userId: userId,
        date: selectedDate,
      ),
      builder: (context, snapshot) {
        final counts = snapshot.hasError
            ? const TaskFilterCounts.error()
            : snapshot.hasData
            ? TaskFilterCounts.fromSnapshot(snapshot.data!)
            : const TaskFilterCounts.empty();

        return FilterChipsRow(
          selectedFilter: filterProvider.filter,
          counts: counts,
          isTablet: isTablet,
          onFilterSelected: filterProvider.setFilter,
        );
      },
    );
  }
}

class _TaskList extends StatelessWidget {
  final String userId;
  final DateTime selectedDate;
  final TaskController taskController;
  final bool isTablet;

  const _TaskList({
    required this.userId,
    required this.selectedDate,
    required this.taskController,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    final filterProvider = context.watch<TaskFilterProvider>();

    return StreamBuilder<QuerySnapshot>(
      stream: taskController.watchTasks(
        userId: userId,
        date: selectedDate,
        filter: filterProvider.filter,
      ),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _TaskErrorState(error: snapshot.error);
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _EmptyTaskState(selectedDate: selectedDate);
        }

        final tasks = taskController.mapAndSortTasks(snapshot.data!);

        return TaskTimelineList(
          tasks: tasks,
          isTablet: isTablet,
          onDeleteTask: (task) => taskController.deleteTask(task.id),
          onToggleTask: (task) =>
              taskController.toggleTaskStatus(userId: userId, task: task),
          onEditTask: (task, title, body) => taskController.updateTask(
            taskId: task.id,
            title: title,
            body: body,
          ),
        );
      },
    );
  }
}

class _TaskErrorState extends StatelessWidget {
  final Object? error;

  const _TaskErrorState({required this.error});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: AppSizes.md),
            const Text(
              'Firestore Error',
              style: TextStyle(
                fontSize: AppSizes.fontXl,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: AppSizes.sm),
            SelectableText(
              '$error',
              style: const TextStyle(fontSize: AppSizes.fontSm),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyTaskState extends StatelessWidget {
  final DateTime selectedDate;

  const _EmptyTaskState({required this.selectedDate});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isToday = _isSameDay(selectedDate, DateTime.now());

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check_circle_outline_rounded,
            size: 64,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
          ),
          const SizedBox(height: AppSizes.md),
          Text(
            'No Available Tasks',
            style: TextStyle(
              fontSize: AppSizes.fontLg,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: AppSizes.xs),
          Text(
            isToday ? 'Tap + to add a new task' : '',
            style: TextStyle(
              fontSize: AppSizes.fontMd,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
