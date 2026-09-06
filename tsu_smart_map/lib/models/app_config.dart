import 'dart:ui';

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
      app: AppSettings.fromJson(json['app'] as Map<String, dynamic>),
      map: MapSettings.fromJson(json['map'] as Map<String, dynamic>),
      layers: (json['layers'] as List<dynamic>)
          .map((e) => LocationCategory.fromJson(e as Map<String, dynamic>))
          .toList(),
      shortcuts: (json['shortcuts'] as List<dynamic>)
          .map((e) => Shortcut.fromJson(e as Map<String, dynamic>))
          .toList(),
      markets: (json['markets'] as List<dynamic>)
          .map((e) => Market.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class AppSettings {
  final String name;
  final String campusName;
  final String emergencyNumber;
  final String emergencyLabel;

  const AppSettings({
    required this.name,
    required this.campusName,
    required this.emergencyNumber,
    required this.emergencyLabel,
  });

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      name: json['name'] as String,
      campusName: json['campusName'] as String,
      emergencyNumber: json['emergencyNumber'] as String,
      emergencyLabel: json['emergencyLabel'] as String,
    );
  }
}

class MapSettings {
  final MapPoint center;
  final double zoom;
  final double minZoom;
  final double maxZoom;

  const MapSettings({
    required this.center,
    required this.zoom,
    required this.minZoom,
    required this.maxZoom,
  });

  factory MapSettings.fromJson(Map<String, dynamic> json) {
    return MapSettings(
      center: MapPoint.fromJson(json['center'] as Map<String, dynamic>),
      zoom: (json['zoom'] as num).toDouble(),
      minZoom: (json['minZoom'] as num).toDouble(),
      maxZoom: (json['maxZoom'] as num).toDouble(),
    );
  }
}

class MapPoint {
  final double lat;
  final double lng;

  const MapPoint({required this.lat, required this.lng});

  factory MapPoint.fromJson(Map<String, dynamic> json) {
    return MapPoint(
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
    );
  }
}

class LocationCategory {
  final String id;
  final String name;
  final String emoji;
  final bool enabled;
  final Color color;
  final List<LocationPoint> locations;

  const LocationCategory({
    required this.id,
    required this.name,
    required this.emoji,
    required this.enabled,
    required this.color,
    required this.locations,
  });

  factory LocationCategory.fromJson(Map<String, dynamic> json) {
    return LocationCategory(
      id: json['id'] as String,
      name: json['name'] as String,
      emoji: json['emoji'] as String,
      enabled: json['enabled'] as bool,
      color: _parseHexColor(json['color'] as String),
      locations: (json['locations'] as List<dynamic>)
          .map((e) => LocationPoint.fromJson(e as Map<String, dynamic>))
          .toList(),
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
      name: json['name'] as String,
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      detail: json['detail'] as String,
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

  const Market({
    required this.name,
    required this.lat,
    required this.lng,
    required this.detail,
    required this.distanceKm,
    required this.emoji,
  });

  factory Market.fromJson(Map<String, dynamic> json) {
    return Market(
      name: json['name'] as String,
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      detail: json['detail'] as String,
      distanceKm: (json['distanceKm'] as num).toDouble(),
      emoji: (json['emoji'] as String?) ?? '🏪',
    );
  }
}

class Shortcut {
  final String id;
  final String label;
  final String icon;
  final Color color;
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
      id: json['id'] as String,
      label: json['label'] as String,
      icon: json['icon'] as String,
      color: _parseHexColor(json['color'] as String),
      action: json['action'] as String,
      layerId: json['layerId'] as String?,
    );
  }
}

Color _parseHexColor(String hex) {
  var value = hex.replaceFirst('#', '');
  if (value.length == 6) {
    value = 'FF$value';
  }
  return Color(int.parse(value, radix: 16));
}