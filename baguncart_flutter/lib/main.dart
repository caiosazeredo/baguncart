import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(BaguncartApp());
}

class BaguncartApp extends StatelessWidget {
  const BaguncartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BagunçArt - Sistema Administrativo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.purple,
        primaryColor: const Color(0xFF8B2F8B),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8B2F8B),
          secondary: const Color(0xFFFF8C00),
        ),
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
        cardColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF8B2F8B),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF8C00),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
      home: const LoginScreen(),
    );
  }
}
