import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../models/app_config.dart';
import '../services/navigation_service.dart';
import '../utils/app_icons.dart';
import '../widgets/location_marker.dart';
import 'emergency_screen.dart';
import 'layer_list_screen.dart';
import 'market_detail_screen.dart';
import 'market_list_screen.dart';

/// หน้าแรก: แผนที่เต็มหน้าจอ + แถบค้นหา + แถบทางลัดล่าง + แถบด้านข้าง
class MapScreen extends StatefulWidget {
  final AppConfig config;

  const MapScreen({super.key, required this.config});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  static const _navy = Color(0xFF0D47A1);
  static const _marketColor = Color(0xFFE91E63);

  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  /// สถานะเปิด/ปิดของแต่ละชั้นข้อมูล (ค่าเริ่มต้นมาจาก `enabled` ใน config)
  final Map<String, bool> _enabledLayers = {};
  final List<_SearchResult> _allPlaces = [];

  String _searchText = '';
  bool _showMarketPins = false;

  AppConfig get _config => widget.config;
  AppSettings get _app => _config.app;

  @override
  void initState() {
    super.initState();
    for (final layer in _config.layers) {
      _enabledLayers[layer.id] = layer.enabled;
    }
    _buildSearchIndex();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _buildSearchIndex() {
    for (final layer in _config.layers) {
      for (final loc in layer.locations) {
        _allPlaces.add(_SearchResult(
          name: loc.name,
          category: layer.name,
          color: layer.color,
          icon: layer.icon,
          lat: loc.lat,
          lng: loc.lng,
          layer: layer,
          location: loc,
        ));
      }
    }
    for (final market in _config.markets) {
      _allPlaces.add(_SearchResult(
        name: market.name,
        category: 'ตลาดใกล้มหาวิทยาลัย',
        color: _marketColor,
        icon: market.icon,
        lat: market.lat,
        lng: market.lng,
        market: market,
      ));
    }
  }

  // ---------- ค้นหา ----------
  List<_SearchResult> get _searchResults {
    final query = _searchText.trim().toLowerCase();
    if (query.isEmpty) return const [];
    return _allPlaces.where((p) => p.name.toLowerCase().contains(query)).take(8).toList();
  }

  void _selectPlace(_SearchResult place) {
    setState(() {
      _searchText = '';
      _searchController.clear();
    });
    FocusScope.of(context).unfocus();
    _mapController.move(LatLng(place.lat, place.lng), 18);
    if (place.market != null) {
      _openMarketDetail(place.market!);
    } else if (place.layer != null && place.location != null) {
      _showPlaceSheet(place.layer!, place.location!);
    }
  }

  // ---------- การกระทำ ----------
  void _openEmergency() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EmergencyScreen(app: _app)),
    );
  }

  Future<void> _openMarketList() async {
    final showAll = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => MarketListScreen(
          markets: _config.markets,
          mapSettings: _config.map,
        ),
      ),
    );
    if (showAll == true) _fitAllMarkets();
  }

  void _openMarketDetail(Market market) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MarketDetailScreen(market: market, mapSettings: _config.map),
      ),
    );
  }

  Future<void> _openLayerList(LocationCategory layer) async {
    final picked = await Navigator.push<LocationPoint>(
      context,
      MaterialPageRoute(
        builder: (_) => LayerListScreen(layer: layer, mapSettings: _config.map),
      ),
    );
    if (picked == null || !mounted) return;
    if (!(_enabledLayers[layer.id] ?? false)) {
      setState(() => _enabledLayers[layer.id] = true);
    }
    _mapController.move(LatLng(picked.lat, picked.lng), 18);
    _showPlaceSheet(layer, picked);
  }

  /// แสดงหมุดตลาดทั้งหมดแล้วซูมให้เห็นครบ (ปุ่ม "ดูเส้นทางทั้งหมดบนแผนที่")
  void _fitAllMarkets() {
    if (_config.markets.isEmpty) return;
    setState(() => _showMarketPins = true);
    _mapController.fitCamera(
      CameraFit.coordinates(
        coordinates: [
          LatLng(_config.map.center.lat, _config.map.center.lng),
          for (final m in _config.markets) LatLng(m.lat, m.lng),
        ],
        padding: const EdgeInsets.all(60),
        maxZoom: 16,
      ),
    );
  }

  void _runShortcut(Shortcut shortcut) {
    switch (shortcut.action) {
      case 'markets':
        _openMarketList();
      case 'emergency':
        _openEmergency();
      case 'toggleLayer':
        final layerId = shortcut.layerId;
        if (layerId != null) _toggleLayer(layerId);
      case 'layerList':
        final layer = _config.layerById(shortcut.layerId ?? '');
        if (layer != null) _openLayerList(layer);
    }
  }

  void _toggleLayer(String id) {
    final enabled = !(_enabledLayers[id] ?? false);
    setState(() => _enabledLayers[id] = enabled);
    final name = _config.layerById(id)?.name ?? id;
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text('$name ${enabled ? 'เปิดแล้ว' : 'ปิดแล้ว'}'),
          duration: const Duration(seconds: 1),
        ),
      );
  }

  void _showPlaceSheet(LocationCategory layer, LocationPoint location) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: layer.color,
                  child: Icon(iconFromConfig(layer.icon), color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        location.name,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                      ),
                      Text(
                        layer.name,
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              location.detail,
              style: const TextStyle(fontSize: 14, color: Color(0xFF5F6368), height: 1.55),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () async {
                  final opened =
                      await NavigationService.openGoogleMaps(location.lat, location.lng);
                  if (!opened && sheetContext.mounted) {
                    ScaffoldMessenger.of(sheetContext).showSnackBar(
                      const SnackBar(content: Text('ไม่สามารถเปิด Google Maps ได้')),
                    );
                  }
                },
                icon: const Icon(Icons.navigation),
                label: const Text('นำทางไป Google Maps'),
                style: FilledButton.styleFrom(
                  backgroundColor: _navy,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- build ----------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: _buildDrawer(),
      body: Stack(
        children: [
          _buildMap(),
          _buildTopBar(),
          _buildSearchResults(),
          _buildMapControls(),
          _buildEmergencyFab(),
          Align(alignment: Alignment.bottomCenter, child: _buildShortcutBar()),
        ],
      ),
    );
  }

  Widget _buildMap() {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: LatLng(_config.map.center.lat, _config.map.center.lng),
        initialZoom: _config.map.zoom,
        minZoom: _config.map.minZoom,
        maxZoom: _config.map.maxZoom,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
        ),
        onTap: (_, __) {
          if (_searchText.isNotEmpty) {
            setState(() {
              _searchText = '';
              _searchController.clear();
            });
          }
        },
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.tsu_smart_map',
        ),
        MarkerLayer(markers: _buildMarkers()),
        RichAttributionWidget(
          alignment: AttributionAlignment.bottomLeft,
          attributions: const [TextSourceAttribution('© OpenStreetMap contributors')],
        ),
      ],
    );
  }

  List<Marker> _buildMarkers() {
    final markers = <Marker>[];
    for (final layer in _config.layers) {
      if (!(_enabledLayers[layer.id] ?? false)) continue;
      for (final loc in layer.locations) {
        markers.add(
          Marker(
            point: LatLng(loc.lat, loc.lng),
            width: 160,
            height: 66,
            alignment: Alignment.topCenter,
            child: LocationMarker(
              label: loc.name,
              color: layer.color,
              icon: layer.icon,
              onTap: () => _showPlaceSheet(layer, loc),
            ),
          ),
        );
      }
    }
    if (_showMarketPins) {
      for (final market in _config.markets) {
        markers.add(
          Marker(
            point: LatLng(market.lat, market.lng),
            width: 160,
            height: 66,
            alignment: Alignment.topCenter,
            child: LocationMarker(
              label: market.name,
              color: _marketColor,
              icon: market.icon,
              onTap: () => _openMarketDetail(market),
            ),
          ),
        );
      }
    }
    return markers;
  }

  Widget _buildTopBar() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 12,
      left: 14,
      right: 14,
      child: Row(
        children: [
          _roundButton(
            Icons.menu,
            'เมนู',
            () => _scaffoldKey.currentState?.openDrawer(),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8)],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (v) => setState(() => _searchText = v),
                decoration: InputDecoration(
                  hintText: 'ค้นหาสถานที่ ภายใน ม.ทักษิณ พัทลุง',
                  hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF9AA0A6)),
                  prefixIcon: const Icon(Icons.search, color: Color(0xFF9AA0A6)),
                  suffixIcon: _searchText.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          onPressed: () => setState(() {
                            _searchText = '';
                            _searchController.clear();
                          }),
                        ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    final results = _searchResults;
    if (_searchText.trim().isEmpty) return const SizedBox.shrink();
    final top = MediaQuery.of(context).padding.top + 66;
    return Positioned(
      top: top,
      left: 14,
      right: 14,
      child: Material(
        elevation: 6,
        borderRadius: BorderRadius.circular(14),
        color: Colors.white,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 320),
          child: results.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'ไม่พบสถานที่ที่ค้นหา',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    final r = results[index];
                    return ListTile(
                      dense: true,
                      leading: CircleAvatar(
                        radius: 16,
                        backgroundColor: r.color,
                        child: Icon(iconFromConfig(r.icon), size: 18, color: Colors.white),
                      ),
                      title: Text(r.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      subtitle: Text(r.category, style: const TextStyle(fontSize: 11)),
                      onTap: () => _selectPlace(r),
                    );
                  },
                  separatorBuilder: (_, __) => const Divider(height: 1),
                ),
        ),
      ),
    );
  }

  Widget _buildMapControls() {
    return Positioned(
      right: 14,
      bottom: 190,
      // ไม่มีปุ่ม "ตำแหน่งของฉัน" เพราะยังไม่ได้เพิ่ม package geolocator
      // (requirement ไม่ได้ระบุไว้ — การนำทางใช้ตำแหน่งผู้ใช้ผ่าน Google Maps อยู่แล้ว)
      child: _roundButton(Icons.near_me, 'กลับไปกลางมหาวิทยาลัย', () {
        setState(() => _showMarketPins = false);
        _mapController.move(
          LatLng(_config.map.center.lat, _config.map.center.lng),
          _config.map.zoom,
        );
      }),
    );
  }

  Widget _roundButton(IconData icon, String tooltip, VoidCallback onTap) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 4,
      child: IconButton(
        tooltip: tooltip,
        icon: Icon(icon, color: _navy),
        onPressed: onTap,
      ),
    );
  }

  Widget _buildEmergencyFab() {
    return Positioned(
      right: 14,
      bottom: 128,
      child: FloatingActionButton.extended(
        heroTag: 'btn_emergency',
        onPressed: _openEmergency,
        backgroundColor: const Color(0xFFE53935),
        icon: const Icon(Icons.phone_in_talk, color: Colors.white),
        label: Text(
          'เบอร์ฉุกเฉิน\n${_app.formattedEmergencyNumber}',
          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildShortcutBar() {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.fromLTRB(14, 0, 14, 12),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 16)],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [for (final s in _config.shortcuts) _buildShortcutButton(s)],
        ),
      ),
    );
  }

  Widget _buildShortcutButton(Shortcut shortcut) {
    final isActive = shortcut.action == 'toggleLayer' &&
        shortcut.layerId != null &&
        (_enabledLayers[shortcut.layerId] ?? false);
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _runShortcut(shortcut),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 23,
              backgroundColor:
                  isActive ? shortcut.color : shortcut.color.withValues(alpha: .12),
              child: Icon(
                iconFromConfig(shortcut.icon),
                color: isActive ? Colors.white : shortcut.color,
                size: 26,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              shortcut.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- แถบด้านข้าง ----------
  Widget _buildDrawer() {
    // จัดกลุ่มชั้นข้อมูลตามฟิลด์ group ใน config
    final groups = <String, List<LocationCategory>>{};
    for (final layer in _config.layers) {
      groups.putIfAbsent(layer.group, () => []).add(layer);
    }

    return Drawer(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            color: _navy,
            padding: EdgeInsets.fromLTRB(16, MediaQuery.of(context).padding.top + 22, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _app.name,
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 3),
                Text(
                  _app.campusName,
                  style: TextStyle(color: Colors.white.withValues(alpha: .85), fontSize: 11),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 8, 4),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'ตัวกรองชั้นข้อมูล',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 20),
              children: [
                for (final entry in groups.entries) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 14, 8, 6),
                    child: Text(
                      entry.key,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
                    ),
                  ),
                  for (final layer in entry.value) _buildLayerTile(layer),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLayerTile(LocationCategory layer) {
    final isOn = _enabledLayers[layer.id] ?? false;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      leading: CircleAvatar(
        backgroundColor: layer.color,
        child: Icon(iconFromConfig(layer.icon), color: Colors.white, size: 22),
      ),
      title: Text(layer.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      subtitle: layer.description.isEmpty
          ? null
          : Text(layer.description, style: const TextStyle(fontSize: 11, height: 1.35)),
      // แตะที่ชื่อ -> เปิดรายการจุดทั้งหมดของชั้นข้อมูลนี้
      onTap: () {
        Navigator.pop(context);
        _openLayerList(layer);
      },
      trailing: Switch(
        value: isOn,
        onChanged: (_) => _toggleLayer(layer.id),
      ),
    );
  }
}

class _SearchResult {
  final String name;
  final String category;
  final Color color;
  final String icon;
  final double lat;
  final double lng;
  final LocationCategory? layer;
  final LocationPoint? location;
  final Market? market;

  const _SearchResult({
    required this.name,
    required this.category,
    required this.color,
    required this.icon,
    required this.lat,
    required this.lng,
    this.layer,
    this.location,
    this.market,
  });
}
