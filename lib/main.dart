import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:unihack_2025/DashboardScreen.dart';
import 'NewStartPage.dart';
import 'chatbot_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'DonateFoodPage.dart';
import 'pages/login_page.dart';
import 'app_theme.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

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

  WidgetsFlutterBinding.ensureInitialized();

  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } catch (e) {
    if (e is FirebaseException && e.code == 'duplicate-app') {
      print('Firebase already initialized');
    } else {
      rethrow;
    }
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
      home: const LoginPage(),
    );
  }
}

