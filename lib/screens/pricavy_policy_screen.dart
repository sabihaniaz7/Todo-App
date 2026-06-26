import 'package:flutter/material.dart';
import 'package:flutter_firebase/theme/app_colors.dart';
import 'package:flutter_firebase/theme/app_sizes.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D0D0D) : Colors.grey[50],
      appBar: AppBar(
        // title: const Text(
        //   'Privacy Policy',
        //   style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800),
        // ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.lg,
            vertical: AppSizes.md,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your Data, Encrypted & Secured',
                style: TextStyle(
                  fontSize: AppSizes.fontXxl,
                  fontWeight: FontWeight.w900,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ),
              ),
              // const SizedBox(height: AppSizes.sm),
              // Text(
              //   'Last updated: June 2026',
              //   style: TextStyle(
              //     fontFamily: 'Nunito',
              //     fontSize: 12,
              //     fontWeight: FontWeight.w600,
              //     color: isDark ? Colors.white38 : Colors.black38,
              //   ),
              // ),
              const SizedBox(height: AppSizes.sm),
              const Divider(color: Colors.white10),
              const SizedBox(height: AppSizes.lg),

              _buildPolicySection(
                context,
                title: '1. Account & Password Security',
                body:
                    'We use Google Firebase to handle logins securely. Your password is encrypted instantly, meaning it is completely hidden and can never be seen or read by us.',
              ),
              _buildPolicySection(
                context,
                title: '2. How Your Tasks Are Saved',
                body:
                    'Your tasks, categories, and updates are saved in a secure cloud database. Strict safety rules are in place so that only you can see, edit, or access your own information.',
              ),
              _buildPolicySection(
                context,
                title: '3. App Notifications',
                body:
                    'We only use notifications to remind you about your task deadlines. We never track your activity or send you spam, ads, or promotional messages.',
              ),
              _buildPolicySection(
                context,
                title: '4. Storage & Deleting Data',
                body:
                    'Your app settings (like your Dark/Light mode preference) and offline tasks are saved directly on your phone. If you clear your app data or delete your account, everything is permanently wiped clean instantly.',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPolicySection(
    BuildContext context, {
    required String title,
    required String body,
  }) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: AppSizes.fontLg,
              fontWeight: FontWeight.w800,
              color: AppColors.primary, // Unified purple tone match
            ),
          ),
          const SizedBox(height: AppSizes.xs),
          Text(
            body,
            style: TextStyle(
              fontSize: AppSizes.fontMd,
              height: 1.5,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
