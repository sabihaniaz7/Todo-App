import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase/services/firestore_service.dart';
import 'package:flutter_firebase/theme/app_sizes.dart';

/// A widget that displays the user's profile avatar.
///
/// It caches the fetched base64 image data to avoid flickering on rebuilds and
/// shows a shimmer placeholder while the data is loading.
class ProfileAvatar extends StatefulWidget {
  final String userId;
  final double radius;
  const ProfileAvatar({super.key, required this.userId, required this.radius});

  @override
  State<ProfileAvatar> createState() => _ProfileAvatarState();
}

class _ProfileAvatarState extends State<ProfileAvatar>
    with SingleTickerProviderStateMixin {
  final FirestoreService _firestoreService = FirestoreService();
  StreamSubscription<DocumentSnapshot>? _subscription;
  String? _cachedBase64;
  String? _cachedUserName;
  bool _loading = true;

  // Shimmer animation controller
  late final AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _subscribe();
  }

  void _subscribe() {
    _subscription = _firestoreService
        .getUserProfilStream(widget.userId)
        .listen(
          (snapshot) {
            if (!mounted) return;
            final data = (snapshot.data() as Map<String, dynamic>?);
            final base64String = data?['profilePicData'] as String?;
            final userName = data?['userName'] as String?;
            setState(() {
              // Keep previous cached data if null to avoid flicker on temporary loss
              if (base64String != null) _cachedBase64 = base64String;
              if (userName != null) _cachedUserName = userName;
              _loading = false;
            });
          },
          onError: (_) {
            setState(() {
              _loading = false;
            });
          },
        );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading && _cachedBase64 == null) {
      // show perosn Icon
      return CircleAvatar(
        radius: widget.radius,
        backgroundColor: Colors.white.withAlpha(20),
        child: const Icon(
          Icons.person,
          color: Colors.white,
          size: AppSizes.iconXl,
        ),
      );
    }
    return CircleAvatar(
      radius: widget.radius,
      backgroundColor: Colors.white.withAlpha(20),
      backgroundImage: _cachedBase64 != null
          ? MemoryImage(base64Decode(_cachedBase64!))
          : null,
      child: _cachedBase64 == null
          ? Text(
              _cachedUserName != null && _cachedUserName!.isNotEmpty
                  ? _cachedUserName![0].toUpperCase()
                  : '?',
              style: const TextStyle(
                color: Colors.white,
                fontSize: AppSizes.fontDisplay,
                fontWeight: FontWeight.bold,
              ),
            )
          : null,
    );
  }
}
