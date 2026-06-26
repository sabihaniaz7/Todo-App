import 'package:flutter_firebase/providers/notification_provider.dart';
import 'package:flutter_firebase/screens/about_screen.dart';
import 'package:flutter_firebase/screens/auth_screen.dart';
import 'package:flutter_firebase/screens/pricavy_policy_screen.dart';
import 'package:flutter_firebase/theme/app_colors.dart';
import 'package:flutter_firebase/theme/app_sizes.dart';
import 'package:flutter_firebase/widgets/profile_avatar.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase/providers/theme_provider.dart';
import 'package:flutter_firebase/services/firestore_service.dart';
import 'package:flutter_firebase/services/profile_image_service.dart';

class ProfileScreen extends StatefulWidget {
  final String userId;
  const ProfileScreen({super.key, required this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileImageService _imageService = ProfileImageService();
  final FirestoreService _firestoreService = FirestoreService();
  bool _isUploading = false;

  // Grab the current user details directly from the Firebase Auth instance cache
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  Future<void> _updatePhoto() async {
    setState(() {
      _isUploading = true;
    });
    try {
      final String? base64Result = await _imageService.pickAndConvertImage();
      if (base64Result != null) {
        await _firestoreService.saveUserProfilePicture(
          widget.userId,
          base64Result,
        );
      }
    } catch (e) {
      if (mounted) {
        debugPrint('Error saving photo: $e');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving photo: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Safely extract the user's email string and grab the first letter
    final userEmail = _currentUser?.email ?? 'User';
    final userName = _currentUser?.displayName ?? 'User';
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final themeProvider = context.watch<ThemeProvider>();
    final notifProvider = context.watch<NotificationProvider>();
    final size = MediaQuery.of(context).size;
    final isTablet = size.width >= 600;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Profile"),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_rounded,
            size: AppSizes.iconMd,
            color: isDark
                ? AppColors.darkTextPrimary
                : AppColors.lightTextPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? AppSizes.xxl : AppSizes.md,
            vertical: AppSizes.md,
          ),
          child: Column(
            children: [
              // Profile Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSizes.md),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primary, AppColors.primary],
                  ),
                  borderRadius: BorderRadius.circular(AppSizes.radiusXl),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.35),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Avatar with edit overlay
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        // Reusable ProfileAvatar widget with caching and shimmer
                        ProfileAvatar(
                          userId: widget.userId,
                          radius: AppSizes.avatarXl,
                        ),
                        // Upload Overlay
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _isUploading ? null : _updatePhoto,
                            child: Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.2),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                              child: _isUploading
                                  ? const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.primary,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.camera_alt_rounded,
                                      size: AppSizes.iconSm + 2,
                                      color: AppColors.primary,
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: AppSizes.md),
                    // Display profile email metadata text field
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize:
                            MainAxisSize.min, // Clean bounding alignment
                        children: [
                          Text(
                            userName,
                            style: const TextStyle(
                              fontSize: AppSizes.fontXxl,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: AppSizes.xs),
                          Text(
                            userEmail,
                            // maxLines: 1,
                            style: TextStyle(
                              fontSize: AppSizes.fontMd,
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ),

                    ////
                  ],
                ),
              ),
              const SizedBox(height: AppSizes.lg),

              // ── Settings Sections ─────────────────────────────────────────
              _SectionCard(
                title: 'Preferences',
                children: [
                  _ToggleTile(
                    icon: Icons.dark_mode_rounded,
                    iconColor: AppColors.primary,
                    title: 'Theme',
                    subtitle: themeProvider.isDark ? 'Dark Mode' : 'Light Mode',
                    value: themeProvider.isDark,
                    onChanged: (_) => themeProvider.toggleTheme(),
                  ),
                  _DividerLine(),
                  _ToggleTile(
                    icon: Icons.notifications_outlined,
                    iconColor: AppColors.primary,
                    title: 'Notifications',
                    subtitle: notifProvider.enabled
                        ? 'Push notifications on'
                        : 'Notifications off',
                    value: notifProvider.enabled,
                    onChanged: (_) => notifProvider.toggleNotifications(),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.md),
              _SectionCard(
                title: 'Tasks',
                children: [
                  _ActionTile(
                    icon: Icons.history_rounded,
                    iconColor: AppColors.primary,
                    title: 'Clear History',
                    subtitle: 'Remove all completed tasks',
                    onTap: _confirmClearHistory,
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.md),

              _SectionCard(
                title: 'About & Support',
                children: [
                  _ActionTile(
                    icon: Icons.info_outline_rounded,
                    iconColor: AppColors.primary,
                    title: 'About',
                    subtitle: 'Version 1.0.0',
                    onTap: _showAbout,
                  ),
                  _DividerLine(),
                  _ActionTile(
                    icon: Icons.privacy_tip_outlined,
                    iconColor: AppColors.primary,
                    title: 'Privacy Policy',
                    subtitle: 'How we handle your data',
                    onTap: () => _openPrivacyPolicy(),
                  ),

                  // _DividerLine(),
                  // _ActionTile(
                  //   icon: Icons.share_rounded,
                  //   iconColor: AppColors.primary,
                  //   title: 'Share',
                  //   subtitle: 'Tell your friends about Todo App',
                  //   onTap: _shareApp,
                  // ),
                ],
              ),

              const SizedBox(height: AppSizes.md),

              _SectionCard(
                title: 'Account',
                children: [
                  _ActionTile(
                    icon: Icons.logout_rounded,
                    iconColor: AppColors.primary,
                    title: 'Sign Out',
                    subtitle: 'Sign out of your account',
                    onTap: _confirmLogout,
                    titleColor: AppColors.danger,
                  ),
                ],
              ),

              const SizedBox(height: AppSizes.xl),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmClearHistory() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Clear History', textAlign: TextAlign.center),
        content: Text(
          'Are you sure you want to permanently delete all completed tasks? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await _firestoreService.clearCompletedTasks(widget.userId);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Completed Tasks successfully cleared'),
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to clear history')),
                  );
                }
              }
            },
            child: Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text(
          'Are you sure you want to sign out of your account?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () async {
              Navigator.pop(ctx); // Close dialog window frame

              try {
                // Terminate authentication session cache state cleanly
                await FirebaseAuth.instance.signOut();

                if (mounted) {
                  // Pop back to Auth screen or clear route history stack entirely
                  Navigator.of(
                    context,
                  ).push(MaterialPageRoute(builder: (context) => AuthScreen()));
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error signing out: $e')),
                  );
                }
              }
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  void _showAbout() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AboutScreen()),
    );
  }

  void _openPrivacyPolicy() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PrivacyPolicyScreen()),
    );
  }
}

