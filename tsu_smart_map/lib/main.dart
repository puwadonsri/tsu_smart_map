import 'package:flutter/material.dart';

import 'pages/splash_screen.dart';

void main() {
  runApp(const TSUSmartMapApp());
}

class TSUSmartMapApp extends StatelessWidget {
  const TSUSmartMapApp({super.key});

  /// ธีมสีหลักตาม requirement ข้อ 5
  static const Color primary = Color(0xFF0D47A1);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TSU Smart Map',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: primary,
        colorScheme: ColorScheme.fromSeed(seedColor: primary),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
