import 'package:flutter/material.dart';
import 'package:flutter_firebase/theme/app_colors.dart';
import 'package:flutter_firebase/theme/app_sizes.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D0D0D) : Colors.grey[50],
      appBar: AppBar(
        // title: const Text(
        //   'About App',
        //   style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800),
        // ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      // FIX: Removed Positioned.fill and replaced with a clean, scrollable layout structure
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Application Branding Header
              Text(
                'Todo App',
                style: TextStyle(
                  fontSize: AppSizes.fontDisplay,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary, // Signature light purple tone
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                'Version 1.0.0',
                style: TextStyle(
                  fontSize: AppSizes.fontMd,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSizes.xl),
              const Divider(color: Colors.white10),

              // Enhanced Technical Spec Cards
              _buildAboutCard(
                context,
                // suggest title
                title: 'About This App',
                content:
                    'A clean, super-fast app designed to help you organize your daily routines and stay on track, keeping everything synced safely to the cloud.',
              ),

              _buildAboutCard(
                context,
                title: 'Cloud Powered System',
                content:
                    '• Live Sync: Your tasks update instantly across all your devices.\n'
                    '• Secure Login: Keep your account safe using your Email or your Google account.\n'
                    '• Works Offline: Create and manage tasks even without internet. Your changes will save and update automatically the moment you reconnect.',
              ),

              _buildAboutCard(
                context,
                title: 'Key Features',
                content:
                    '• Smart Filters: Easily switch views to see your ongoing, completed, or high-priority tasks.\n'
                    '• Dark & Light Modes: A beautiful design that switches smoothly between light and eye-friendly dark layouts.\n'
                    '• Smart Reminders: Timely notifications to make sure you never miss an important deadline or task.',
              ),

              // Footer Metadata
              const SizedBox(height: AppSizes.xl),
              const Center(
                child: Text(
                  '© 2026 By Sabiha Niaz.',
                  style: TextStyle(
                    fontSize: AppSizes.fontSm,
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.md),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAboutCard(
    BuildContext context, {
    required String title,
    required String content,
  }) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.lg),
      margin: const EdgeInsets.only(bottom: AppSizes.lg),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: AppSizes.fontLg,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: AppSizes.sm),
          Text(
            content,
            style: TextStyle(
              fontSize: AppSizes.fontMd,
              height: 1.5,
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
