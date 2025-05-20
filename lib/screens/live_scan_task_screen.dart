import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tugas_besar_mobile2/screens/ocr_preview_screen.dart';

class LiveScanTaskScreen extends StatefulWidget {
  const LiveScanTaskScreen({super.key});

  @override
  State<LiveScanTaskScreen> createState() => _LiveScanTaskScreenState();
}

class _LiveScanTaskScreenState extends State<LiveScanTaskScreen> {
  CameraController? _cameraController;
  bool _isProcessing = false;
  String _recognizedText = '';

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final backCamera = cameras
        .firstWhere((cam) => cam.lensDirection == CameraLensDirection.back);

    _cameraController = CameraController(backCamera, ResolutionPreset.medium);
    await _cameraController!.initialize();
    if (mounted) setState(() {});
  }

  Future<void> _captureAndScan() async {
    if (_cameraController == null ||
        !_cameraController!.value.isInitialized ||
        _isProcessing) return;

    setState(() => _isProcessing = true);

    final file = await _cameraController!.takePicture();
    final inputImage = InputImage.fromFilePath(file.path);

    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    final recognizedText = await textRecognizer.processImage(inputImage);

    setState(() {
      _recognizedText = recognizedText.text;
      _isProcessing = false;
    });

    // Setelah selesai, parsing & arahkan ke OCR preview
    final parsed = _parseScannedText(_recognizedText);

    Navigator.pushReplacement(
      this.context,
      MaterialPageRoute(
        builder: (BuildContext context) => OCRPreviewScreen(
          extractedData: parsed['data'],
          garbageText: parsed['garbage'],
        ),
      ),
    );
  }

  Map<String, dynamic> _parseScannedText(String text) {
    final lines = text.split('\n');
    final result = <String, String>{};
    final garbageList = <String>[];

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
      final lineLower = line.toLowerCase();

      if (garbageKeywords.any((word) => lineLower.contains(word))) {
        garbageList.add(line);
        continue;
      }

      if (lineLower.contains('nama')) {
        result['namaTugas'] = line.split(':').last.trim();
      } else if (lineLower.contains('kuliah')) {
        result['mataKuliah'] = line.split(':').last.trim();
      } else if (lineLower.contains('deadline')) {
        result['deadline'] = line.split(':').last.trim();
      } else if (lineLower.contains('catatan')) {
        result['catatan'] = line.split(':').last.trim();
      }
    }

    return {
      'data': result,
      'garbage': garbageList,
    };
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Scan Langsung"),
        backgroundColor: Colors.indigo,
      ),
      body: Stack(
        children: [
          CameraPreview(_cameraController!),
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
          if (_isProcessing)
            const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _captureAndScan,
        icon: const Icon(Icons.camera),
        label: const Text("Scan Sekarang"),
        backgroundColor: Colors.indigo,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
