import 'package:flutter/material.dart';

import 'pages/splash_screen.dart';

void main() {
  runApp(const TSUSmartMapApp());
}

class TSUSmartMapApp extends StatelessWidget {
  const TSUSmartMapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TSU Smart Map',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF0D47A1),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0D47A1)),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}