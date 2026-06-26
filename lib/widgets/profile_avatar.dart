import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_firebase/providers/profile_avatar_provider.dart';
import 'package:flutter_firebase/theme/app_sizes.dart';
import 'package:provider/provider.dart';

/// A widget that displays the user's profile avatar.
///
/// It caches the fetched base64 image data to avoid flickering on rebuilds and
/// shows a shimmer placeholder while the data is loading.
class ProfileAvatar extends StatefulWidget {
  final String userId;
  final double radius;
  final Color? backgroundColor;
  final Color? iconColor;
  const ProfileAvatar({
    super.key,
    required this.userId,
    required this.radius,
    this.backgroundColor,
    this.iconColor,
  });

  @override
  State<ProfileAvatar> createState() => _ProfileAvatarState();
}

class _ProfileAvatarState extends State<ProfileAvatar>
    with SingleTickerProviderStateMixin {
  // Shimmer animation controller
  late final AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProfileAvatarProvider(userId: widget.userId),
      child: Consumer<ProfileAvatarProvider>(
        builder: (context, avatarProvider, _) {
          if (avatarProvider.loading && avatarProvider.cachedBase64 == null) {
            // show perosn Icon
            return CircleAvatar(
              radius: widget.radius,
              backgroundColor: widget.backgroundColor,
              child: Icon(
                Icons.person,
                color: widget.iconColor,
                size: AppSizes.iconXl,
              ),
            );
          }
          //  Main Avatar state (Loaded or Done checking)
          final cachedBase64 = avatarProvider.cachedBase64;
          final bool hasImage = cachedBase64 != null && cachedBase64.isNotEmpty;
          return CircleAvatar(
            radius: widget.radius,
            backgroundImage: hasImage
                ? MemoryImage(base64Decode(cachedBase64))
                : null,
            // If we DO NOT have an image, show the person icon. If we have an image, child is null.
            child: !hasImage
                ? Icon(
                    Icons.person,
                    color: widget.iconColor,
                    size: AppSizes.iconXl,
                  )
                : null,
          );
        },
      ),
    );
  }
}
