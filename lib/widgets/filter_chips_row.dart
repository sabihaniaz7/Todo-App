import 'package:flutter/material.dart';
import 'package:flutter_firebase/models/task_filter_counts.dart';
import 'package:flutter_firebase/providers/task_filter_provider.dart';
import 'package:flutter_firebase/theme/app_colors.dart';
import 'package:flutter_firebase/theme/app_sizes.dart';

class FilterChipsRow extends StatelessWidget {
  final TaskFilter selectedFilter;
  final TaskFilterCounts counts;
  final ValueChanged<TaskFilter> onFilterSelected;
  final bool isTablet;

  const FilterChipsRow({
    super.key,
    required this.selectedFilter,
    required this.counts,
    required this.onFilterSelected,
    this.isTablet = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(
          horizontal: isTablet ? AppSizes.xl : AppSizes.md,
        ),
        children: [
          _FilterChip(
            label: 'All',
            count: counts.total,
            filter: TaskFilter.all,
            selectedFilter: selectedFilter,
            color: AppColors.darkTextSecondary,
            onTap: onFilterSelected,
          ),
          const SizedBox(width: AppSizes.sm),
          _FilterChip(
            label: 'Pending',
            count: counts.pending,
            filter: TaskFilter.pending,
            selectedFilter: selectedFilter,
            color: AppColors.pending,
            onTap: onFilterSelected,
          ),
          const SizedBox(width: AppSizes.sm),
          _FilterChip(
            label: 'Completed',
            count: counts.completed,
            filter: TaskFilter.completed,
            selectedFilter: selectedFilter,
            color: AppColors.completed,
            onTap: onFilterSelected,
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final int count;
  final TaskFilter filter;
  final TaskFilter selectedFilter;
  final Color color;
  final ValueChanged<TaskFilter> onTap;

  const _FilterChip({
    required this.label,
    required this.count,
    required this.filter,
    required this.selectedFilter,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = selectedFilter == filter;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => onTap(filter),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : isDark
                ? AppColors.darkBorder
                : AppColors.lightBorder,
            width: 2,
          ),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.sm,
          vertical: AppSizes.sm,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: AppSizes.fontSm,
                fontWeight: FontWeight.w800,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                count == -1 ? '!' : count.toString(),
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
