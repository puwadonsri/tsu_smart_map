import 'package:flutter/material.dart';

import '../models/app_config.dart';
import '../utils/app_icons.dart';
import 'market_detail_screen.dart';

/// รายชื่อตลาดรอบมหาวิทยาลัย (requirement ข้อ 4)
///
/// กดการ์ด -> หน้ารายละเอียด, กดปุ่มล่าง -> ปิดหน้านี้พร้อมส่ง `true` กลับไป
/// ให้หน้าแผนที่แสดงหมุดตลาดทั้งหมด
class MarketListScreen extends StatelessWidget {
  final List<Market> markets;
  final MapSettings mapSettings;

  const MarketListScreen({super.key, required this.markets, required this.mapSettings});

  static const _accent = Color(0xFFE91E63);
  static const _navy = Color(0xFF0D47A1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ตลาดใกล้มหาวิทยาลัย', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: _navy,
        foregroundColor: Colors.white,
      ),
      body: markets.isEmpty
          ? const Center(child: Text('ยังไม่มีข้อมูลตลาดใน config'))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                for (final market in markets) _buildCard(context, market),
                const SizedBox(height: 4),
                _buildShowAllButton(context),
              ],
            ),
    );
  }

  Widget _buildCard(BuildContext context, Market market) {
    final walk = mapSettings.travel.walkMinutes(market.distanceKm);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MarketDetailScreen(market: market, mapSettings: mapSettings),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: _accent.withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(iconFromConfig(market.icon), size: 28, color: _accent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      market.name,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 12,
                      children: [
                        _meta(Icons.location_on, '${market.distanceKm.toStringAsFixed(1)} กม.'),
                        _meta(Icons.directions_walk, 'ประมาณ $walk นาที'),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      market.detail,
                      style: const TextStyle(fontSize: 12, color: Color(0xFF5F6368), height: 1.4),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _meta(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey),
        const SizedBox(width: 3),
        Text(text, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildShowAllButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: () => Navigator.pop(context, true),
        icon: const Icon(Icons.map),
        label: const Text('ดูเส้นทางทั้งหมดบนแผนที่'),
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFFE8F0FE),
          foregroundColor: _navy,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }
}
