import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tugas_besar_mobile2/models/task_model.dart';
import 'package:tugas_besar_mobile2/providers/task_provider.dart';
import 'package:tugas_besar_mobile2/screens/add_edit_task_screen.dart';
import 'package:tugas_besar_mobile2/screens/calender_screen.dart';
import 'package:tugas_besar_mobile2/screens/complete_tasks_screen.dart';
import 'package:tugas_besar_mobile2/screens/login_screen.dart';
import 'package:tugas_besar_mobile2/screens/scan_task_screen.dart';
import 'package:tugas_besar_mobile2/services/task_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedCourse = 'Semua';
  String selectedStatus = 'Belum selesai';
  bool sortAsc = true;
  int? userId;
  String? username;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user_data');

    if (userJson != null) {
      final userMap = jsonDecode(userJson);
      userId = userMap['id'];
      username = userMap['username'];

      // provider
      final taskProvider = Provider.of<TaskProvider>(context, listen: false);
      await taskProvider.loadTasksByUser(userId!);
    }
  }

  List<Task> getFilteredTasks(List<Task> tasks) {
    List<Task> filtered = tasks;

    if (selectedStatus == 'Belum selesai') {
      filtered = filtered.where((t) => !t.isDone).toList();
    } else if (selectedStatus == 'Selesai') {
      filtered = filtered.where((t) => t.isDone).toList();
    }

    if (selectedCourse != 'Semua') {
      filtered = filtered.where((t) => t.matakuliah == selectedCourse).toList();
    }

    filtered.sort((a, b) => sortAsc
        ? a.deadline.compareTo(b.deadline)
        : b.deadline.compareTo(a.deadline));

    return filtered;
  }

  List<String> getCourses(List<Task> tasks) {
    final courses = tasks.map((t) => t.matakuliah).toSet().toList();
    courses.sort();
    return ['Semua', ...courses];
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final filteredTasks = getFilteredTasks(taskProvider.tasks);

    return Scaffold(
      appBar: AppBar(
  leading: const SizedBox.shrink(), // tidak pakai ikon di kiri
  title: const Text(
    'Student Task Manager',
    style: TextStyle(color: Colors.white),
  ),
  backgroundColor: Colors.indigo,
  centerTitle: true,
  actions: [
    PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, color: Colors.white), // ikon menu
      onSelected: (value) async {
        switch (value) {
          case 'completed':
            Navigator.push(context, MaterialPageRoute(builder: (_) => const CompletedTasksScreen()));
            break;
          case 'logout':
            final prefs = await SharedPreferences.getInstance();
            await prefs.remove('user_data');
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
              (_) => false,
            );
            break;
          case 'calendar':
            Navigator.push(context, MaterialPageRoute(builder: (_) => const CalendarScreen()));
            break;
          case 'scan':
            final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => const ScanTaskScreen()));
            if (result == true && userId != null) {
              await taskProvider.loadTasksByUser(userId!);
            }
            break;
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'completed',
          child: ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Completed Tasks'),
          ),
        ),
        PopupMenuItem(
          value: 'logout',
          child: ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
          ),
        ),
        PopupMenuItem(
          value: 'calendar',
          child: ListTile(
            leading: const Icon(Icons.calendar_month),
            title: const Text('Calendar'),
          ),
        ),
        PopupMenuItem(
          value: 'scan',
          child: ListTile(
            leading: const Icon(Icons.document_scanner),
            title: const Text('Scan Task'),
          ),
        ),
      ],
    )
  ],
),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Halo, ${username ?? 'Mahasiswa'} 👋',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.indigo[800]),
            ),
            const SizedBox(height: 4),
            const Text('Filter & urutkan tugas kamu di bawah ini:', style: TextStyle(fontSize: 16, color: Colors.black54)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: selectedCourse,
                    items: getCourses(taskProvider.tasks)
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (val) => setState(() => selectedCourse = val!),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: selectedStatus,
                    items: const [
                      DropdownMenuItem(value: 'Belum selesai', child: Text('Belum selesai')),
                      DropdownMenuItem(value: 'Selesai', child: Text('Selesai')),
                      DropdownMenuItem(value: 'Semua', child: Text('Semua')),
                    ],
                    onChanged: (val) => setState(() => selectedStatus = val!),
                  ),
                ),
                IconButton(
                  icon: Icon(sortAsc ? Icons.arrow_upward : Icons.arrow_downward),
                  onPressed: () => setState(() => sortAsc = !sortAsc),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => taskProvider.loadTasksByUser(userId!),
                child: filteredTasks.isEmpty
                    ? Center(child: Text('Tidak ada tugas ditemukan 🎉', style: TextStyle(fontSize: 18, color: Colors.grey[600])))
                    : ListView.builder(
                        itemCount: filteredTasks.length,
                        itemBuilder: (context, index) {
                          final task = filteredTasks[index];
                          return Card(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            elevation: 5,
                            child: ListTile(
                              title: Text('Tugas: ${task.tugas}'),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Mata Kuliah: ${task.matakuliah}'),
                                  Text('Notes: ${task.notes}'),
                                  Text('Deadline: ${DateFormat('dd MMM yyyy – HH:mm').format(task.deadline)}'),
                                ],
                              ),
                              trailing: IconButton(
                                icon: Icon(
                                  task.isDone ? Icons.check_circle : Icons.radio_button_unchecked,
                                  color: Colors.indigo,
                                ),
                                onPressed: () async {
                                  taskProvider.toggleStatus(task);
                                },
                              ),
                              onTap: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => AddEditTaskScreen(task: task)),
                                );
                                if (result == true) await taskProvider.loadTasksByUser(userId!);
                              },
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        // asyncronus async await
        onPressed: () async {
          final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddEditTaskScreen()));
          if (result == true && userId != null) await taskProvider.loadTasksByUser(userId!);
        },
        backgroundColor: Colors.indigo,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Tambah Tugas', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
