// Trajuan Smith
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task_model.dart';

// Handles all Firestore operations related to tasks
class TaskService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Add Task
  Future<void> addTask(Task task) async {
    await _db.collection('tasks').add(task.toMap());
  }

  // Get all tasks for a user
  Future<List<Task>> getUserTasks(String userId) async {
    final snapshot = await _db
        .collection('tasks')
        .where('userId', isEqualTo: userId)
        .get();

    return snapshot.docs
        .map((doc) => Task.fromMap(doc.data(), doc.id))
        .toList();
  }

  // Update Task
  Future<void> updateTask(Task task) async {
    await _db.collection('tasks').doc(task.id).update(task.toMap());
  }

  // Delete Task
  Future<void> deleteTask(String taskId) async {
    await _db.collection('tasks').doc(taskId).delete();
  }
}