// ── Reusable section card ──────────────────────────────────────────────────────
class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SectionCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: AppSizes.xs,
            bottom: AppSizes.sm,
          ),
          child: Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: AppSizes.fontXs,
              fontWeight: FontWeight.w800,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
              letterSpacing: 1.2,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : AppColors.lightCard,
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

// ── Action tile ────────────────────────────────────────────────────────────────
class _ActionTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? titleColor;
  final Widget? trailing;

  const _ActionTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.titleColor,
  }) : trailing = null;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.md,
          vertical: AppSizes.md,
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.22),
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              ),
              child: Icon(icon, color: iconColor, size: AppSizes.iconMd),
            ),
            const SizedBox(width: AppSizes.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: AppSizes.fontMd,
                      fontWeight: FontWeight.w700,
                      color:
                          titleColor ??
                          (isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.lightTextPrimary),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: AppSizes.fontSm,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            ),
            trailing ??
                Icon(
                  Icons.chevron_right_rounded,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                  size: AppSizes.iconMd,
                ),
          ],
        ),
      ),
    );
  }
}

// ── Divider ────────────────────────────────────────────────────────────────────
// ── Toggle tile ────────────────────────────────────────────────────────────────
class _ToggleTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _ToggleTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });
  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.md,
        vertical: AppSizes.sm,
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.22),
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            ),
            child: Icon(icon, color: iconColor, size: AppSizes.iconMd),
          ),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: AppSizes.fontMd,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: AppSizes.fontSm,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _DividerLine extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(left: AppSizes.md + 38 + AppSizes.md),
      child: Divider(
        height: 1,
        color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
      ),
    );
  }
}
