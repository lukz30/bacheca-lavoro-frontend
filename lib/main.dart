import 'package:flutter/material.dart';

import 'api_service.dart';
import 'screens/job_list_screen.dart';
import 'config.dart';
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppConfig.load(); // indirizzo del server salvato
  await Api.loadSession(); // recupera l'eventuale login precedente
  runApp(const BachecaApp());
}

class BachecaApp extends StatelessWidget {
  const BachecaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bacheca Lavoro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      home: const JobListScreen(), // schermata pubblica
    );
  }
}
