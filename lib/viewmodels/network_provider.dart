import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

enum ConnectivityStatus { online, offline }

class NetworkProviderController with ChangeNotifier {
  ConnectivityStatus _status = ConnectivityStatus.online;

  ConnectivityStatus get status => _status;

  NetworkProviderController() {
    _initConnectivityListener();
    _checkConnectivityOnInit(); // Correct method called
  }

  void _initConnectivityListener() {
    Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      debugPrint("Connectivity Results: $results");

      if (results.isEmpty || results.contains(ConnectivityResult.none)) {
        _updateStatus(ConnectivityStatus.offline);
        debugPrint("Internet Disconnected");
      } else {
        _updateStatus(ConnectivityStatus.online);
        debugPrint("Internet Connected");
      }
    });
  }

  void _checkConnectivityOnInit() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      _updateStatus(ConnectivityStatus.offline);
      debugPrint("Internet Disconnected");
    } else {
      _updateStatus(ConnectivityStatus.online);
      debugPrint("Internet Connected");
    }
  }

  void _updateStatus(ConnectivityStatus newStatus) {
    if (_status != newStatus) {
      _status = newStatus;
      notifyListeners();
    }
  }
  /// Public method to trigger a manual connectivity check
  void checkConnectivity() {
    _checkConnectivityOnInit();
  }

}
