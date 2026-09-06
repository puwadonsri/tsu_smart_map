import 'dart:ui';

/// ตัวแบบข้อมูลของ `assets/config/app_config.json`
///
/// การอ่านค่าทุกจุดใส่ค่า default ไว้ เพราะ config ถูกออกแบบให้ผู้ดูแลแก้ด้วยมือ
/// (ตาม requirement ข้อ 6) — ถ้าคีย์ใดหายไปแอปต้องไม่พัง
class AppConfig {
  final AppSettings app;
  final MapSettings map;
  final List<LocationCategory> layers;
  final List<Shortcut> shortcuts;
  final List<Market> markets;

  const AppConfig({
    required this.app,
    required this.map,
    required this.layers,
    required this.shortcuts,
    required this.markets,
  });

  factory AppConfig.fromJson(Map<String, dynamic> json) {
    return AppConfig(
      app: AppSettings.fromJson(_obj(json['app'])),
      map: MapSettings.fromJson(_obj(json['map'])),
      layers: _list(json['layers']).map(LocationCategory.fromJson).toList(),
      shortcuts: _list(json['shortcuts']).map(Shortcut.fromJson).toList(),
      markets: _list(json['markets']).map(Market.fromJson).toList(),
    );
  }

  LocationCategory? layerById(String id) {
    for (final layer in layers) {
      if (layer.id == id) return layer;
    }
    return null;
  }
}

class AppSettings {
  final String name;
  final String campusName;
  final String emergencyNumber;
  final String emergencyLabel;
  final String tagline;
  final String emergencyTitle;

  const AppSettings({
    required this.name,
    required this.campusName,
    required this.emergencyNumber,
    required this.emergencyLabel,
    required this.tagline,
    required this.emergencyTitle,
  });

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      name: _str(json['name'], 'TSU Smart Map'),
      campusName: _str(json['campusName'], 'มหาวิทยาลัยทักษิณ วิทยาเขตพัทลุง'),
      emergencyNumber: _str(json['emergencyNumber'], '0928733748'),
      emergencyLabel: _str(json['emergencyLabel'], 'สำหรับรถเสีย / อุบัติเหตุ'),
      tagline: _str(json['tagline'], ''),
      emergencyTitle: _str(json['emergencyTitle'], 'เบอร์ฉุกเฉิน'),
    );
  }

  /// 0928733748 -> 092-873-3748
  String get formattedEmergencyNumber {
    final n = emergencyNumber;
    if (n.length == 10 && n.startsWith('0')) {
      return '${n.substring(0, 3)}-${n.substring(3, 6)}-${n.substring(6)}';
    }
    return n;
  }
}

class MapSettings {
  final MapPoint center;
  final double zoom;
  final double minZoom;
  final double maxZoom;
  final TravelSpeeds travel;

  const MapSettings({
    required this.center,
    required this.zoom,
    required this.minZoom,
    required this.maxZoom,
    required this.travel,
  });

  factory MapSettings.fromJson(Map<String, dynamic> json) {
    return MapSettings(
      center: MapPoint.fromJson(_obj(json['center'])),
      zoom: _num(json['zoom'], 16),
      minZoom: _num(json['minZoom'], 12),
      maxZoom: _num(json['maxZoom'], 19),
      travel: TravelSpeeds.fromJson(_obj(json['travel'])),
    );
  }
}

/// ความเร็วที่ใช้ประมาณเวลาเดินทางจาก `distanceKm` (ไม่ต้องเรียก API ใด ๆ)
class TravelSpeeds {
  final double walkKmh;
  final double driveKmh;

  const TravelSpeeds({required this.walkKmh, required this.driveKmh});

  factory TravelSpeeds.fromJson(Map<String, dynamic> json) {
    return TravelSpeeds(
      walkKmh: _num(json['walkKmh'], 4.5),
      driveKmh: _num(json['driveKmh'], 30),
    );
  }

  int walkMinutes(double km) => _minutes(km, walkKmh);
  int driveMinutes(double km) => _minutes(km, driveKmh);

  static int _minutes(double km, double kmh) {
    if (kmh <= 0) return 1;
    final m = (km / kmh * 60).round();
    return m < 1 ? 1 : m;
  }
}

class MapPoint {
  final double lat;
  final double lng;

  const MapPoint({required this.lat, required this.lng});

