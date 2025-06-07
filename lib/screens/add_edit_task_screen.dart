import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tugas_besar_mobile2/models/task_model.dart';
import 'package:tugas_besar_mobile2/models/user_model.dart';
import 'package:tugas_besar_mobile2/screens/home_screen.dart';
import 'package:tugas_besar_mobile2/screens/live_scan_task_screen.dart';
import 'package:tugas_besar_mobile2/services/local_db.dart';
import 'package:tugas_besar_mobile2/utils/notification_services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

DateTime? parseDeadline(String deadlineText) {
  final formats = [
    // DateFormat("dd MMM yyyy - HH:mm", 'id'),
    // DateFormat("dd MMM yyyy H:mm", 'id'),
    // DateFormat("dd-MM-yyyy HH:mm"),
    // DateFormat("dd/MM/yyyy HH:mm"),
    DateFormat("dd MMM yyyy – HH:mm"),
  ];

  for (var format in formats) {
    try {
      return format.parse(deadlineText);
    } catch (_) {}
  }

  return null; // jika gagal semua
}

class AddEditTaskScreen extends StatefulWidget {
  final Task? task;
  final Map<String, String>? scannedText; // Ubah ke Map

  const AddEditTaskScreen({super.key, this.task, this.scannedText});

  @override
  State<AddEditTaskScreen> createState() => _AddEditTaskScreenState();
}

class _AddEditTaskScreenState extends State<AddEditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _courseController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  DateTime? _selectedDateTime;

  bool get isEdit => widget.task != null;

  @override
  void initState() {
    super.initState();
    _loadUser();
    initializeDateFormatting('id', null); // Tambahkan ini

    if (widget.task != null) {
      // Edit task
      _titleController.text = widget.task!.tugas;
      _courseController.text = widget.task!.matakuliah;
      _notesController.text = widget.task!.notes ?? '';
      _selectedDateTime = widget.task!.deadline;
    } else if (widget.scannedText != null) {
      // Isi otomatis dari hasil OCR
      final data = widget.scannedText!;
      _titleController.text = data['namaTugas'] ?? '';
      _courseController.text = data['mataKuliah'] ?? '';
      _notesController.text = data['catatan'] ?? '';

      if (data['deadline'] != null) {
        _selectedDateTime = parseDeadline(data['deadline']!);
      }
    }
  }

  Users? loggedInUser;

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    String? userJson = prefs.getString('user_data');

    if (userJson != null) {
      setState(() {
        loggedInUser = Users.fromJson(userJson);
      });
    }
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime ?? DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );

    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime:
            TimeOfDay.fromDateTime(_selectedDateTime ?? DateTime.now()),
      );

      if (time != null) {
        setState(() {
          _selectedDateTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _saveTask() async {
    if (_formKey.currentState!.validate() && _selectedDateTime != null) {
      final userId = widget.task?.user_id ?? loggedInUser?.id ?? 0;
      print('user : ${userId}');
      final task = Task(
        id: widget.task?.id,
        tugas: _titleController.text,
        matakuliah: _courseController.text,
        deadline: _selectedDateTime!,
        notes: _notesController.text,
        user_id: userId,
        isDone: widget.task?.isDone ?? false,
      );

      if (isEdit) {
        await LocalDB.instance.updateTask(task);
        await NotificationService.cancelTaskNotifications(task.id!);
        await NotificationService.scheduleTaskReminder(
          id: task.id!,
          tugas: task.tugas,
          deadline: task.deadline,
        );
        await NotificationService.scheduleTaskReminderr(
          id: task.id!,
          tugas: task.tugas,
          deadline: task.deadline,
        );
      } else {
        final newId = await LocalDB.instance.insertTask(task);
        await NotificationService.scheduleTaskReminder(
          id: newId,
          tugas: task.tugas,
          deadline: task.deadline,
        );
        await NotificationService.scheduleTaskReminderr(
          id: newId,
          tugas: task.tugas,
          deadline: task.deadline,
        );
      }

      // Balik langsung ke halaman Home
      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (route) => false,
        );
      }
    }
  }

  Future<void> _deleteTask() async {
    if (isEdit && widget.task?.id != null) {
      // await NotificationService.cancelTaskNotifications(widget.task!.id!);
      await NotificationService.showInstantNotification(
          title: 'Dibatalkan', body: 'Silahkan Input Tugas Baru');
      await LocalDB.instance.deleteTask(widget.task!.id!);
      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Tugas' : 'Tambah Tugas',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.lightBlue,
        actions: isEdit
            ? [
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: _deleteTask,
                ),
              ]
            : null,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Nama Tugas',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _courseController,
                decoration: const InputDecoration(
                  labelText: 'Mata Kuliah',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Deadline'),
                subtitle: Text(
                  _selectedDateTime == null
                      ? 'Pilih tanggal dan waktu'
                      : DateFormat('dd MMM yyyy – HH:mm')
                          .format(_selectedDateTime!),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: _pickDateTime,
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Catatan Tambahan',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveTask,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlue,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(isEdit ? 'Perbarui Tugas' : 'Simpan Tugas',
                    style: TextStyle(color: Colors.white)),
              )
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const LiveScanTaskScreen()),
          );
        },
        label: const Text('Scan Tugas',
            style: TextStyle(fontSize: 16, color: Colors.white)),
        icon: const Icon(Icons.document_scanner, color: Colors.white),
        backgroundColor: Colors.lightBlue,
      ),
    );
  }
}
