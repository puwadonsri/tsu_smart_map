import 'package:flutter/material.dart';

import '../models/app_config.dart';
import '../services/navigation_service.dart';

class MarketListScreen extends StatelessWidget {
  final List<Market> markets;

  const MarketListScreen({super.key, required this.markets});

  static const List<Color> _palette = [
    Color(0xFFE91E63),
    Color(0xFF43A047),
    Color(0xFF5D9CEC),
    Color(0xFF8E24AA),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ตลาดใกล้มหาวิทยาลัย', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF0D47A1),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (var i = 0; i < markets.length; i++)
            _buildMarketCard(context, markets[i], _palette[i % _palette.length]),
        ],
      ),
    );
  }

  Widget _buildMarketCard(BuildContext context, Market market, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () async {
          final opened = await NavigationService.openGoogleMaps(market.lat, market.lng);
          if (!opened && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('ไม่สามารถเปิด Google Maps ได้')),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(market.emoji, style: const TextStyle(fontSize: 40)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      market.name,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 14, color: Colors.grey),
                        Text(
                          ' ${market.distanceKm.toStringAsFixed(1)} กม.',
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      market.detail,
                      style: const TextStyle(color: Colors.black87, fontSize: 12),
                    ),
                    const SizedBox(height: 6),
                    const Row(
                      children: [
                        Icon(Icons.directions, size: 14, color: Color(0xFF0D47A1)),
                        SizedBox(width: 4),
                        Text(
                          'นำทางไป Google Maps',
                          style: TextStyle(color: Color(0xFF0D47A1), fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ],
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
}