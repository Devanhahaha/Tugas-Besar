// lib/providers/ocr_provider.dart
import 'package:flutter/material.dart';

class OCRProvider with ChangeNotifier {
  Map<String, String> _extractedData = {};
  List<String> _garbageText = [];

  Map<String, String> get extractedData => _extractedData;
  List<String> get garbageText => _garbageText;

  void setExtractedData(Map<String, String> data) {
    _extractedData = data;
    notifyListeners();
  }

  void setGarbageText(List<String> garbage) {
    _garbageText = garbage;
    notifyListeners();
  }

  void clear() {
    _extractedData = {};
    _garbageText = [];
    notifyListeners();
  }
}
