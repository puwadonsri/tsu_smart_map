import 'package:url_launcher/url_launcher.dart';

class NavigationService {
  /// เปิดเส้นทางใน Google Maps จากตำแหน่งผู้ใช้ไปยังพิกัดปลายทาง
  /// ใช้ URL แบบสาธารณะ ไม่ต้องใช้ API key
  static Uri directionsUri(double lat, double lng, {String travelMode = 'driving'}) {
    return Uri.parse(
      'https://www.google.com/maps/dir/?api=1'
      '&destination=$lat,$lng&travelmode=$travelMode',
    );
  }

  static Future<bool> openGoogleMaps(
    double lat,
    double lng, {
    String travelMode = 'driving',
  }) async {
    try {
      return await launchUrl(
        directionsUri(lat, lng, travelMode: travelMode),
        mode: LaunchMode.externalApplication,
      );
    } catch (_) {
      return false;
    }
  }

  /// โทรออก — บนมือถือต้องใช้ externalApplication ไม่งั้น dialer อาจไม่เปิด
  static Future<bool> call(String number) async {
    try {
      return await launchUrl(
        Uri(scheme: 'tel', path: number),
        mode: LaunchMode.externalApplication,
      );
    } catch (_) {
      return false;
    }
  }
}
