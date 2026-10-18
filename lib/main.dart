import 'package:flutter/material.dart';

import 'screens/carte_screen.dart';

void main() {
  runApp(const CarteApp());
}

class CarteApp extends StatelessWidget {
  const CarteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Carte',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const CarteScreen(),
    );
  }
}
