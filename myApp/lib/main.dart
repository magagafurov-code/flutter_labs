import 'package:flutter/material.dart';
import 'weather_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Погода',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF1A1E2C),
        primaryColor: const Color(0xFF6C5ECF),
      ),
      home: const WeatherScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}