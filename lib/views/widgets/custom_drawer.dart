import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/Login/login_view_model.dart';
import '../../services/LocalStorageService/local_storage.dart';
import '../screens/Login/login_screen.dart';
import 'custom_text_widget.dart';

class CustomDrawer extends StatefulWidget {
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
                  Colors.blue.shade700.withOpacity(0.9), // Match primary color
            ),
            child: Center(
              child: Text(
                "Welcome, $_username" ?? 'Loading...',
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
              await loginViewModel.logout(); // Perform logout logic
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}
