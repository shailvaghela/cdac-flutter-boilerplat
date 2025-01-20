
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_demo/viewmodels/Login/login_view_model.dart';
import 'package:flutter_demo/viewmodels/camera_provider.dart';
import 'package:flutter_demo/viewmodels/permission_provider.dart';
import 'package:flutter_demo/views/screens/Offline/offline_screen.dart';
import 'package:flutter_demo/views/screens/Splash/splash_screen.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(OfflineBuilder(
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
      child: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => LoginViewModel(), // Register LoginViewModel here
        ),
        ChangeNotifierProvider(create: (_) => PermissionProvider()),
        ChangeNotifierProvider(create: (_) => CameraProvider()),
      ],
      child: MaterialApp(
          title: 'Flutter Demo',
          debugShowCheckedModeBanner: false,
          navigatorKey: navigatorKey,
          // Set the navigatorKey here
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue.shade700),
            useMaterial3: true,
            textTheme: TextTheme(
              bodyLarge: TextStyle(fontFamily: 'Montserrat'),
              bodyMedium: TextStyle(fontFamily: 'Montserrat'),
              displayLarge: TextStyle(fontFamily: 'Montserrat'),
              displayMedium: TextStyle(fontFamily: 'Montserrat'),
              // Add other text styles if needed
            ),
          ),
          home: SplashScreen()

          // MyHomePage(title: 'Flutter Demo Home Page'),
          ),
    );
  }
}
