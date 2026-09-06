import 'package:flutter/material.dart';

import '../models/app_config.dart';
import '../services/navigation_service.dart';

/// หน้าจอยืนยันโทรฉุกเฉิน (requirement ข้อ 3) — เต็มหน้าจอสีแดงตามแบบ UI
class EmergencyScreen extends StatelessWidget {
  final AppSettings app;

  const EmergencyScreen({super.key, required this.app});

  Future<void> _call(BuildContext context) async {
    final ok = await NavigationService.call(app.emergencyNumber);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('ไม่สามารถโทรออกได้บนอุปกรณ์นี้ (เบอร์: ${app.formattedEmergencyNumber})'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE53935), Color(0xFFC62828)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Text(
                    app.emergencyTitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 170,
                          height: 170,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: .16),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Container(
                              width: 126,
                              height: 126,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: .2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.call, size: 64, color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        const Text(
                          'โทรออกทันที',
                          style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          app.formattedEmergencyNumber,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 40,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          app.emergencyLabel,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: .9),
                            fontSize: 15,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 44),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 340),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () => _call(context),
                              icon: const Icon(Icons.call, color: Color(0xFFE53935)),
                              label: const Text(
                                'กดโทรออก',
                                style: TextStyle(
                                  color: Color(0xFFE53935),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 17),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(32),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
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
