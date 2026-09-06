import 'package:flutter/material.dart';

import '../models/app_config.dart';
import '../services/config_service.dart';
import 'map_screen.dart';

/// หน้าเปิดแอป — โหลด config ไปพร้อมกับแสดงโลโก้ แล้วส่ง config ต่อให้หน้าแผนที่
/// (เดิมหน้าแผนที่โหลดเองทำให้เห็นจอว่าง ๆ ระหว่างรอ)
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static const _minDuration = Duration(milliseconds: 1800);

  AppConfig? _config;
  String? _error;

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    setState(() => _error = null);
    final delay = Future<void>.delayed(_minDuration);
    try {
      final config = await ConfigService.load();
      // แสดงชื่อวิทยาเขต/สโลแกนจาก config ทันทีที่โหลดเสร็จ ระหว่างรอครบเวลา splash
      if (mounted) setState(() => _config = config);
      await delay;
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => MapScreen(config: config)),
      );
    } catch (e) {
      await delay;
      if (!mounted) return;
      setState(() => _error = 'โหลดข้อมูลไม่สำเร็จ: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = _config?.app;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF5D9CEC), Color(0xFF1976D2), Color(0xFF0D47A1)],
            stops: [0, .55, 1],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 112,
                      height: 112,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: .16),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.location_on, size: 60, color: Colors.white),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'TSU',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1.1,
                        letterSpacing: 1,
                      ),
                    ),
                    const Text(
                      'Smart Map',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      app?.campusName ?? 'มหาวิทยาลัยทักษิณ วิทยาเขตพัทลุง',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    if ((app?.tagline ?? '').isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          '"${app!.tagline}"',
                          style: TextStyle(
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                            color: Colors.white.withValues(alpha: .8),
                          ),
                        ),
                      ),
                    if (_error != null) ...[
                      const SizedBox(height: 28),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                        ),
                      ),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: _start,
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF0D47A1),
                        ),
                        child: const Text('ลองใหม่'),
                      ),
                    ],
                  ],
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 44),
                  child: Text(
                    'THAKSIN UNIVERSITY',
                    style: TextStyle(
                      fontSize: 12,
                      letterSpacing: 3,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: .85),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
