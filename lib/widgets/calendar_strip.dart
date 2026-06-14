import 'package:flutter_firebase/theme/app_colors.dart';
import 'package:flutter_firebase/theme/app_sizes.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

class CalendarStrip extends StatefulWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  final bool isTablet;
  const CalendarStrip({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
    required this.isTablet,
  });

  @override
  State<CalendarStrip> createState() => _CalendarStripState();
}

class _CalendarStripState extends State<CalendarStrip> {
  late DateTime _currentWeekStart;
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _currentWeekStart = _getWeekStart(widget.selectedDate);
    _scrollToSelectedDate(jump: true);
  }

  @override
  void didUpdateWidget(covariant CalendarStrip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_isSameDay(oldWidget.selectedDate, widget.selectedDate)) {
      _currentWeekStart = _getWeekStart(widget.selectedDate);
      _scrollToSelectedDate();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  DateTime _getWeekStart(DateTime date) {
    final dayOfWeek = date.weekday; //1=monday, 7=sunday
    return date.subtract(Duration(days: dayOfWeek - 1));
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  void _scrollToSelectedDate({bool jump = false}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;

      final selectedIndex = widget.selectedDate
          .difference(_currentWeekStart)
          .inDays
          .clamp(0, 6);
      const itemStride = AppSizes.calendarDayWidth + AppSizes.sm;
      final viewportWidth = _scrollController.position.viewportDimension;
      final targetOffset =
          (selectedIndex * itemStride) -
          ((viewportWidth - AppSizes.calendarDayWidth) / 2);
      final clampedOffset = targetOffset.clamp(
        0.0,
        _scrollController.position.maxScrollExtent,
      );

      if (jump) {
        _scrollController.jumpTo(clampedOffset);
        return;
      }

      _scrollController.animateTo(
        clampedOffset,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
    });
  }

  void _prevWeek() {
    setState(() {
      _currentWeekStart = _currentWeekStart.subtract(Duration(days: 7));
    });
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
    );
  }

  void _nextWeek() {
    setState(
      () => _currentWeekStart = _currentWeekStart.add(const Duration(days: 7)),
    );
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
    );
  }

  /// Helper utility that checks month name character width rules dynamically
  String _getFormattedMonthName(DateTime date) {
    final String fullMonthName = DateFormat('MMMM').format(date);
    if (fullMonthName.length > 5) {
      return DateFormat('MMM').format(date); // E.g., February -> Feb
    }
    return fullMonthName; // E.g., June, May, April remain unmutated
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final now = DateTime.now();
    // Determine month label based on the selected date if it falls within the current week view.
    // Otherwise, default to the current week's start date.
    final weekEnd = _currentWeekStart.add(const Duration(days: 6));
    final bool isSelectedDateInvisibleWeek =
        (widget.selectedDate.isAfter(_currentWeekStart) ||
            _isSameDay(widget.selectedDate, _currentWeekStart)) &&
        (widget.selectedDate.isBefore(weekEnd) ||
            _isSameDay(widget.selectedDate, weekEnd));
    final monthLabel = DateFormat('MMMM').format(
      isSelectedDateInvisibleWeek ? widget.selectedDate : _currentWeekStart,
    );
    final days = List.generate(
      7,
      (i) => _currentWeekStart.add(Duration(days: i)),
    );
    return Column(
      children: [
        // Month row with arrows
        Padding(
          padding: EdgeInsetsGeometry.symmetric(
            horizontal: widget.isTablet ? AppSizes.xl : AppSizes.md,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: _prevWeek,
                child: Icon(
                  Icons.arrow_back_ios_rounded,
                  size: AppSizes.iconSm,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: AppSizes.sm),
              Text(
                monthLabel,
                style: TextStyle(
                  fontSize: AppSizes.fontLg,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(width: AppSizes.sm),
              GestureDetector(
                onTap: _nextWeek,
                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: AppSizes.iconSm,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSizes.md),
        // Days row
        SizedBox(
          height: AppSizes.calendarDayHeight,
          child: ListView.builder(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(
              horizontal: widget.isTablet ? AppSizes.xl : AppSizes.md,
            ),
            itemCount: 7,
            itemBuilder: (context, index) {
              final day = days[index];
              final isSelected =
                  day.year == widget.selectedDate.year &&
                  day.month == widget.selectedDate.month &&
                  day.day == widget.selectedDate.day;
              final isToday =
                  day.year == now.year &&
                  day.month == now.month &&
                  day.day == now.day;

              return GestureDetector(
                onTap: () => widget.onDateSelected(day),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutCubic,
                  width: AppSizes.calendarDayWidth,
                  margin: const EdgeInsets.only(right: AppSizes.sm),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary
                        : isDark
                        ? AppColors.darkCard
                        : Colors.black87,
                    borderRadius: BorderRadius.circular(
                      AppSizes.calendarDayRadius,
                    ),
                    border: isToday && !isSelected
                        ? Border.all(color: AppColors.primary, width: 2)
                        : Border.all(
                            color: isDark
                                ? AppColors.darkBorder
                                : AppColors.lightBorder,
                          ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.35),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        DateFormat('EEE').format(day).substring(0, 3),
                        style: TextStyle(
                          fontSize: AppSizes.fontSm,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? Colors.white.withValues(alpha: 0.85)
                              : isDark
                              ? AppColors.darkTextSecondary
                              : Colors.white.withValues(alpha: 0.85),
                        ),
                      ),
                      const SizedBox(height: AppSizes.xs),
                      Text(
                        day.day.toString().padLeft(2, '0'),
                        style: TextStyle(
                          fontSize: AppSizes.fontDisplay,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: AppSizes.xs),
                      Text(
                        _getFormattedMonthName(day),
                        style: TextStyle(
                          fontSize: AppSizes.fontXs,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? Colors.white.withValues(alpha: 0.75)
                              : isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                      ),
                      if (isToday && isSelected)
                        Padding(
                          padding: const EdgeInsets.only(top: 3),
                          child: Container(
                            width: 5,
                            height: 5,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
