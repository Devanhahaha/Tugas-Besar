import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:tugas_besar_mobile2/screens/home_screen.dart';
import 'package:tugas_besar_mobile2/screens/login_screen.dart';
import 'package:tugas_besar_mobile2/utils/notification_services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await NotificationService.initialize();
    await initializeDateFormatting('id', null);
  } catch (e, stack) {
    print("ERROR saat inisialisasi: $e");
    print(stack);
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student Task Manager',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}
