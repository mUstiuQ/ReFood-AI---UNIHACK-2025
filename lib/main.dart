import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:unihack_2025/DashboardScreen.dart';
import 'NewStartPage.dart';
import 'chatbot_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'DonateFoodPage.dart';

Future<void> main() async {

  runApp(const MyApp());
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");  // trebuie exact numele fișierului asta in main inainte de rurale a aplicatiei
  await Hive.initFlutter();
  await Hive.openBox('donations');

  var chatBox = await Hive.openBox('chatBox');
  var donationsBox = await Hive.openBox('donations');

  if (!chatBox.containsKey('initialized')) {
    await chatBox.clear();
    await donationsBox.clear();
    await chatBox.put('__app_initialized__', true);
  }

  runApp(const MyApp());
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

