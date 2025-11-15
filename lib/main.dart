import 'package:flutter/material.dart';
import 'pages/login_page.dart';
import 'app_theme.dart';
import 'pages/image_detection_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
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
      //home: const LoginPage(),
      home: const ImageDetectionPage(),
    );
  }
}