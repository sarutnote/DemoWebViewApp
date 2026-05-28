import 'package:flutter/material.dart';
import 'core/theme.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const WebAvatarApp());
}

class WebAvatarApp extends StatelessWidget {
  const WebAvatarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Web Avatar App',
      theme: AppTheme.lightTheme,
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
