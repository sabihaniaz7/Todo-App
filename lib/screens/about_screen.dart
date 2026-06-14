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
                  fontFamily: 'Nunito',
                  fontSize: AppSizes.fontDisplay,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFFB19FFB), // Signature light purple tone
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                'Version 1.0.0',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 13,
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
                title: 'The Mission',
                content:
                    'A minimal, lightning-fast task management platform designed to eliminate cognitive overload. Built to help individuals structure their daily routines smoothly with state-of-the-art cloud workflows.',
              ),

              _buildAboutCard(
                context,
                title: 'Firebase Engine Ecosystem',
                content:
                    '• Cloud Firestore: Realtime multi-device database synchronization.\n'
                    '• Firebase Auth: Secure JWT-backed authentication via Email/Password credentials and Google Identity Credential Manager.\n'
                    '• Offline Persistence: Seamless local caching allowing full offline task mutations that sync instantly when back online.',
              ),

              _buildAboutCard(
                context,
                title: 'Core App Features',
                content:
                    '• Contextual Task Filtering: Switch between active, completed, and high-priority states dynamically.\n'
                    '• Native Theme Engine: Fluid architectural transitions between custom True Dark and Light UI modes.\n'
                    '• Local Notification Engine: Low-overhead scheduling threads for task deadlines and contextual reminders.',
              ),

              // Footer Metadata
              const SizedBox(height: AppSizes.xl),
              const Center(
                child: Text(
                  '© 2026 By Sabiha Niaz.',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 12,
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
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFFB19FFB), // Matching your custom accent color
            ),
          ),
          const SizedBox(height: AppSizes.sm),
          Text(
            content,
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 14,
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
