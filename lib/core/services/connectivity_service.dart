import 'package:connectivity_plus/connectivity_plus.dart';

abstract interface class ConnectivityService {
  Future<bool> isOnline();

  Stream<bool> get onStatusChanged;
}

class ConnectivityPlusService implements ConnectivityService {
  final Connectivity _connectivity;

  ConnectivityPlusService([Connectivity? connectivity]) : _connectivity = connectivity ?? Connectivity();

  @override
  Future<bool> isOnline() async => _hasConnection(await _connectivity.checkConnectivity());

  @override
  Stream<bool> get onStatusChanged => _connectivity.onConnectivityChanged.map(_hasConnection).distinct();

  static bool _hasConnection(List<ConnectivityResult> results) =>
      results.any((result) => result != ConnectivityResult.none);
}
