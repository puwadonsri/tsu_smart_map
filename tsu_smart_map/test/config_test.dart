import 'package:flutter_test/flutter_test.dart';

import 'package:tsu_smart_map/models/app_config.dart';
import 'package:tsu_smart_map/services/config_service.dart';
import 'package:tsu_smart_map/utils/app_icons.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('โหลด config จาก asset ได้ครบตาม requirement', () async {
    final config = await ConfigService.load();

    expect(config.app.emergencyNumber, '0928733748');
    expect(config.app.formattedEmergencyNumber, '092-873-3748');
    expect(config.app.campusName, isNotEmpty);

    expect(config.map.center.lat, closeTo(7.80822, 0.00001));
    expect(config.map.center.lng, closeTo(99.93869, 0.00001));

    // requirement ข้อ 2: ต้องมีชั้นข้อมูล 4 ประเภท
    expect(config.layers.map((l) => l.id),
        containsAll(<String>['tram', 'fuel', 'scooter', 'caution']));
    expect(config.markets, isNotEmpty);

    // requirement ข้อ 5: แถบล่างมีปุ่มทางลัด 3 ปุ่ม
    expect(config.shortcuts.length, 3);
  });

  test('ทุกชื่อไอคอนใน config ต้องแปลงเป็น IconData ได้จริง', () async {
    final config = await ConfigService.load();
    final names = <String>[
      ...config.layers.map((l) => l.icon),
      ...config.shortcuts.map((s) => s.icon),
      ...config.markets.map((m) => m.icon),
    ];
    for (final name in names) {
      expect(kConfigIcons.containsKey(name), isTrue,
          reason: 'ไอคอน "$name" ยังไม่ได้ลงทะเบียนใน kConfigIcons');
    }
  });

  test('config ที่ขาดคีย์ต้องไม่ทำให้แอปพัง (ใช้ค่า default แทน)', () {
    final config = AppConfig.fromJson(<String, dynamic>{});

    expect(config.app.name, 'TSU Smart Map');
    expect(config.app.emergencyNumber, '0928733748');
    expect(config.map.zoom, 16);
    expect(config.layers, isEmpty);
    expect(config.markets, isEmpty);
  });

  test('ประมาณเวลาเดินทางจากระยะทางใน config', () async {
    final config = await ConfigService.load();
    final travel = config.map.travel;

    expect(travel.walkMinutes(4.5), 60);
    expect(travel.driveMinutes(30), 60);
    // ระยะสั้นมากต้องไม่ได้ 0 นาที
    expect(travel.walkMinutes(0.01), 1);
  });
}
