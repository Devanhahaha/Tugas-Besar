import 'package:flutter/material.dart';
import 'package:tugas_besar_mobile2/models/task_model.dart';
import 'package:tugas_besar_mobile2/screens/add_edit_task_screen.dart';
import 'package:tugas_besar_mobile2/screens/calender_screen.dart';
import 'package:tugas_besar_mobile2/screens/complete_tasks_screen.dart';
import 'package:intl/intl.dart';
import 'package:tugas_besar_mobile2/services/local_db.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Task> tasks = [];
  String selectedCourse = 'Semua';
  String selectedStatus = 'Belum selesai';
  bool sortAsc = true;

  Future<void> _loadTasks() async {
    final data = await LocalDB.instance.getAllTasks();
    setState(() {
      tasks = data;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  List<String> getCourses() {
    final allCourses = tasks.map((t) => t.matakuliah).toSet().toList();
    allCourses.sort();
    return ['Semua', ...allCourses];
  }

  List<Task> getFilteredTasks() {
    List<Task> filtered = tasks;

    // Filter status
    if (selectedStatus == 'Belum selesai') {
      filtered = filtered.where((t) => !t.isDone).toList();
    } else if (selectedStatus == 'Selesai') {
      filtered = filtered.where((t) => t.isDone).toList();
    }

    // Filter mata kuliah
    if (selectedCourse != 'Semua') {
      filtered = filtered.where((t) => t.matakuliah == selectedCourse).toList();
    }

    // Sort deadline
    filtered.sort((a, b) => sortAsc
        ? a.deadline.compareTo(b.deadline)
        : b.deadline.compareTo(a.deadline));

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final filteredTasks = getFilteredTasks();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Student Task Manager'),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CompletedTasksScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CalendarScreen()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Halo, Mahasiswa! 👋',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.indigo[800],
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Filter & urutkan tugas kamu di bawah ini:',
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: selectedCourse,
                    items: getCourses()
                        .map((c) => DropdownMenuItem(
                              value: c,
                              child: Text(c),
                            ))
                        .toList(),
                    onChanged: (val) {
                      setState(() => selectedCourse = val!);
                    },
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
                    onChanged: (val) {
                      setState(() => selectedStatus = val!);
                    },
                  ),
                ),
                IconButton(
                  icon: Icon(sortAsc ? Icons.arrow_upward : Icons.arrow_downward),
                  tooltip: 'Urutkan deadline',
                  onPressed: () => setState(() => sortAsc = !sortAsc),
                )
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: filteredTasks.isEmpty
                  ? Center(
                      child: Text(
                        'Tidak ada tugas ditemukan 🎉',
                        style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                      ),
                    )
                  : ListView.builder(
                      itemCount: filteredTasks.length,
                      itemBuilder: (context, index) {
                        final task = filteredTasks[index];
                        return Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          color: Colors.white,
                          shadowColor: Colors.indigo.withOpacity(0.2),
                          elevation: 5,
                          margin: const EdgeInsets.only(bottom: 16),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => AddEditTaskScreen(task: task),
                                  ),
                                );
                                _loadTasks();
                              },
                              title: Text(
                                task.tugas,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(
                                    task.matakuliah,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.calendar_today,
                                          size: 14, color: Colors.indigo),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Deadline: ${DateFormat('dd MMM yyyy – HH:mm').format(task.deadline)}',
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              trailing: IconButton(
                                icon: Icon(
                                  task.isDone
                                      ? Icons.check_circle
                                      : Icons.radio_button_unchecked,
                                  color: Colors.indigo,
                                ),
                                onPressed: () async {
                                  final updatedTask = Task(
                                    id: task.id,
                                    tugas: task.tugas,
                                    matakuliah: task.matakuliah,
                                    deadline: task.deadline,
                                    notes: task.notes,
                                    isDone: !task.isDone,
                                  );
                                  await LocalDB.instance.updateTask(updatedTask);
                                  _loadTasks();
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddEditTaskScreen()),
          );
          _loadTasks();
        },
        backgroundColor: Colors.indigo,
        icon: const Icon(Icons.add),
        label: const Text('Tambah Tugas'),
      ),
    );
  }
}
