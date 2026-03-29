import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(scaffoldBackgroundColor: Colors.white),
      home: Scaffold(
        body: Center(
          child: Theme(
            data: ThemeData(scaffoldBackgroundColor: Colors.yellow),
            child: Container(
              width: 140,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.yellow,
                border: Border.all(color: Colors.red, width: 3),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
