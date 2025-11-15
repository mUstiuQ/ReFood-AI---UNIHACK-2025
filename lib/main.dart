import 'package:flutter/material.dart';
import 'package:unihack_2025/DashboardScreen.dart';
import 'NewStartPage.dart';

void main() {
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

