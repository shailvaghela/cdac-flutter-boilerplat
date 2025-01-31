// ignore_for_file: unused_import, depend_on_referenced_packages

import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'package:flutter_demo/services/MasterDataService/master_data_service.dart';
import 'package:flutter_demo/utils/device_id.dart';
import 'package:flutter_demo/utils/device_utils.dart';
import 'package:flutter_demo/viewmodels/Login/login_view_model.dart';
import 'package:flutter_demo/viewmodels/Logout/logout_view_model.dart';
import 'package:flutter_demo/viewmodels/MasterData/masterdata_viewmodel.dart';
import 'package:flutter_demo/viewmodels/Register/register_view_model.dart';
import 'package:flutter_demo/viewmodels/camera_provider.dart';
import 'package:flutter_demo/viewmodels/permission_provider.dart';
import 'package:flutter_demo/viewmodels/theme_provider.dart';
import 'package:flutter_demo/viewmodels/user_provider.dart';
import 'package:flutter_demo/views/screens/BottomNavBar/bottom_navigation_home.dart';
import 'package:flutter_demo/views/screens/Splash/splash_screen.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final deviceInfo = await DeviceUtils.getDeviceInfo();
  debugPrint("deviceInfo: ${deviceInfo.toString()}");

  String? deviceId = await DeviceId.getId();
  debugPrint("deviceId: ${deviceId.toString()}");

  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize Crashlytics
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  runApp(MyApp());
  /* runApp(OfflineBuilder(
      debounceDuration: Duration.zero,
      connectivityBuilder: (
        BuildContext context,
        List<ConnectivityResult> connectivity,
        Widget child,
      ) {
        if (connectivity.contains(ConnectivityResult.none)) {
          return MaterialApp(
              debugShowCheckedModeBanner: false, home: OfflineScreen());
        }
        return child;
      },
      child: MyApp()));*/
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  final _storage = const FlutterSecureStorage(); // Secure storage instance

  bool isDarkMode = false; // Default theme mode
  @override
  void initState() {
    // TOD_initializeThemeStatus
    super.initState();
    _initializeThemeStatus();
    if (kDebugMode) {
      final masterDataService = MasterData();

      masterDataService.fetchMasterData("john_toe2", "district");
    }
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(
              create: (BuildContext context) =>
                  ThemeProvider(isDark: isDarkMode)),
          ChangeNotifierProvider(
            create: (_) => LoginViewModel(), // Register LoginViewModel here
          ),
          ChangeNotifierProvider(
            create: (_) => LogoutViewModel(), // Register LoginViewModel here
          ),
          ChangeNotifierProvider(
            create: (_) => RegisterViewModel(), // Register LoginViewModel here
          ),
          ChangeNotifierProvider(
            create: (_) => MasterDataViewModel(), // Register LoginViewModel here
          ),
          ChangeNotifierProvider(create: (_) => PermissionProvider()),
          ChangeNotifierProvider(create: (_) => CameraProvider()),
          ChangeNotifierProvider(create: (_) => UserProvider()),
        ],
        child:
            Consumer<ThemeProvider>(builder: (context, themeProvider, child) {
          return MaterialApp(
              title: 'Flutter Demo',
              debugShowCheckedModeBanner: false,
              navigatorKey: navigatorKey,
              theme: themeProvider.getTheme,
              /* theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue.shade700),
            useMaterial3: true,
            textTheme: TextTheme(
              bodyLarge: TextStyle(fontFamily: 'Montserrat'),
              bodyMedium: TextStyle(fontFamily: 'Montserrat'),
              displayLarge: TextStyle(fontFamily: 'Montserrat'),
              displayMedium: TextStyle(fontFamily: 'Montserrat'),
              // Add other text styles if needed
            ),
          ),*/
              home: SplashScreen()
             /* home: BottomNavigationHome(
                initialIndex: 0,
              )*/

              // MyHomePage(title: 'Flutter Demo Home Page'),
              );
        }));
  }

  Future<void> _initializeThemeStatus() async {
    final isDark = (await _storage.read(key: 'isDark')) == 'true';
    setState(() => isDarkMode = isDark);
  }
}
