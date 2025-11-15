import 'package:flutter/material.dart';
import 'package:unihack_2025/dashboard_screen.dart';
import 'new_start_page.dart';
import 'chatbot_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {

  runApp(const MyApp());
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");  // trebuie exact numele fișierului asta in main inainte de rurale a aplicatiei
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Recomandat pentru aplicațiile Flutter
      title: 'ReFood AI App',
      // 2. Apelarea codului tău:
      home: const NewStartPage(),
    );
  }
}

