import 'package:flutter/material.dart';

import 'homeScreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
      title: 'AI Background Remover',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    );
  }
}
