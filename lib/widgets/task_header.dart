import 'package:flutter/material.dart';
import 'package:flutter_firebase/theme/app_colors.dart';
import 'package:flutter_firebase/theme/app_sizes.dart';
import 'package:flutter_firebase/widgets/profile_avatar.dart';

class TaskHeader extends StatelessWidget {
  final String title;
  final String userId;
  final bool isTablet;
  final VoidCallback onProfileTap;

  const TaskHeader({
    super.key,
    required this.title,
    required this.userId,
    required this.isTablet,
    required this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? AppSizes.xl : AppSizes.md,
        vertical: AppSizes.sm,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Centered title pill
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppSizes.md,
              vertical: AppSizes.xs + 2,
            ),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.lightTextPrimary,
              borderRadius: BorderRadius.circular(AppSizes.radiusFull),
            ),
            child: Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: AppSizes.fontMd,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          // Avatar pinned to the right
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: onProfileTap,
              child: ProfileAvatar(
                userId: userId,
                backgroundColor: AppColors.primary,
                iconColor: Colors.white,
                radius: AppSizes.avatarSm,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
