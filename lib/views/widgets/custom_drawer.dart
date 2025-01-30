import 'dart:developer';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/Login/login_view_model.dart';
import '../../constants/app_colors.dart';
import '../../models/LogoutModel/logout_response.dart';
import '../../services/LocalStorageService/local_storage.dart';
import '../../utils/toast_util.dart';
import '../../viewmodels/Logout/logout_view_model.dart';
import '../screens/GeoTagWithPicture/geotag_with_picture.dart';
import '../screens/GeoTagWithPicture/picture_with_geotag_list.dart';
import '../screens/Login/login_screen.dart';
import 'custom_text_widget.dart';

class CustomDrawer extends StatefulWidget {
  // ignore: use_super_parameters
  const CustomDrawer({Key? key}) : super(key: key);

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  final LocalStorage _localStorage = LocalStorage();
  String? _username; // Variable to hold the username

  @override
  void initState() {
    super.initState();
    _fetchUserName(); // Fetch username on initialization
  }

  Future<void> _fetchUserName() async {
    String? username = await _localStorage.getUserName(); // Fetch username
    setState(() {
      _username = username ?? 'Guest'; // Set default value to "Guest" if null
    });
  }

  @override
  Widget build(BuildContext context) {
    final loginViewModel = context.watch<LoginViewModel>();
    return Drawer(
      child: Column(
        children: [
          // Drawer Header
          DrawerHeader(
            decoration: BoxDecoration(
              color:
                  Colors.blue.shade700.withAlpha((0.8*255).toInt()), // Match primary color
            ),
            child: Center(
              child: Text(
                "Welcome, $_username",
                // 'My App',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Other Drawer Items
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Home'),
            onTap: () {
              Navigator.of(context).pop(); // Close the drawer
              // Navigate to Home
            },
          ),
          ListTile(
            leading: Icon(Icons.picture_in_picture_rounded),
            title: Text('CaptureGeoTagPicture'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => GeoTagWithPicture()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.data_array),
            title: Text('GeoTagWithPicture '),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => GeoTagWithPictureList()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Settings'),
            onTap: () {
              Navigator.of(context).pop(); // Close the drawer
              // Navigate to Settings
            },
          ),

          Spacer(), // Push Logout to the bottom of the drawer

          // Logout Button
          ListTile(
            leading: Icon(Icons.logout, color: Colors.red),
            title: /*Text(
              'Logout',
              style: TextStyle(color: Colors.red),
            ),*/
                CustomTextWidget(
              text: 'Logout',
              fontWeight: FontWeight.bold,
              color: Colors
                  .red, // This will now correctly set the text color to red
            ),
            onTap: () async {

              _handleLogout(context);
            },
          ),


          ListTile(
            leading: Icon(Icons.crisis_alert, color: Colors.red),
            title: /*Text(
              'Logout',
              style: TextStyle(color: Colors.red),
            ),*/
            CustomTextWidget(
              text: 'Crash Logs',
              fontWeight: FontWeight.bold,
              color: Colors
                  .red, // This will now correctly set the text color to red
            ),
            onTap: () async {
              // await loginViewModel.logout(); // Perform logout logic
              FirebaseCrashlytics.instance.crash();


              Navigator.pushReplacement(
                // ignore: use_build_context_synchronously
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );

            },
          ),
        ],
      ),
    );
  }

  // Handle logout action
  Future<void> _handleLogout(BuildContext context) async {
    final logoutViewModel = context.read<LogoutViewModel>();

    String logoutOperationResultMessage = await logoutViewModel.performLogout("");

    if(kDebugMode){
      log("Inside login screen");
      log(logoutOperationResultMessage);
    }

    if (!logoutOperationResultMessage.toLowerCase().contains("success")) {
      ToastUtil().showToast(
        // ignore: use_build_context_synchronously
        context,
        logoutOperationResultMessage,
        Icons.error_outline,
        AppColors.toastBgColorRed,
      );
      return;
    }

    ToastUtil().showToast(
      // ignore: use_build_context_synchronously
      context,
      'Successfully logout',
      Icons.check_circle_outline,
      AppColors.toastBgColorGreen,
    );
    // Navigate to the home screen
    Navigator.pushReplacement(
      // ignore: use_build_context_synchronously
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

}
