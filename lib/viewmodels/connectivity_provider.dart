import 'package:flutter/material.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'dart:async';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class ConnectivityProvider with ChangeNotifier {
  bool _isConnected = true;
  late StreamSubscription _subscription;

  ConnectivityProvider() {
    _subscription = InternetConnectionChecker.instance.onStatusChange.listen((status) {
      _isConnected = status == InternetConnectionStatus.connected;
      notifyListeners();
    });
  }

  bool get isConnected => _isConnected;

  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}