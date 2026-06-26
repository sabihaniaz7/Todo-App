// ── Add Task Bottom Sheet ─────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:flutter_firebase/providers/add_task_sheet_provider.dart';
import 'package:flutter_firebase/theme/app_colors.dart';
import 'package:flutter_firebase/theme/app_sizes.dart';
import 'package:provider/provider.dart';

class AddTaskSheet extends StatefulWidget {
  final String? initialTitle;
  final String? initialBody;
  final Future<void> Function(String title, String body) onSave;

  const AddTaskSheet({
    super.key,
    this.initialTitle,
    this.initialBody,
    required this.onSave,
  });

  @override
  State<AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends State<AddTaskSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _bodyController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle);
    _bodyController = TextEditingController(text: widget.initialBody);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AddTaskSheetProvider(),
      child: Consumer<AddTaskSheetProvider>(
        builder: (context, sheetProvider, _) {
          final bool isDark = Theme.of(context).brightness == Brightness.dark;
          final bottom = MediaQuery.of(context).viewInsets.bottom;

          return Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppSizes.radiusXl),
              ),
            ),
            padding: EdgeInsets.fromLTRB(
              AppSizes.lg,
              AppSizes.lg,
              AppSizes.lg,
              AppSizes.lg + bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: AppSizes.xs,
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.darkBorder
                          : AppColors.lightBorder,
                      borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                    ),
                  ),
                ),
                const SizedBox(height: AppSizes.lg),
                Text(
                  widget.initialTitle != null ? 'Edit Task' : 'New Task',
                  style: TextStyle(
                    fontSize: AppSizes.fontXxl,
                    fontWeight: FontWeight.w800,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                  ),
                ),
                const SizedBox(height: AppSizes.md),
                TextField(
                  controller: _titleController,
                  autofocus:
                      widget.initialTitle == null, // Autofocus only on create
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: AppSizes.fontLg,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    hintText: 'What needs to be done?',
                  ),
                ),
                const SizedBox(height: AppSizes.md),
                TextField(
                  controller: _bodyController,
                  maxLines: 3,
                  minLines: 1,
                  style: TextStyle(
                    fontSize: AppSizes.fontMd,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Description (optional)',
                    hintText: 'Add description...',
                  ),
                ),
                const SizedBox(height: AppSizes.lg),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton(
                        onPressed: sheetProvider.saving
                            ? null
                            : () async {
                                if (_titleController.text.trim().isEmpty)
                                  return;
                                await sheetProvider.save(
                                  () => widget.onSave(
                                    _titleController.text.trim(),
                                    _bodyController.text.trim(),
                                  ),
                                );
                                if (context.mounted) Navigator.pop(context);
                              },
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSizes.md,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppSizes.radiusMd,
                            ),
                          ),
                        ),
                        child: sheetProvider.saving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                widget.initialTitle != null
                                    ? 'Save Changes'
                                    : 'Save Task',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
