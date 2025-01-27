import 'package:flutter/material.dart';
// ignore: unused_import
import 'package:flutter_offline/flutter_offline.dart';
// ignore: depend_on_referenced_packages, unused_import
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

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}