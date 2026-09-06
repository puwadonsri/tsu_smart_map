import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import '../models/app_config.dart';

class ConfigService {
  static const String _configAsset = 'assets/config/app_config.json';
  static const String _runtimeConfigUrl = 'config/app_config.json';

  /// โหลด config
  ///
  /// บนเว็บจะลองดึงไฟล์ `config/app_config.json` ที่วางข้างตัว build ก่อน
  /// (แก้แล้วรีเฟรชเห็นผลทันทีตาม requirement ข้อ 6) ถ้าไม่มีจึงใช้ asset ที่ฝังมา
  /// บนแพลตฟอร์มอื่นข้ามขั้นตอน HTTP ไปเลย เพราะ path แบบ relative ใช้ไม่ได้
  static Future<AppConfig> load() async {
    if (kIsWeb) {
      final runtimeJson = await _tryFetchRuntime();
      if (runtimeJson != null) return AppConfig.fromJson(runtimeJson);
    }
    final raw = await rootBundle.loadString(_configAsset);
    return AppConfig.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  static Future<Map<String, dynamic>?> _tryFetchRuntime() async {
    try {
      final response = await http
          .get(Uri.base.resolve(_runtimeConfigUrl))
          .timeout(const Duration(seconds: 4));
      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      }
    } catch (_) {
      // ปิดเสียง — fallback ไปใช้ asset
    }
    return null;
  }
}