  factory MapPoint.fromJson(Map<String, dynamic> json) {
    return MapPoint(lat: _num(json['lat'], 7.80822), lng: _num(json['lng'], 99.93869));
  }
}

class LocationCategory {
  final String id;
  final String name;
  final String emoji;

  /// ชื่อไอคอน Material ที่มาจาก config — ไม่ผูกกับชื่อภาษาไทยของชั้นข้อมูล
  final String icon;
  final String description;

  /// หัวข้อของหน้า "รายการจุดทั้งหมด" เช่น "จุดจอดรถรางทั้งหมด"
  final String listTitle;

  /// หัวข้อกลุ่มในแถบด้านข้าง เช่น "ประเภทสถานที่"
  final String group;
  final bool enabled;
  final Color color;
  final List<LocationPoint> locations;

  const LocationCategory({
    required this.id,
    required this.name,
    required this.emoji,
    required this.icon,
    required this.description,
    required this.listTitle,
    required this.group,
    required this.enabled,
    required this.color,
    required this.locations,
  });

  factory LocationCategory.fromJson(Map<String, dynamic> json) {
    final name = _str(json['name'], '');
    return LocationCategory(
      id: _str(json['id'], name),
      name: name,
      emoji: _str(json['emoji'], '📍'),
      icon: _str(json['icon'], 'place'),
      description: _str(json['description'], ''),
      listTitle: _str(json['listTitle'], name),
      group: _str(json['group'], 'ประเภทสถานที่'),
      enabled: json['enabled'] as bool? ?? true,
      color: _parseHexColor(_str(json['color'], '#0D47A1')),
      locations: _list(json['locations']).map(LocationPoint.fromJson).toList(),
    );
  }
}

class LocationPoint {
  final String name;
  final double lat;
  final double lng;
  final String detail;

  const LocationPoint({
    required this.name,
    required this.lat,
    required this.lng,
    required this.detail,
  });

  factory LocationPoint.fromJson(Map<String, dynamic> json) {
    return LocationPoint(
      name: _str(json['name'], ''),
      lat: _num(json['lat'], 0),
      lng: _num(json['lng'], 0),
      detail: _str(json['detail'], ''),
    );
  }
}

class Market {
  final String name;
  final double lat;
  final double lng;
  final String detail;
  final double distanceKm;
  final String emoji;
  final String icon;

  const Market({
    required this.name,
    required this.lat,
    required this.lng,
    required this.detail,
    required this.distanceKm,
    required this.emoji,
    required this.icon,
  });

  factory Market.fromJson(Map<String, dynamic> json) {
    return Market(
      name: _str(json['name'], ''),
      lat: _num(json['lat'], 0),
      lng: _num(json['lng'], 0),
      detail: _str(json['detail'], ''),
      distanceKm: _num(json['distanceKm'], 0),
      emoji: _str(json['emoji'], '🏪'),
      icon: _str(json['icon'], 'storefront'),
    );
  }
}

class Shortcut {
  final String id;
  final String label;
  final String icon;
  final Color color;

  /// markets | emergency | toggleLayer | layerList
  final String action;
  final String? layerId;

  const Shortcut({
    required this.id,
    required this.label,
    required this.icon,
    required this.color,
    required this.action,
    this.layerId,
  });

  factory Shortcut.fromJson(Map<String, dynamic> json) {
    return Shortcut(
      id: _str(json['id'], ''),
      label: _str(json['label'], ''),
      icon: _str(json['icon'], 'place'),
      color: _parseHexColor(_str(json['color'], '#0D47A1')),
      action: _str(json['action'], ''),
      layerId: json['layerId'] as String?,
    );
  }
}

// ---------- ตัวช่วยอ่าน JSON แบบไม่ throw ----------
Map<String, dynamic> _obj(Object? value) =>
    value is Map<String, dynamic> ? value : const <String, dynamic>{};

List<Map<String, dynamic>> _list(Object? value) => value is List
    ? value.whereType<Map<String, dynamic>>().toList()
    : const <Map<String, dynamic>>[];

String _str(Object? value, String fallback) =>
    value is String && value.isNotEmpty ? value : fallback;

double _num(Object? value, double fallback) =>
    value is num ? value.toDouble() : fallback;

Color _parseHexColor(String hex) {
  var value = hex.replaceFirst('#', '');
  if (value.length == 6) value = 'FF$value';
  return Color(int.tryParse(value, radix: 16) ?? 0xFF0D47A1);
}
