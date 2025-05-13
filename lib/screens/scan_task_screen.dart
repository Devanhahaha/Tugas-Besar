import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tugas_besar_mobile2/screens/add_edit_task_screen.dart';
import 'package:tugas_besar_mobile2/screens/ocr_preview_screen.dart';
import 'package:tugas_besar_mobile2/utils/ocr_services.dart';

class ScanTaskScreen extends StatefulWidget {
  const ScanTaskScreen({super.key});

  @override
  State<ScanTaskScreen> createState() => _ScanTaskScreenState();
}

class _ScanTaskScreenState extends State<ScanTaskScreen> {
  File? _image;
  String _scannedText = '';
  bool _loading = false;

  Future<void> _pickImage(ImageSource source) async {
    final picked = await ImagePicker().pickImage(source: source);
    if (picked != null) {
      setState(() {
        _image = File(picked.path);
        _scannedText = '';
        _loading = true;
      });
      final text = await OCRService.scanTextFromImage(_image!);
      setState(() {
        _scannedText = text;
        _loading = false;
      });
    }
  }

  Map<String, String> parseScannedText(String text) {
    final lines = text.split('\n');
    final result = <String, String>{};

    for (var line in lines) {
      if (line.toLowerCase().contains('nama')) {
        result['namaTugas'] = line.split(':').last.trim();
      } else if (line.toLowerCase().contains('kuliah')) {
        result['mataKuliah'] = line.split(':').last.trim();
      } else if (line.toLowerCase().contains('deadline')) {
        result['deadline'] = line.split(':').last.trim();
      } else if (line.toLowerCase().contains('catatan')) {
        result['catatan'] = line.split(':').last.trim();
      }
    }

    return result;
  }

  void _useScannedText() {
    final parsed = parseScannedText(_scannedText);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OCRPreviewScreen(extractedData: parsed),
      ),
    ).then((result) {
      if (result == true)
        Navigator.pop(context, true); // ini akan trigger _loadTasks() di Home
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Tugas dari Kamera/Gambar', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.indigo,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          // Tambahkan ini
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Kamera'),
                    onPressed: () => _pickImage(ImageSource.camera),
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Galeri'),
                    onPressed: () => _pickImage(ImageSource.gallery),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (_loading) const CircularProgressIndicator(),
              if (_image != null && !_loading) ...[
                Image.file(_image!, height: 200),
                const SizedBox(height: 12),
                const Text('Hasil OCR:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(_scannedText),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _scannedText.isEmpty ? null : _useScannedText,
                  child: const Text('Gunakan untuk Isi Form'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
