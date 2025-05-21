import 'package:flutter/material.dart';
import 'package:tugas_besar_mobile2/models/task_model.dart';
import 'package:tugas_besar_mobile2/services/local_db.dart';

// provider
class TaskProvider with ChangeNotifier {
  List<Task> _tasks = [];

  List<Task> get tasks => _tasks;

  Future<void> loadTasks() async {
    _tasks = await LocalDB.instance.getAllTasks();
    notifyListeners();
  }

  void addTask(Task task) async {
    await LocalDB.instance.insertTask(task);
    await loadTasks();
  }

  void updateTask(Task task) async {
    await LocalDB.instance.updateTask(task);
    await loadTasks();
  }

  void deleteTask(int id) async {
    await LocalDB.instance.deleteTask(id);
    await loadTasks();
  }

  Future<void> loadTasksByUser(int userId) async {
  _tasks = await LocalDB.instance.getTasksByUser(userId);
  notifyListeners();
}


  void toggleStatus(Task task) async {
    task = Task(
      id: task.id,
      tugas: task.tugas,
      matakuliah: task.matakuliah,
      deadline: task.deadline,
      notes: task.notes,
      isDone: !task.isDone, user_id: task.user_id ?? 0,
    );
    updateTask(task);
  }
}
