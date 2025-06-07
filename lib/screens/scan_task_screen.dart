import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:tugas_besar_mobile2/screens/ocr_preview_screen.dart';
import 'package:tugas_besar_mobile2/utils/ocr_services.dart';
import 'package:tugas_besar_mobile2/providers/ocr_provider.dart';

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

  Map<String, dynamic> parseScannedText(String text) {
    final lines = text.split('\n');
    final result = <String, String>{};
    final garbage = <String>[];

    final garbageKeywords = [
      'jangan telat',
      'kena denda',
      'terlambat',
      'dihukum',
      'hukumannya',
      'kalau telat',
      'telat kena',
    ];

    for (var line in lines) {
      final lower = line.toLowerCase();

      if (garbageKeywords.any((word) => lower.contains(word))) {
        garbage.add(line);
        continue;
      }

      if (lower.contains('nama')) {
        result['namaTugas'] = line.split(':').last.trim();
      } else if (lower.contains('kuliah')) {
        result['mataKuliah'] = line.split(':').last.trim();
      } else if (lower.contains('deadline')) {
        result['deadline'] = line.split(':').last.trim();
      } else if (lower.contains('catatan')) {
        result['catatan'] = line.split(':').last.trim();
      }
    }

    return {
      'data': result,
      'garbage': garbage,
    };
  }

  void _useScannedText() {
    final parsed = parseScannedText(_scannedText);

    final ocrProvider = context.read<OCRProvider>();
    ocrProvider.setExtractedData(parsed['data']);
    ocrProvider.setGarbageText(parsed['garbage']);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const OCRPreviewScreen(extractedData: {},),
      ),
    ).then((result) {
      if (result == true) {
        Navigator.pop(context, true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Tugas dari Kamera/Gambar',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.lightBlue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
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
