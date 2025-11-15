import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'pages/login_page.dart';
import 'app_theme.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
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

  // 5. Run your app
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  // ... (The rest of your MyApp class is fine)
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ReFood AI App',
      theme: ThemeData(
        primaryColor: primaryGreen,
        scaffoldBackgroundColor: lightGreenBg,
        colorScheme: ColorScheme.fromSeed(seedColor: primaryGreen),
        useMaterial3: true,
      ),
      home: const LoginPage(),
    );
  }
}