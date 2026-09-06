import 'package:flutter_test/flutter_test.dart';

import 'package:tsu_smart_map/services/config_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Config service loads app config from asset', () async {
    final config = await ConfigService.load();
    expect(config.app.emergencyNumber, '0928733748');
    expect(config.app.campusName, isNotEmpty);
    expect(config.map.center.lat, isNotNull);
    expect(config.layers, isNotEmpty);
    expect(config.markets, isNotEmpty);
  });
}