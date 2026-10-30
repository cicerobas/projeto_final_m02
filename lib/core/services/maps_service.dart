import 'package:url_launcher/url_launcher.dart';

abstract interface class MapsService {
  Future<bool> openRoute({required double latitude, required double longitude});
}

class UrlLauncherMapsService implements MapsService {
  const UrlLauncherMapsService();

  @override
  Future<bool> openRoute({required double latitude, required double longitude}) async {
    final Uri uri = Uri.https('www.google.com', '/maps/dir/', {
      'api': '1',
      'destination': '$latitude,$longitude',
      'travelmode': 'driving',
    });

    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }
}
