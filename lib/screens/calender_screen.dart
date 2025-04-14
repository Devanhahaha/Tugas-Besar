import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:tugas_besar_mobile2/models/task_model.dart';
import 'package:tugas_besar_mobile2/services/local_db.dart';
import 'package:intl/intl.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  List<Task> tasks = [];
  String selectedCourse = 'Semua';

  final Map<int, List<String>> jadwalKuliahPerHari = {
    DateTime.monday: [
      '08:20 - 10:00 Sistem Terdistribusi',
      '10:00 - 13:30 Visi Komputer',
      '13:30 - 16:00 Manajemen Proyek Perangkat Lunak',
    ],
    DateTime.tuesday: [
      '07:30 - 10:00 Komputasi Awan',
      '14:20 - 16:00 Kecerdasan Buatan',
    ],
    DateTime.wednesday: [
      '07:30 - 09:10 Sistem Terdistribusi',
      '10:00 - 11:40 Pemrograman Mobile 2',
      '12:40 - 15:10 Kecerdasan Buatan',
    ],
    DateTime.thursday: [
      '07:30 - 09:10 Manajemen Proyek Perangkat Lunak',
      '10:00 - 13:30 Grafika Komputer',
      '13:30 - 16:00 Sistem Terdistribusi',
    ],
    DateTime.friday: [
      '07:30 - 09:10 Visi Komputer',
      '09:10 - 11:40 Pemrograman Mobile 2',
    ],
  };

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

  List<dynamic> _getEventsForDay(DateTime day) {
    final tugas = tasks.where((t) => isSameDay(t.deadline, day)).toList();
    final kuliah = jadwalKuliahPerHari[day.weekday] ?? [];

    final filteredTugas = selectedCourse == 'Semua'
        ? tugas
        : tugas.where((t) => t.matakuliah == selectedCourse).toList();

    return [
      ...filteredTugas.map((t) => '📝 ${t.tugas} (Tugas)'),
      ...kuliah.map((k) => '📚 $k (Kuliah)'),
    ];
  }

  List<String> getCourses() {
    final allCourses = tasks.map((t) => t.matakuliah).toSet().toList();
    allCourses.sort();
    return ['Semua', ...allCourses];
  }

  void _showAllTasksForMatkul(String course) {
    final courseTasks = tasks.where((t) => t.matakuliah == course).toList();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Tugas untuk $course'),
        content: courseTasks.isEmpty
            ? const Text('Tidak ada tugas untuk mata kuliah ini.')
            : SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: courseTasks.length,
                  itemBuilder: (context, index) {
                    final t = courseTasks[index];
                    return ListTile(
                      leading: const Icon(Icons.assignment),
                      title: Text(t.tugas),
                      subtitle: Text(
                          DateFormat('dd MMM yyyy – HH:mm').format(t.deadline)),
                    );
                  },
                ),
              ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final events = _getEventsForDay(_selectedDay);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kalender Mingguan'),
        backgroundColor: Colors.indigo,
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2024, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            eventLoader: _getEventsForDay,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Text('Filter Mata Kuliah: '),
                const SizedBox(width: 12),
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
                if (selectedCourse != 'Semua')
                  IconButton(
                    icon: const Icon(Icons.list_alt_rounded),
                    tooltip: 'Lihat semua tugas',
                    onPressed: () => _showAllTasksForMatkul(selectedCourse),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: events.isEmpty
                ? const Center(
                    child: Text(
                      'Tidak ada jadwal atau tugas hari ini. 🎉',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      final event = events[index];
                      return ListTile(
                        leading: event.contains("Kuliah")
                            ? const Icon(Icons.school, color: Colors.blueAccent)
                            : const Icon(Icons.assignment,
                                color: Colors.indigo),
                        title: Text(event),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
