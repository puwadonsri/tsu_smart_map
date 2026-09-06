import 'package:url_launcher/url_launcher.dart';

class NavigationService {
  static Future<bool> openGoogleMaps(double lat, double lng) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving',
    );
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}