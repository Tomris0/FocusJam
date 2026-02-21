import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const FocusJamApp());
}

class FocusJamApp extends StatelessWidget {
  const FocusJamApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FocusJam',
      theme: ThemeData(useMaterial3: true),
      home: const HomeScreen(),
    );
  }
}