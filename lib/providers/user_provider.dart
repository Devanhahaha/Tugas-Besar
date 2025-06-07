import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProvider with ChangeNotifier {
  int? _userId;
  String? _username;

  int? get userId => _userId;
  String? get username => _username;

  void setUsername(String name) {
    _username = name;
    notifyListeners();
  }

  Future<void> loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user_data');

    if (userJson != null) {
      final userMap = jsonDecode(userJson);
      _userId = userMap['id'];
      _username = userMap['username'];
      notifyListeners();
    }
  }

  Future<void> updateUsername(String newUsername) async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user_data');

    if (userJson != null) {
      final userMap = jsonDecode(userJson);
      userMap['username'] = newUsername;
      await prefs.setString('user_data', jsonEncode(userMap));

      _username = newUsername;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_data');
    _userId = null;
    _username = null;
    notifyListeners();
  }
}
