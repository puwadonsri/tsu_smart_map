import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../models/app_config.dart';
import '../services/navigation_service.dart';
import '../utils/app_icons.dart';
import '../widgets/location_marker.dart';

/// หน้ารายละเอียดตลาด: ข้อมูล + ปุ่มนำทาง/แชร์ + เวลาเดินทางโดยประมาณ + แผนที่ย่อ
class MarketDetailScreen extends StatelessWidget {
  final Market market;
  final MapSettings mapSettings;

  const MarketDetailScreen({super.key, required this.market, required this.mapSettings});

  static const _accent = Color(0xFFE91E63);
  static const _navy = Color(0xFF0D47A1);

  Future<void> _navigate(BuildContext context, String travelMode) async {
    final opened = await NavigationService.openGoogleMaps(
      market.lat,
      market.lng,
      travelMode: travelMode,
    );
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ไม่สามารถเปิด Google Maps ได้')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final travel = mapSettings.travel;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: _navy,
        foregroundColor: Colors.white,
        title: const Text('ตลาดใกล้มหาวิทยาลัย', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: _accent,
                child: Icon(iconFromConfig(market.icon), color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      market.name,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 14, color: Colors.grey),
                        Text(
                          ' ${market.distanceKm.toStringAsFixed(1)} กม.',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            market.detail,
            style: const TextStyle(fontSize: 14, color: Color(0xFF5F6368), height: 1.55),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => _navigate(context, 'driving'),
                  icon: const Icon(Icons.navigation),
                  label: const Text('นำทาง'),
                  style: FilledButton.styleFrom(
                    backgroundColor: _navy,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    final url = NavigationService.directionsUri(market.lat, market.lng).toString();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('ลิงก์เส้นทาง: $url')),
                    );
                  },
                  icon: const Icon(Icons.share),
                  label: const Text('แชร์'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _navy,
                    side: const BorderSide(color: _navy, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          const Text('เส้นทาง', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _chip(Icons.directions_car, 'ขับรถ',
                  '${travel.driveMinutes(market.distanceKm)} นาที (${market.distanceKm.toStringAsFixed(1)} กม.)'),
              _chip(Icons.directions_walk, 'เดิน',
                  '${travel.walkMinutes(market.distanceKm)} นาที (${market.distanceKm.toStringAsFixed(1)} กม.)'),
            ],
          ),
          const SizedBox(height: 22),
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: SizedBox(height: 200, child: _buildMiniMap()),
          ),
          const SizedBox(height: 8),
          const Text(
            'เส้นบนแผนที่เป็นเส้นตรงระหว่างมหาวิทยาลัยกับตลาด ใช้ดูทิศทางคร่าว ๆ '
            'เส้นทางจริงให้กดปุ่ม "นำทาง" เพื่อเปิดใน Google Maps',
            style: TextStyle(fontSize: 11, color: Colors.grey, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _chip(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F3F4),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: _navy),
          const SizedBox(width: 6),
          Text('$label ', style: const TextStyle(fontSize: 12, color: Color(0xFF3C4043))),
          Text(
            value,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF3C4043)),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniMap() {
    final campus = LatLng(mapSettings.center.lat, mapSettings.center.lng);
    final target = LatLng(market.lat, market.lng);
    return FlutterMap(
      options: MapOptions(
        initialCenter: target,
        initialZoom: mapSettings.zoom,
        minZoom: mapSettings.minZoom,
        maxZoom: mapSettings.maxZoom,
        initialCameraFit: CameraFit.coordinates(
          coordinates: [campus, target],
          padding: const EdgeInsets.all(44),
          maxZoom: 16,
        ),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.tsu_smart_map',
        ),
        PolylineLayer(
          polylines: [
            Polyline(points: [campus, target], strokeWidth: 4, color: _navy),
          ],
        ),
        MarkerLayer(
          markers: [
            Marker(
              point: target,
              width: 160,
              height: 66,
              alignment: Alignment.topCenter,
              child: LocationMarker(label: market.name, color: _accent, icon: market.icon),
            ),
          ],
        ),
      ],
    );
  }
}
