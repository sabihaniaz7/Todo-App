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
                title: '1. Account Credentials & Security',
                body:
                    'Todo App utilizes secure Firebase Authentication servers. Your passwords are processed natively via Firebase Identity Provider tools and are never visible to or stored by us in unencrypted, plain-text formats.',
              ),
              _buildPolicySection(
                context,
                title: '2. Cloud Database Infrastructure',
                body:
                    'Your personal tasks, filter criteria, and contextual task updates are hosted inside Cloud Firestore instances. Data entries are strongly partitioned using server-side Security Rules, restricting read and write access strictly to the authenticated owner account.',
              ),
              _buildPolicySection(
                context,
                title: '3. Device Notification Triggers',
                body:
                    'Local alert channels and Firebase Cloud Messaging tokens are used solely to remind you of pending task durations or contextual deadlines. No analytics or promotional payload tracking is attached.',
              ),
              _buildPolicySection(
                context,
                title: '4. Offline Storage Boundaries',
                body:
                    'Cached data points (including current app theme logs and offline task changes) reside locally within sandboxed app storage. Clearing app cache or deleting your user account thoroughly wipes these variables instantly.',
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
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFFB19FFB), // Unified purple tone match
            ),
          ),
          const SizedBox(height: AppSizes.xs),
          Text(
            body,
            style: TextStyle(
              fontSize: 14,
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
