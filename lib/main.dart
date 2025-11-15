import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'NewStartPage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initializare Hive
  await Hive.initFlutter();

  // Deschidem box-urile
  var chatBox = await Hive.openBox('chatBox');
  var donationsBox = await Hive.openBox('donations');

  // 🔥 Resetare box-uri O SINGURĂ DATĂ
  if (!chatBox.containsKey('initialized')) {
    await chatBox.clear();
    await donationsBox.clear();
    await chatBox.put('__app_initialized__', true);
  }

  // Incarcam .env
  await dotenv.load(fileName: ".env");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ReFood AI App',
      home: const NewStartPage(),
    );
  }
}
