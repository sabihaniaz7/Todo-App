import 'package:flutter/material.dart';
import 'package:flutter_firebase/models/todo_task.dart';
import 'package:flutter_firebase/theme/app_colors.dart';
import 'package:flutter_firebase/theme/app_sizes.dart';
import 'package:flutter_firebase/widgets/add_task_sheet.dart';
import 'package:intl/intl.dart';

class TaskTimelineList extends StatelessWidget {
  final List<TodoTask> tasks;
  final bool isTablet;
  final ValueChanged<TodoTask> onDeleteTask;
  final ValueChanged<TodoTask> onToggleTask;
  final void Function(TodoTask task, String title, String body) onEditTask;

  const TaskTimelineList({
    super.key,
    required this.tasks,
    required this.onDeleteTask,
    required this.onToggleTask,
    required this.onEditTask,
    this.isTablet = false,
  });

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return const Center(child: Text('No tasks for today.'));
    }

    return ListView.builder(
      padding: EdgeInsets.only(
        left: isTablet ? AppSizes.xl : AppSizes.md,
        right: isTablet ? AppSizes.xl : AppSizes.md,
        top: AppSizes.xs,
        bottom: AppSizes.xxl + AppSizes.xl,
      ),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return _TimelineTileRow(
          key: Key(task.id),
          task: task,
          isFirst: index == 0,
          isLast: index == tasks.length - 1,
          onDeleteTask: onDeleteTask,
          onToggleTask: onToggleTask,
          onEditTask: onEditTask,
        );
      },
    );
  }
}

class _TimelineTileRow extends StatelessWidget {
  final TodoTask task;
  final bool isFirst;
  final bool isLast;
  final ValueChanged<TodoTask> onDeleteTask;
  final ValueChanged<TodoTask> onToggleTask;
  final void Function(TodoTask task, String title, String body) onEditTask;

  const _TimelineTileRow({
    super.key,
    required this.task,
    required this.isLast,
    required this.isFirst,
    required this.onDeleteTask,
    required this.onToggleTask,
    required this.onEditTask,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final timeLabel = DateFormat('h:mm a').format(task.displayTime);
    final lineFillColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return Dismissible(
      key: Key(task.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) {
        onDeleteTask(task);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Task "${task.title}" removed')));
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.lg),
        child: const Icon(
          Icons.delete_outline_rounded,
          color: AppColors.danger,
          size: 24,
        ),
      ),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: task.isCompleted ? 0.50 : 1.0,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: AppSizes.xl,
                child: Column(
                  children: [
                    Container(
                      width: 2,
                      height: 14,
                      color: isFirst ? Colors.transparent : lineFillColor,
                    ),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: task.isCompleted
                            ? AppColors.primary
                            : (isDark ? Colors.white : Colors.black),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        width: 2,
                        color: isLast ? Colors.transparent : lineFillColor,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: AppSizes.sm,
                    bottom: AppSizes.md,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              task.title,
                              style: TextStyle(
                                fontSize: AppSizes.fontMd,
                                fontWeight: FontWeight.w700,
                                color: task.isCompleted
                                    ? Colors.grey
                                    : (isDark
                                          ? AppColors.darkTextPrimary
                                          : AppColors.lightTextPrimary),
                              ),
                            ),
                            if (task.body.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                task.body,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: AppSizes.fontSm,
                                  color: isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.lightTextSecondary,
                                ),
                              ),
                            ],
                            const SizedBox(height: 6),
                            Text(
                              timeLabel,
                              style: TextStyle(
                                fontSize: AppSizes.fontXs,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () => _showEditBottomSheet(context),
                            icon: Icon(
                              Icons.edit_outlined,
                              size: 20,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary.withValues(
                                      alpha: 0.6,
                                    ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => onToggleTask(task),
                            icon: Icon(
                              task.isCompleted
                                  ? Icons.check_circle_outline_outlined
                                  : Icons.access_time_rounded,
                              size: 22,
                              color: task.isCompleted
                                  ? AppColors.primary
                                  : (isDark
                                        ? AppColors.darkTextSecondary
                                        : AppColors.lightTextSecondary
                                              .withValues(alpha: 0.6)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AddTaskSheet(
        initialTitle: task.title,
        initialBody: task.body,
        onSave: (newTitle, newBody) async =>
            onEditTask(task, newTitle, newBody),
      ),
    );
  }
}
