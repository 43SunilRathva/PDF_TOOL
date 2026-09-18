import 'package:flutter/material.dart';

import 'screens/home_screen.dart';

void main() {
  runApp(const PdfToolApp());
}

class PdfToolApp extends StatelessWidget {
  const PdfToolApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PDF Tool',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      ),
      home: const HomeScreen(),
    );
  }
}
