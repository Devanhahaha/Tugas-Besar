class Task {
  final int? id;
  final String tugas;
  final String matakuliah;
  final DateTime deadline;
  final String notes;
  final bool isDone;

  Task({
    this.id,
    required this.tugas,
    required this.matakuliah,
    required this.deadline,
    required this.notes,
    this.isDone = false,
  });

  // Untuk simpan ke SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tugas': tugas,
      'matakuliah': matakuliah,
      'deadline': deadline.toIso8601String(),
      'notes': notes,
      'isDone': isDone ? 1 : 0,
    };
  }

  // Untuk ambil dari SQLite
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      tugas: map['tugas'],
      matakuliah: map['matakuliah'],
      deadline: DateTime.parse(map['deadline']),
      notes: map['notes'],
      isDone: map['isDone'] == 1,
    );
  }
}
