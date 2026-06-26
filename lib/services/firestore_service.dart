import 'dart:convert';
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  //* Create a pointer referencing our "tasks" collection folder on the server
  final CollectionReference _tasksCollection = FirebaseFirestore.instance
      .collection('tasks');

  //*               ---- CREATE ----
  // Adds a brand new task file to the server database
  Future<void> addTask(String title, String body, String userId) async {
    final now = Timestamp.now();
    await _tasksCollection.add({
      'title': title,
      'body': body,
      'isCompleted': false,
      'userId': userId, // Isolates data so users only see their own tasks
      'createdAt': now, // Sets an anchor point for sorting
      'timestamp': now,
    });
  }

  // --- READ ---
  // Opens a live, continuous real-time stream pipe to listen for changes
  Stream<QuerySnapshot> getTasksStream(String userId, bool showCompletedOnly) {
    return _tasksCollection
        .where(
          'userId',
          isEqualTo: userId,
        ) // Security check: Must match active user
        .where(
          'isCompleted',
          isEqualTo: showCompletedOnly,
        ) // UI Filter toggle state
        .orderBy(
          'createdAt',
          descending: true,
        ) // Places newest documents at the top
        .snapshots(); // Keeps the pipe open for live server push updates
  }

  //*            --- UPDATE---
  // Modifies a single field inside an existing document using its unique ID
  Future<void> toggleTaskStatus(String docId, bool currentStatus) async {
    await _tasksCollection.doc(docId).update({
      'isCompleted': !currentStatus, // Inverts the true/false checkbox state
    });
  }

  // Updates the task's title, body, and timestamp in Firestore
  Future<void> updateTask(String docId, String title, String body) async {
    await _tasksCollection.doc(docId).update({
      'title': title,
      'body': body,
      'timestamp': Timestamp.now(),
    });
  }

  //* --- DELETE ---
  // Completely erases the target document file from the server disk storage
  Future<void> deleteTask(String docId) async {
    await _tasksCollection.doc(docId).delete();
  }

  // Delete All Completed Tasks fro userId
  Future<void> clearCompletedTasks(String userId) async {
    final snap = await _tasksCollection
        .where('userId', isEqualTo: userId)
        .where('isCompleted', isEqualTo: true)
        .get();
    final batch = _db.batch();
    for (final doc in snap.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  /// Stream all tasks (no filter).
  Stream<QuerySnapshot> getAllTasksStream(String userId) {
    return _tasksCollection
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  /// Stream tasks created on a specific calendar day.
  Stream<QuerySnapshot> getTasksByDateStream(
    String userId,
    DateTime date, {
    bool? isCompletedFilter, // null = all, true = completed, false = pending
  }) {
    final start = DateTime(date.year, date.month, date.day, 0, 0, 0);
    final end = DateTime(date.year, date.month, date.day, 23, 59, 59);
    var query = _tasksCollection
        .where('userId', isEqualTo: userId)
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(end));
    if (isCompletedFilter != null) {
      query = query.where('isCompleted', isEqualTo: isCompletedFilter);
    }
    return query.orderBy('createdAt', descending: true).snapshots();
  }

  // ######################## PROFILE PHOTO ###############
  //* Creates a user collection folder
  final CollectionReference _userCollection = FirebaseFirestore.instance
      .collection('users');
  // Saving Data: Updates or creates a user profile document with the image string
  Future<void> saveUserProfilePicture(String userId, String base64Image) async {
    await _userCollection.doc(userId).set(
      {'profilePicData': base64Image, 'updatedAt': Timestamp.now()},
      SetOptions(merge: true),
    ); //Merge ensures we don't accidentally wipe out other existing fields
  }

  // READING DATA: Streams the user record in real-time
  Stream<DocumentSnapshot> getUserProfilStream(String userId) {
    return _userCollection.doc(userId).snapshots();
  }

  // =========================================================================
  // SCENARIO 1: FIXED-SCHEDULE DAILY CHECK
  // =========================================================================
  Future<void> runDailyScheduleCheck(String userId, String deviceToken) async {
    final now = DateTime.now();
    // Only trigger this automated check if it's past 8:00 PM (20:00)
    if (now.hour >= 20) {
      final activeTasks = await _tasksCollection
          .where('userId', isEqualTo: userId)
          .where('isCompleted', isEqualTo: false)
          .get();
      if (activeTasks.docs.isNotEmpty) {
        await _sendPushNotification(
          deviceToken: deviceToken,
          title: "Daily Todo Checkpoint",
          body:
              "You still have ${activeTasks.docs.length} tasks pending on your list for tonight!",
        );
      }
    }
  }

  // =========================================================================
  // SCENARIO 2: YESTERDAY'S LEFTOVERS ONLY (STRICT 24-HOUR WINDOW)
  // =========================================================================
  Future<void> checkYesterdayLeftOvers(
    String userId,
    String deviceToken,
  ) async {
    final now = DateTime.now();
    // Calculate exactly midnight of yesterday to midnight of last night
    final yesterdayStart = DateTime(now.year, now.month, now.day - 1, 0, 0, 0);
    final yesterdayEnd = DateTime(now.year, now.month, now.day - 1, 23, 59, 59);
    final yesterdayTasks = await _tasksCollection
        .where('userId', isEqualTo: userId)
        .where('isCompleted', isEqualTo: false)
        .where(
          'createdAt',
          isGreaterThanOrEqualTo: Timestamp.fromDate(yesterdayStart),
        )
        .where(
          'createdAt',
          isLessThanOrEqualTo: Timestamp.fromDate(yesterdayEnd),
        )
        .get();
    if (yesterdayTasks.docs.isNotEmpty) {
      await _sendPushNotification(
        deviceToken: deviceToken,
        title: "Yesterday's Leftovers!",
        body:
            "You left ${yesterdayTasks.docs.length} tasks unfinished from yesterday. Tap to clear them!",
      );
    }
  }

  Future<void> evaluateCleanSlateStatus(
    String userId,
    String deviceToken,
  ) async {
    final remainingActiveTasks = await _tasksCollection
        .where('userId', isEqualTo: userId)
        .where('isCompleted', isEqualTo: false)
        .get();

    if (remainingActiveTasks.docs.isEmpty) {
      await _sendPushNotification(
        deviceToken: deviceToken,
        title: "Clean Slate!",
        body: "Awesome job! All daily tasks completed successfully. 🌟",
      );
    }
  }

  // =========================================================================
  // THE CORE ENGINE: SENDS THE DATA PAYLOAD TO THE FIREBASE SERVER
  // =========================================================================

  Future<void> _sendPushNotification({
    required String deviceToken,
    required String title,
    required String body,
  }) async {
    // 1. Define the scopes required to talk to Firebase Messaging
    final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];
    final String projectId = _env('PROJECT_ID', 'project_id');
    final String privateKeyId = _env('PRIVATE_KEY_ID', 'private_key_id');
    final String privateKey = _normalizePrivateKey(
      _env('PRIVATE_KEY', 'private_key'),
    );
    final String clientEmail = _env('CLIENT_EMAIL', 'client_email');
    final String clientId = _env('CLIENT_ID', 'client_id');

    final missingFields = <String>[
      if (projectId.isEmpty) 'PROJECT_ID',
      if (privateKeyId.isEmpty) 'PRIVATE_KEY_ID',
      if (privateKey.isEmpty) 'PRIVATE_KEY',
      if (clientEmail.isEmpty) 'CLIENT_EMAIL',
      if (clientId.isEmpty) 'CLIENT_ID',
    ];

    if (missingFields.isNotEmpty) {
      print(
        'FCM delivery skipped: missing dart defines: ${missingFields.join(', ')}',
      );
      return;
    }

    if (!privateKey.startsWith('-----BEGIN PRIVATE KEY-----') ||
        !privateKey.trimRight().endsWith('-----END PRIVATE KEY-----')) {
      print(
        'FCM delivery skipped: PRIVATE_KEY is not a valid PEM. '
        'Run with --dart-define-from-file=secrets.json or pass the full key with escaped newlines.',
      );
      return;
    }

    final serviceMap = {
      "type": "service_account",
      "project_id": projectId,
      "private_key_id": privateKeyId,
      "private_key": privateKey,
      "client_email": clientEmail,
      "client_id": clientId,
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url":
          "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url":
          "https://www.googleapis.com/robot/v1/metadata/x509/$clientEmail",
      "universe_domain": "googleapis.com",
    };
    try {
      // 2. Automatically exchange the JSON credentials for a short-lived Access Token
      final accountCredentials = auth.ServiceAccountCredentials.fromJson(
        serviceMap,
      );
      final authClient = await auth.clientViaServiceAccount(
        accountCredentials,
        scopes,
      );
      // 3. Modern HTTP v1 Endpoint URL
      final String url =
          'https://fcm.googleapis.com/v1/projects/$projectId/messages:send';

      // 4. Send the payload using the authClient (it attaches the Authorization token automatically!)
      final response = await authClient.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'message': {
            'token': deviceToken, // The target phone token address
            'notification': {'title': title, 'body': body},
          },
        }),
      );

      if (response.statusCode == 200) {
        print('HTTP v1 Push Notification Dispatched Successfully!');
      } else {
        print('FCM Server Rejected Payload: ${response.body}');
      }

      authClient.close(); // Clean up client memory resources
    } catch (e) {
      print('FCM delivery error: $e');
    }
  }

  String _normalizePrivateKey(String rawKey) {
    final decodedKey = rawKey.contains('%') ? Uri.decodeFull(rawKey) : rawKey;

    return decodedKey
        .trim()
        .replaceAll(r'\r\n', '\n')
        .replaceAll(r'\n', '\n')
        .replaceAll('\r\n', '\n');
  }

  String _env(String upperCaseName, String lowerCaseName) {
    const values = {
      'PROJECT_ID': String.fromEnvironment('PROJECT_ID'),
      'project_id': String.fromEnvironment('project_id'),
      'PRIVATE_KEY_ID': String.fromEnvironment('PRIVATE_KEY_ID'),
      'private_key_id': String.fromEnvironment('private_key_id'),
      'PRIVATE_KEY': String.fromEnvironment('PRIVATE_KEY'),
      'private_key': String.fromEnvironment('private_key'),
      'CLIENT_EMAIL': String.fromEnvironment('CLIENT_EMAIL'),
      'client_email': String.fromEnvironment('client_email'),
      'CLIENT_ID': String.fromEnvironment('CLIENT_ID'),
      'client_id': String.fromEnvironment('client_id'),
    };

    return values[upperCaseName]!.isNotEmpty
        ? values[upperCaseName]!
        : values[lowerCaseName]!;
  }
}
