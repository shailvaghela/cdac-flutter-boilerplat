import 'dart:io';

// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_demo/services/LocalStorageService/local_storage.dart';
import 'package:flutter_demo/utils/device_id.dart';
import 'package:flutter_demo/utils/device_utils.dart';
import 'package:flutter_demo/utils/language_change_controller.dart';
import 'package:flutter_demo/viewmodels/Login/login_view_model.dart';
import 'package:flutter_demo/viewmodels/Logout/logout_view_model.dart';
import 'package:flutter_demo/viewmodels/MasterData/masterdata_viewmodel.dart';
import 'package:flutter_demo/viewmodels/Register/register_view_model.dart';
import 'package:flutter_demo/viewmodels/camera_provider.dart';
import 'package:flutter_demo/viewmodels/permission_provider.dart';
import 'package:flutter_demo/viewmodels/theme_provider.dart';
import 'package:flutter_demo/viewmodels/user_provider.dart';
import 'package:flutter_demo/views/screens/Login/login_screen.dart';
import 'package:flutter_demo/views/screens/Settings/settings_screen.dart';
import 'package:flutter_demo/views/screens/Splash/splash_screen.dart';
import 'package:flutter_demo/views/screens/home/home_screen.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  LocalStorage localStorage = LocalStorage();
  final String? language = await localStorage.getLanguage();

  runApp( MyApp(local: language));
}

class MyApp extends StatefulWidget {
  final String? local;
  const MyApp({super.key, required this.local});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  final _storage = const FlutterSecureStorage(); // Secure storage instance

  bool isDarkMode = false; // Default theme mode
  String? currentLanguage;

  // Declare variables for DeviceInfo and Firebase initialization
  String? deviceId;
  String? deviceInfo;

  @override
  void initState() {
    super.initState();
    _initializeThemeStatus();
    _initializeApp();
  }

  // Initialize Firebase and DeviceInfo asynchronously
  Future<void> _initializeApp() async {

    // if(Platform.isAndroid){
    //   await Firebase.initializeApp();

    //   // Initialize Crashlytics
    //   FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

    //   // Get Device Info and Device ID
    //   deviceInfo = await DeviceUtils.getDeviceInfo();
    //   deviceId = await DeviceId.getId();
    //   debugPrint("deviceInfo: $deviceInfo");
    //   debugPrint("deviceId: $deviceId");

    // }

    // Get initial language setting from local storage
    final localStorage = LocalStorage();
    String? language = await localStorage.getLanguage();
    setState(() {
      currentLanguage = language ?? 'en'; // Default to 'en' if no language is set
    });

    // Set language to the app
    if (currentLanguage != null) {
      Provider.of<LanguageChangeController>(context, listen: false)
          .changeLanguage(Locale(currentLanguage!));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check if the app is on mobile or web inside the build method
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (BuildContext context) => ThemeProvider(isDark: isDarkMode),
        ),
        ChangeNotifierProvider(
          create: (_) => LoginViewModel(), // Register LoginViewModel here
        ),
        ChangeNotifierProvider(
          create: (_) => LogoutViewModel(), // Register LogoutViewModel here
        ),
        ChangeNotifierProvider(
          create: (_) => RegisterViewModel(), // Register RegisterViewModel here
        ),
        ChangeNotifierProvider(
          create: (_) => MasterDataViewModel(), // Register MasterDataViewModel here
        ),
        ChangeNotifierProvider(create: (_) => LanguageChangeController()),
        ChangeNotifierProvider(create: (_) => PermissionProvider()),
        ChangeNotifierProvider(create: (_) => CameraProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: Consumer2<ThemeProvider, LanguageChangeController>(
        builder: (context, themeProvider, languageProvider, child) {

          return MaterialApp(
            title: 'Flutter Demo',
            debugShowCheckedModeBanner: false,
            navigatorKey: navigatorKey,
            theme: themeProvider.getTheme,
            // locale: languageProvider.appLocale ?? Locale(widget.local),
            locale: languageProvider.appLocale ?? (widget.local != null ? Locale(widget.local!) : Locale('en', 'US')),

            supportedLocales: [
              Locale('en'), // English
              Locale('hi'), // Hindi
            ],
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: SplashScreen(),  // Replace with your main screen
          );
        },
      ),
    );
  }

  Future<void> _initializeThemeStatus() async {
    final isDark = (await _storage.read(key: 'isDark')) == 'true';
    setState(() => isDarkMode = isDark);
  }
}
