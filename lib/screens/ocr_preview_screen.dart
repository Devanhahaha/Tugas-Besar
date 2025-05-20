import 'package:flutter/material.dart';
import 'package:tugas_besar_mobile2/screens/add_edit_task_screen.dart';

class OCRPreviewScreen extends StatelessWidget {
  final Map<String, String> extractedData;
  final List<String>? garbageText;

  const OCRPreviewScreen({
    super.key,
    required this.extractedData,
    this.garbageText,
  });

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
            const SizedBox(height: 16),
            if (garbageText != null && garbageText!.isNotEmpty) ...[
              const Divider(),
              const Text('Teks Tidak Digunakan:',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.red)),
              const SizedBox(height: 4),
              ...garbageText!.map((line) => Text(
                    '- $line',
                    style: const TextStyle(color: Colors.red),
                  )),
            ],
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
                  if (result == true) Navigator.pop(context, true);
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
