import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
//* --- STATE 1: THE TERMINATED STATE HANDLER ---
// Wakes up when the app is completely dead/closed. The OS passes the background payload here.

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("============== TERMINATED STATE RECEIVED ==============");
  print("Notification Title: ${message.notification?.title}");
  print("Notification Body: ${message.notification?.body}");
  // Android handles showing the top system bar banner automatically here!
}

class MessagingService {
  static Future<NotificationSettings>? _permissionRequest;
  static bool _backgroundHandlerRegistered = false;

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final CollectionReference _userCollection = FirebaseFirestore.instance
      .collection('users');
  StreamSubscription<String>? _tokenRefreshSubscription;
  StreamSubscription<RemoteMessage>? _foregroundMessageSubscription;
  StreamSubscription<RemoteMessage>? _messageOpenedSubscription;

  Future<void> initializeFCM(String userId, BuildContext context) async {
    if (!_backgroundHandlerRegistered) {
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
      _backgroundHandlerRegistered = true;
    }

    // 1. Request OS Permission permissions (Crucial for Android 13+)
    _permissionRequest ??= _fcm
        .requestPermission(alert: true, badge: true, sound: true)
        .whenComplete(() => _permissionRequest = null);
    await _permissionRequest;

    // 2. Fetch unique token and upload it to the users collection folder
    final token = await _getTokenSafely();
    if (token != null) {
      await _userCollection.doc(userId).set({
        'fcmToken': token,
        'tokenLastUpdated': Timestamp.now(),
      }, SetOptions(merge: true));
    }
    // 3. Listen to active dynamic token refreshes
    _tokenRefreshSubscription ??= _fcm.onTokenRefresh.listen(
      (newToken) {
        _userCollection.doc(userId).set({
          'fcmToken': newToken,
          'tokenLastUpdated': Timestamp.now(),
        }, SetOptions(merge: true));
      },
      onError: (Object error) {
        debugPrint('FCM token refresh failed: $error');
      },
    );
    //* --- STATE 2: THE FOREGROUND STATE HANDLER ---
    // Fires when the user is looking directly at the app. We catch the payload
    // and manually show a beautiful alert matching our 3 scenarios!
    _foregroundMessageSubscription ??= FirebaseMessaging.onMessage.listen((
      RemoteMessage message,
    ) {
      print("============== FOREGROUND STATE RECEIVED ==============");
      if (message.notification != null && context.mounted) {
        final title = message.notification!.title ?? "";
        final body = message.notification!.body ?? "";

        // Check which scenario payload the server sent us, and display an alert
        if (title.contains("Yesterday's Leftovers")) {
          _showInAppDialog(context, title, body, Colors.amber);
        } else if (title.contains('Clean Slate')) {
          _showInAppDialog(context, title, body, Colors.green);
        } else {
          // Standard Daily Fixed Check or default alert
          _showInAppSnackbar(context, title, body);
        }
      }
    });
    //* --- STATE 3: THE BACKGROUND STATE HANDLER ---
    // Fires when the app is minimized, and the user physically taps the top system banner alert.
    _messageOpenedSubscription ??= FirebaseMessaging.onMessageOpenedApp.listen((
      RemoteMessage message,
    ) {
      print("============== BACKGROUND STATE TAP OPENED ==============");
      print(
        "User tapped the banner! Notification payload: ${message.notification?.title}",
      );

      // PORTFOLIO TIP: In a larger app, you would read message.data['screen']
      // and use Navigator.push() to take them to a specific page.
    });
  }

  Future<String?> _getTokenSafely() async {
    try {
      return await _fcm.getToken();
    } on FirebaseException catch (e) {
      debugPrint('FCM registration failed (${e.code}): ${e.message}');
      return null;
    } catch (e) {
      debugPrint('FCM registration failed: $e');
      return null;
    }
  }

  // UI Component: Shows a clean in-app overlay dialog block for major alerts
  void _showInAppDialog(
    BuildContext context,
    String title,
    String body,
    Color accentColor,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.notifications, color: accentColor),
            const SizedBox(width: 10),
            Expanded(child: Text(title)),
          ],
        ),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  // UI Component: Shows a quick toast snackbar for standard briefings
  void _showInAppSnackbar(BuildContext context, String title, String body) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.blueGrey[900],
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        content: Text("**$title**\n$body"),
      ),
    );
  }
}
