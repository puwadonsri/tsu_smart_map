import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/app_config.dart';
import '../services/config_service.dart';
import '../services/navigation_service.dart';
import '../widgets/location_marker.dart';
import 'market_list_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();

  AppConfig? _config;
  String? _error;
  final Map<String, bool> _enabledLayers = {};
  final List<_SearchResult> _allPlaces = [];
  String _searchText = '';

  String get _emergencyNumber => _config?.app.emergencyNumber ?? '0928733748';

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadConfig() async {
    setState(() => _error = null);
    try {
      final config = await ConfigService.load();
      for (final c in config.layers) {
        _enabledLayers[c.id] = c.enabled;
      }
      _allPlaces.clear();
      for (final layer in config.layers) {
        for (final loc in layer.locations) {
          _allPlaces.add(
            _SearchResult(
              name: loc.name,
              subtitle: layer.name,
              lat: loc.lat,
              lng: loc.lng,
            ),
          );
        }
      }
      for (final m in config.markets) {
        _allPlaces.add(
          _SearchResult(
            name: m.name,
            subtitle: 'ตลาด',
            lat: m.lat,
            lng: m.lng,
          ),
        );
      }
      if (mounted) {
        setState(() => _config = config);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = 'โหลด config ไม่สำเร็จ: $e');
      }
    }
  }

  // ---------- Search ----------
  List<_SearchResult> get _searchResults {
    final query = _searchText.trim().toLowerCase();
    if (query.isEmpty) return const [];
    return _allPlaces
        .where((p) => p.name.toLowerCase().contains(query))
        .toList();
  }

  void _onSearch(String value) {
    setState(() => _searchText = value);
  }

  void _selectPlace(_SearchResult place) {
    setState(() {
      _searchText = '';
      _searchController.clear();
    });
    FocusScope.of(context).unfocus();
    _mapController.move(LatLng(place.lat, place.lng), 17);
    _showSnack(place.name);
  }

  // ---------- Actions ----------
  Future<void> _callEmergency() async {
    final uri = Uri.parse('tel:$_emergencyNumber');
    try {
      final launched = await launchUrl(uri);
      if (!launched && mounted) {
        _showSnack('ไม่สามารถโทรออกได้บนอุปกรณ์นี้ (เบอร์: $_emergencyNumber)');
      }
    } catch (_) {
      if (mounted) {
        _showSnack('ไม่สามารถโทรออกได้บนอุปกรณ์นี้ (เบอร์: $_emergencyNumber)');
      }
    }
  }

  void _runShortcut(Shortcut shortcut) {
    switch (shortcut.action) {
      case 'markets':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MarketListScreen(markets: _config?.markets ?? const []),
          ),
        );
      case 'emergency':
        _showEmergencyDialog(context);
      case 'toggleLayer':
        final layerId = shortcut.layerId;
        if (layerId != null) {
          final newVal = !(_enabledLayers[layerId] ?? false);
          setState(() => _enabledLayers[layerId] = newVal);
          final layerName = _layerNameById(layerId);
          _showSnack('$layerName${newVal ? ' เปิดแล้ว' : ' ปิดแล้ว'}');
        }
    }
  }

  String _layerNameById(String id) {
    final config = _config;
    if (config == null) return id;
    for (final layer in config.layers) {
      if (layer.id == id) return layer.name;
    }
    return id;
  }

  void _toggleFilter(String id) {
    setState(() {
      _enabledLayers[id] = !(_enabledLayers[id] ?? false);
    });
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  String _formatPhone(String number) {
    if (number.length == 10 && number.startsWith('0')) {
      return '${number.substring(0, 3)}-${number.substring(3, 6)}-${number.substring(6)}';
    }
    return number;
  }

  void _showEmergencyDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.red.shade600,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.phone, size: 80, color: Colors.white),
            const SizedBox(height: 20),
            const Text('โทรออกทันที', style: TextStyle(color: Colors.white, fontSize: 24)),
            Text(
              _formatPhone(_emergencyNumber),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _config?.app.emergencyLabel ?? 'สำหรับรถเสีย / อุบัติเหตุ',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: _callEmergency,
              icon: const Icon(Icons.call, color: Colors.red),
              label: const Text(
                'กดโทรออก',
                style: TextStyle(color: Colors.red, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 60),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPlaceInfo(LocationCategory category, LocationPoint location) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: category.color, shape: BoxShape.circle),
                  child: Text(category.emoji, style: const TextStyle(fontSize: 20)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    location.name,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(location.detail, style: const TextStyle(fontSize: 14, color: Colors.black87)),
            const SizedBox(height: 8),
            Text('หมวดหมู่: ${category.name}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () async {
                  final opened =
                      await NavigationService.openGoogleMaps(location.lat, location.lng);
                  if (!opened && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('ไม่สามารถเปิด Google Maps ได้')),
                    );
                  }
                },
                icon: const Icon(Icons.directions),
                label: const Text('นำทางไป Google Maps'),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF0D47A1),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- Builders ----------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      drawer: _buildSidebar(),
      body: Stack(
        children: [
          _buildMap(),
          _buildSearchResultsOverlay(),
          Positioned(
            right: 16,
            bottom: 100,
            child: FloatingActionButton.extended(
              heroTag: 'btn_emergency',
              onPressed: () => _showEmergencyDialog(context),
              backgroundColor: Colors.red,
              icon: const Icon(Icons.phone, color: Colors.white),
              label: Text(
                'เบอร์ฉุกเฉิน\n${_formatPhone(_emergencyNumber)}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: _buildBottomShortcutBar(),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.black87),
      title: Container(
        height: 45,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 5),
          ],
        ),
        child: TextField(
          controller: _searchController,
          onChanged: _onSearch,
          decoration: const InputDecoration(
            hintText: 'ค้นหาสถานที่ ภายใน ม.ทักษิณ...',
            prefixIcon: Icon(Icons.search, color: Colors.grey),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResultsOverlay() {
    final results = _searchResults;
    final top = MediaQuery.of(context).padding.top + kToolbarHeight;
    if (results.isEmpty) return const SizedBox.shrink();
    return Positioned(
      top: top + 8,
      left: 12,
      right: 12,
      child: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 320),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: results.length,
            itemBuilder: (context, index) {
              final r = results[index];
              return ListTile(
                dense: true,
                leading: const Icon(Icons.place, color: Color(0xFF0D47A1)),
                title: Text(r.name, style: const TextStyle(fontSize: 14)),
                subtitle: Text(r.subtitle, style: const TextStyle(fontSize: 12)),
                onTap: () => _selectPlace(r),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildMap() {
    final config = _config;
    if (config == null) {
      return _buildLoadingOrError();
    }
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: LatLng(config.map.center.lat, config.map.center.lng),
        initialZoom: config.map.zoom,
        minZoom: config.map.minZoom,
        maxZoom: config.map.maxZoom,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
        ),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.tsu_smart_map',
        ),
        MarkerLayer(markers: _buildMarkers()),
        RichAttributionWidget(
          alignment: AttributionAlignment.bottomRight,
          popupInitialDisplayDuration: const Duration(seconds: 6),
          attributions: const [
            TextSourceAttribution('© OpenStreetMap contributors'),
          ],
        ),
      ],
    );
  }

  List<Marker> _buildMarkers() {
    final config = _config;
    if (config == null) return const [];
    final markers = <Marker>[];
    for (final layer in config.layers) {
      if (!(_enabledLayers[layer.id] ?? false)) continue;
      for (final loc in layer.locations) {
        markers.add(
          Marker(
            point: LatLng(loc.lat, loc.lng),
            width: 150,
            height: 52,
            alignment: Alignment.topCenter,
            child: LocationMarker(
              location: loc,
              color: layer.color,
              emoji: layer.emoji,
              onTap: () => _showPlaceInfo(layer, loc),
            ),
          ),
        );
      }
    }
    return markers;
  }

  Widget _buildLoadingOrError() {
    final error = _error;
    if (error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 40),
              const SizedBox(height: 12),
              Text(error, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              FilledButton(onPressed: _loadConfig, child: const Text('ลองใหม่')),
            ],
          ),
        ),
      );
    }
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildSidebar() {
    final config = _config;
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('ตัวกรองชั้นข้อมูล', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: ListView(
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      'ประเภทสถานที่',
                      style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                    ),
                  ),
                  if (config == null)
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else
                    ...config.layers.map((layer) {
                      final isOn = _enabledLayers[layer.id] ?? false;
                      return _buildFilterSwitch(
                        layer.name,
                        '${layer.emoji} ${_layerDescriptions[layer.id] ?? ''}',
                        layer.color,
                        isOn,
                        (val) => _toggleFilter(layer.id),
                      );
                    }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static const Map<String, String> _layerDescriptions = {
    'tram': 'ศาลาที่จอดรถราง',
    'fuel': 'ปั๊มน้ำมัน / จุดเติมใกล้เคียง',
    'scooter': 'จอด / เช่าสกู๊ตเตอร์ไฟฟ้า',
    'caution': 'ทางแยกอุบัติเหตุบ่อย',
  };

  Widget _buildFilterSwitch(
    String title,
    String subtitle,
    Color iconColor,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: iconColor,
        child: Icon(
          _iconForLayer(title),
          color: Colors.white,
          size: 20,
        ),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: Colors.blue,
      ),
    );
  }

  Widget _buildBottomShortcutBar() {
    final config = _config;
    if (config == null) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          for (final shortcut in config.shortcuts)
            _buildBottomMenuItem(shortcut),
        ],
      ),
    );
  }

  Widget _buildBottomMenuItem(Shortcut shortcut) {
    final isActive = shortcut.action == 'toggleLayer' &&
        shortcut.layerId != null &&
        (_enabledLayers[shortcut.layerId] ?? false);
    return GestureDetector(
      onTap: () => _runShortcut(shortcut),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            backgroundColor: isActive
                ? shortcut.color
                : shortcut.color.withValues(alpha: 0.1),
            radius: 25,
            child: Icon(
              _iconFor(shortcut.icon),
              color: isActive ? Colors.white : shortcut.color,
              size: 28,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            shortcut.label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _SearchResult {
  final String name;
  final String subtitle;
  final double lat;
  final double lng;

  const _SearchResult({
    required this.name,
    required this.subtitle,
    required this.lat,
    required this.lng,
  });
}

IconData _iconFor(String name) {
  switch (name) {
    case 'storefront':
      return Icons.storefront;
    case 'phone_in_talk':
      return Icons.phone_in_talk;
    case 'directions_bus':
      return Icons.directions_bus;
    case 'local_gas_station':
      return Icons.local_gas_station;
    case 'electric_scooter':
      return Icons.electric_scooter;
    case 'warning':
      return Icons.warning_amber_rounded;
    default:
      return Icons.place;
  }
}

IconData _iconForLayer(String title) {
  switch (title) {
    case 'จุดรถราง':
      return Icons.directions_bus;
    case 'จุดเติมน้ำมัน':
      return Icons.local_gas_station;
    case 'จุดสกู๊ตเตอร์':
      return Icons.electric_scooter;
    case 'จุดควรระมัดระวัง':
      return Icons.warning_amber_rounded;
    default:
      return Icons.place;
  }
}