import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../models/app_config.dart';
import '../utils/app_icons.dart';
import '../widgets/location_marker.dart';

/// หน้ารายการจุดทั้งหมดของชั้นข้อมูลหนึ่ง ๆ เช่น "จุดจอดรถรางทั้งหมด"
/// ปิดหน้านี้โดยส่ง [LocationPoint] กลับไป เพื่อให้หน้าแผนที่เลื่อนไปยังจุดนั้น
class LayerListScreen extends StatelessWidget {
  final LocationCategory layer;
  final MapSettings mapSettings;

  const LayerListScreen({super.key, required this.layer, required this.mapSettings});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D47A1),
        foregroundColor: Colors.white,
        title: Text(layer.name, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          SizedBox(height: 240, child: _buildPreviewMap()),
          Expanded(child: _buildList(context)),
        ],
      ),
    );
  }

  Widget _buildPreviewMap() {
    final points = layer.locations.map((l) => LatLng(l.lat, l.lng)).toList();
    return FlutterMap(
      options: MapOptions(
        initialCenter: LatLng(mapSettings.center.lat, mapSettings.center.lng),
        initialZoom: mapSettings.zoom,
        minZoom: mapSettings.minZoom,
        maxZoom: mapSettings.maxZoom,
        initialCameraFit: points.isEmpty
            ? null
            : CameraFit.coordinates(
                coordinates: points,
                padding: const EdgeInsets.all(48),
                maxZoom: 17,
              ),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.tsu_smart_map',
        ),
        MarkerLayer(
          markers: [
            for (final loc in layer.locations)
              Marker(
                point: LatLng(loc.lat, loc.lng),
                width: 160,
                height: 66,
                alignment: Alignment.topCenter,
                child: LocationMarker(label: loc.name, color: layer.color, icon: layer.icon),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildList(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: layer.color,
                child: Icon(iconFromConfig(layer.icon), size: 18, color: Colors.white),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  layer.listTitle,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          for (var i = 0; i < layer.locations.length; i++)
            _buildRow(context, i, layer.locations[i]),
          if (layer.locations.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: Text('ยังไม่มีจุดในชั้นข้อมูลนี้')),
            ),
        ],
      ),
    );
  }

  Widget _buildRow(BuildContext context, int index, LocationPoint loc) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: SizedBox(
        width: 24,
        child: Text(
          '${index + 1}.',
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
        ),
      ),
      title: Text(loc.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      subtitle: loc.detail.isEmpty
          ? null
          : Text(loc.detail, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: () => Navigator.pop(context, loc),
    );
  }
}
