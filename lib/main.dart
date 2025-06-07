import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:tugas_besar_mobile2/screens/home_screen.dart';
import 'package:tugas_besar_mobile2/screens/login_screen.dart';
import 'package:tugas_besar_mobile2/services/firebase_option.dart';
import 'package:tugas_besar_mobile2/services/task_provider.dart';
import 'package:tugas_besar_mobile2/utils/notification_services.dart';
import 'package:tugas_besar_mobile2/providers/ocr_provider.dart';
import 'package:tugas_besar_mobile2/providers/user_provider.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  try {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));
    await NotificationService.initialize();
    await initializeDateFormatting('id', null);
  } catch (e, stack) {
    print("ERROR saat inisialisasi: $e");
    print(stack);
  }

  // provider
  runApp(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TaskProvider()..loadTasks()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => OCRProvider()),
      ],
      child: const MyApp(),
    ),
  );
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
