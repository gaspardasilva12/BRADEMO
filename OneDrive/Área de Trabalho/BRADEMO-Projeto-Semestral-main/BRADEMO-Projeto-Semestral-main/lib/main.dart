import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IF Equipamentos',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF1B5E20),
          onPrimary: Colors.white,
          secondary: Color(0xFF4CAF50),
          onSecondary: Colors.white,
          surface: Colors.white,
          onSurface: Colors.black87,
          error: Colors.red,
        ),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Color(0xFF1B5E20)),
          titleTextStyle: TextStyle(
            color: Color(0xFF1B5E20),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF1F3F6),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          hintStyle: const TextStyle(color: Color(0xFF1B5E20)),
          prefixIconColor: const Color(0xFF1B5E20),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1B5E20),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF1B5E20),
          foregroundColor: Colors.white,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF1B5E20),
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white70,
        ),
        textTheme: const TextTheme(
          headlineSmall: TextStyle(
            color: Color(0xFF1B5E20),
            fontWeight: FontWeight.bold,
          ),
          labelMedium: TextStyle(color: Colors.grey),
          bodyMedium: TextStyle(color: Colors.grey),
        ),
      ),
      home: const LoginScreen(),
    );
  }
}
