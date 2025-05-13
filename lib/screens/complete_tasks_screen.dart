import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tugas_besar_mobile2/models/task_model.dart';
import 'package:tugas_besar_mobile2/services/local_db.dart';

class CompletedTasksScreen extends StatefulWidget {
  const CompletedTasksScreen({super.key});

  @override
  State<CompletedTasksScreen> createState() => _CompletedTasksScreenState();
}

class _CompletedTasksScreenState extends State<CompletedTasksScreen> {
  List<Task> completedTasks = [];

  Future<void> _loadCompletedTasks() async {
    final allTasks = await LocalDB.instance.getAllTasks();
    setState(() {
      completedTasks = allTasks.where((task) => task.isDone).toList();
    });
  }

  @override
  void initState() {
    super.initState();
    _loadCompletedTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Riwayat Tugas', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.indigo,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: completedTasks.isEmpty
            ? const Center(child: Text('Belum ada tugas yang selesai'))
            : ListView.builder(
                itemCount: completedTasks.length,
                itemBuilder: (context, index) {
                  final task = completedTasks[index];
                  return Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 3,
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      title: Text(task.tugas),
                      subtitle: Text(
                          'Deadline: ${DateFormat('dd MMM yyyy').format(task.deadline)}'),
                      trailing:
                          const Icon(Icons.check_circle, color: Colors.green),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
