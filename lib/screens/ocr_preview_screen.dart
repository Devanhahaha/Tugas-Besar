import 'package:flutter/material.dart';
import 'package:tugas_besar_mobile2/screens/add_edit_task_screen.dart';

class OCRPreviewScreen extends StatelessWidget {
  final Map<String, String> extractedData;

  const OCRPreviewScreen({super.key, required this.extractedData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Validasi Hasil OCR'),
        backgroundColor: Colors.indigo,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nama Tugas: ${extractedData['namaTugas'] ?? '-'}'),
            const SizedBox(height: 8),
            Text('Mata Kuliah: ${extractedData['mataKuliah'] ?? '-'}'),
            const SizedBox(height: 8),
            Text('Deadline: ${extractedData['deadline'] ?? '-'}'),
            const SizedBox(height: 8),
            Text('Catatan: ${extractedData['catatan'] ?? '-'}'),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        AddEditTaskScreen(scannedText: extractedData),
                  ),
                ).then((result) {
                  if (result == true) {
                    Navigator.pop(context,
                        true); // balik ke ScanTaskScreen, lalu ke HomeScreen
                  }
                });
              },
              child: const Text('Gunakan Data Ini'),
            )
          ],
        ),
      ),
    );
  }
}
