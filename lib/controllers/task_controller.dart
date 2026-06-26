import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase/models/todo_task.dart';
import 'package:flutter_firebase/providers/task_filter_provider.dart';
import 'package:flutter_firebase/services/firestore_service.dart';

class TaskController {
  final FirestoreService _firestoreService;

  TaskController({FirestoreService? firestoreService})
    : _firestoreService = firestoreService ?? FirestoreService();

  Stream<QuerySnapshot> watchTasks({
    required String userId,
    required DateTime date,
    required TaskFilter filter,
  }) {
    return _firestoreService.getTasksByDateStream(
      userId,
      date,
      isCompletedFilter: _completedFilterFor(filter),
    );
  }

  Stream<QuerySnapshot> watchTaskCounts({
    required String userId,
    required DateTime date,
  }) {
    return _firestoreService.getTasksByDateStream(userId, date);
  }

  Future<void> addTask({
    required String title,
    required String body,
    required String userId,
  }) async {
    final cleanTitle = title.trim();
    if (cleanTitle.isEmpty) return;

    await _firestoreService.addTask(cleanTitle, body.trim(), userId);
  }

  Future<void> updateTask({
    required String taskId,
    required String title,
    required String body,
  }) async {
    final cleanTitle = title.trim();
    if (cleanTitle.isEmpty) return;

    await _firestoreService.updateTask(taskId, cleanTitle, body.trim());
  }

  Future<void> deleteTask(String taskId) {
    return _firestoreService.deleteTask(taskId);
  }

  Future<void> toggleTaskStatus({
    required String userId,
    required TodoTask task,
  }) async {
    await _firestoreService.toggleTaskStatus(task.id, task.isCompleted);

    if (task.isCompleted) return;

    final token = await _getDeviceTokenSafely();
    if (token != null) {
      await _firestoreService.evaluateCleanSlateStatus(userId, token);
    }
  }

  Future<void> runStartupNotificationChecks(String userId) async {
    final deviceToken = await _getDeviceTokenSafely();
    if (deviceToken == null) return;

    try {
      await _firestoreService.checkYesterdayLeftOvers(userId, deviceToken);
      await _firestoreService.runDailyScheduleCheck(userId, deviceToken);
    } catch (e) {
      debugPrint('Startup notification checks deferred: $e');
    }
  }

  List<TodoTask> mapAndSortTasks(QuerySnapshot snapshot) {
    final tasks = snapshot.docs.map(TodoTask.fromDocument).toList();
    tasks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return tasks;
  }

  bool? _completedFilterFor(TaskFilter filter) {
    if (filter == TaskFilter.completed) return true;
    if (filter == TaskFilter.pending) return false;
    return null;
  }

  Future<String?> _getDeviceTokenSafely() async {
    try {
      return await FirebaseMessaging.instance.getToken();
    } on FirebaseException catch (e) {
      debugPrint('FCM token unavailable (${e.code}): ${e.message}');
      return null;
    } catch (e) {
      debugPrint('FCM token unavailable: $e');
      return null;
    }
  }
}
