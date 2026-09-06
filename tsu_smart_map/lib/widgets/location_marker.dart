import 'package:flutter/material.dart';

import '../utils/app_icons.dart';

/// หมุดบนแผนที่: วงกลมสีของชั้นข้อมูล + ป้ายชื่อสถานที่
///
/// ใช้ไอคอน Material ตามชื่อที่กำหนดใน config (ไม่ใช้ emoji เพราะบางแพลตฟอร์ม
/// โดยเฉพาะ Windows/เว็บบางเบราว์เซอร์ วาด emoji ไม่ครบสี)
class LocationMarker extends StatelessWidget {
  final String label;
  final Color color;
  final String icon;
  final VoidCallback? onTap;

  const LocationMarker({
    super.key,
    required this.label,
    required this.color,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: const [
                BoxShadow(color: Colors.black38, blurRadius: 6, offset: Offset(0, 2)),
              ],
            ),
            child: Icon(iconFromConfig(icon), size: 18, color: Colors.white),
          ),
          const SizedBox(height: 3),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(7),
                boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
              ),
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF1A1A1A),
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
