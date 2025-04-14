import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tugas_besar_mobile2/models/task_model.dart';
import 'package:tugas_besar_mobile2/services/local_db.dart';
import 'package:tugas_besar_mobile2/utils/notification_services.dart';

class AddEditTaskScreen extends StatefulWidget {
  final Task? task; // jika null maka mode tambah, jika ada maka edit
  const AddEditTaskScreen({super.key, this.task});

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
    if (isEdit) {
      final task = widget.task!;
      _titleController.text = task.tugas;
      _courseController.text = task.matakuliah;
      _notesController.text = task.notes;
      _selectedDateTime = task.deadline;
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
      final task = Task(
        id: widget.task?.id,
        tugas: _titleController.text,
        matakuliah: _courseController.text,
        deadline: _selectedDateTime!,
        notes: _notesController.text,
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
      } else {
        final newId = await LocalDB.instance.insertTask(task);
        await NotificationService.scheduleTaskReminder(
          id: newId,
          tugas: task.tugas,
          deadline: task.deadline,
        );
      }

      if (context.mounted) Navigator.pop(context);
    }
  }

  Future<void> _deleteTask() async {
    if (isEdit && widget.task?.id != null) {
      await NotificationService.cancelTaskNotifications(widget.task!.id!);
      await LocalDB.instance.deleteTask(widget.task!.id!);
      if (context.mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Tugas' : 'Tambah Tugas'),
        backgroundColor: Colors.indigo,
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
                  backgroundColor: Colors.indigo,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(isEdit ? 'Perbarui Tugas' : 'Simpan Tugas'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
