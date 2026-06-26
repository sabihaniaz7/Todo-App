import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase/services/firestore_service.dart';

class ProfileAvatarProvider extends ChangeNotifier {
  final String userId;
  final FirestoreService _firestoreService;
  StreamSubscription<DocumentSnapshot>? _subscription;
  String? _cachedBase64;
  bool _loading = true;
  bool _disposed = false;

  ProfileAvatarProvider({
    required this.userId,
    FirestoreService? firestoreService,
  }) : _firestoreService = firestoreService ?? FirestoreService() {
    _subscribe();
  }

  String? get cachedBase64 => _cachedBase64;
  bool get loading => _loading;

  void _subscribe() {
    _subscription = _firestoreService
        .getUserProfilStream(userId)
        .listen(
          (snapshot) {
            final data = snapshot.data() as Map<String, dynamic>?;
            final base64String = data?['profilePicData'] as String?;
            final userName = data?['userName'] as String?;

            if (base64String != null) _cachedBase64 = base64String;
            if (userName != null) _loading = false;
            if (!_disposed) notifyListeners();
          },
          onError: (_) {
            _loading = false;
            if (!_disposed) notifyListeners();
          },
        );
  }

  @override
  void dispose() {
    _disposed = true;
    _subscription?.cancel();
    super.dispose();
  }
}
