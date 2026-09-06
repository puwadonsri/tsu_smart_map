import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import '../models/app_config.dart';

class ConfigService {
  static const String _configAsset = 'assets/config/app_config.json';
  static const String _runtimeConfigUrl = 'config/app_config.json';

  /// โหลด config โดยพยายามดึงจากไฟล์ภายนอกก่อน (กรณี web ที่รันอยู่แล้ว)
  /// ถ้าไม่มีจะใช้ config ที่ฝังมากับแอป
  static Future<AppConfig> load() async {
    final runtimeJson = await _tryFetchRuntime();
    if (runtimeJson != null) {
      return AppConfig.fromJson(runtimeJson);
    }
    final raw = await rootBundle.loadString(_configAsset);
    final json = jsonDecode(raw) as Map<String, dynamic>;
    return AppConfig.fromJson(json);
  }

  static Future<Map<String, dynamic>?> _tryFetchRuntime() async {
    try {
      final uri = Uri.parse(_runtimeConfigUrl);
      final response = await http.get(uri).timeout(const Duration(seconds: 4));
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
    } catch (_) {
      // ปิดเสียง — fallback ไปใช้ asset
    }
    return null;
  }
}