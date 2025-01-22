import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';

import '../../../constants/app_colors.dart';
import '../../../constants/app_theme.dart';
import '../../../services/LocalStorageService/local_storage.dart';
import '../../../utils/toast_util.dart';
import '../../../viewmodels/Login/login_view_model.dart';
import '../../../viewmodels/theme_provider.dart';
import '../../../viewmodels/user_provider.dart';
import '../../widgets/app_bar.dart';
import '../../widgets/custom_text_widget.dart';
import '../Login/login_screen.dart';
import '../home/profile_photo_widget.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final LocalStorage _localStorage = LocalStorage();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserProfile();
  }

  @override
  Widget build(BuildContext context) {
    ThemeProvider themeProvider =
        Provider.of<ThemeProvider>(context, listen: false);
    return Scaffold(
        //backgroundColor: AppColors.greyHundred,
        appBar: MyAppBar.buildAppBar('Settings', false),
        body: Center(
            child: Consumer<UserProvider>(builder: (context, userProvider, _) {
          if (userProvider.isLoading) {
            return const CircularProgressIndicator();
          }
          if (userProvider.errorMessage != null) {
            return Text(
              userProvider.errorMessage!,
              style: const TextStyle(color: Colors.red),
            );
          }
          if (userProvider.userData != null) {
            final user = userProvider.userData!;
            return SingleChildScrollView(
              child: Column(
                children: [
                  // Profile Section
                  _buildProfileSection(
                      context, user['firstName'], user['email'], user),

                  const Divider(),

                  // General Settings Section
                  _buildSettingsGroup(
                    context,
                    title: "General Settings",
                    settings: [
                      _buildSettingItem(
                        context,
                        icon: Icons.settings,
                        title: "General",
                        onTap: () {},
                      ),
                      _buildSettingItem(
                        context,
                        icon: Icons.lock,
                        title: "Privacy & Security",
                        onTap: () {},
                      ),
                      _buildSettingItem(
                        context,
                        icon: Icons.language,
                        title: "Language",
                        onTap: () {},
                      ),
                    ],
                  ),

                  const Divider(),

                  // Display & Theme Section
                  _buildSettingsGroup(
                    context,
                    title: "Display & Theme",
                    settings: [
                      _buildSettingItem(
                        context,
                        icon: Icons.dark_mode,
                        title: "Dark Mode",
                        trailing: Switch(
                            value: themeProvider.getTheme == darkTheme,
                            activeColor: themeProvider.getTheme == darkTheme
                                ? Colors.white
                                : Colors.black,
                            onChanged: (d) {
                              themeProvider.changeTheme();
                            }),
                      ),
                    ],
                  ),

                  const Divider(),

                  // Account Section
                  _buildSettingsGroup(
                    context,
                    title: "Account",
                    settings: [
                      _buildSettingItem(
                        context,
                        icon: Icons.logout,
                        title: "Logout",
                        onTap: () async {
                          // Logout logic
                          final loginViewModel = Provider.of<LoginViewModel>(
                              context,
                              listen: false);

                          await loginViewModel.logout(); // Perform logout logic
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const LoginScreen()),
                          );
                          ToastUtil().showToast(
                            context,
                            'Logout Successfully.!',
                            Icons.logout,
                            AppColors.toastBgColorGreen,
                          );
                        },
                      ),
                      _buildSettingItem(
                        context,
                        icon: Icons.delete,
                        title: "Delete Account",
                        onTap: () {
                          // Delete account logic
                        },
                      ),
                      _buildSettingItem(
                        context,
                        icon: Icons.lock_reset,
                        title: "Change Password",
                        onTap: () {},
                      ),
                    ],
                  ),

                  const Divider(),

                  // Feedback Section
                  _buildSettingsGroup(
                    context,
                    title: "Feedback",
                    settings: [
                      _buildSettingItem(
                        context,
                        icon: Icons.feedback,
                        title: "Send Feedback",
                        onTap: () {},
                      ),
                      _buildSettingItem(
                        context,
                        icon: Icons.info,
                        title: "About",
                        onTap: () {},
                      ),
                    ],
                  ),
                ],
              ),
            );
          }
          return const Text('No user data available.');
        })));
  }

  // Profile Section
  Widget _buildProfileSection(
      BuildContext context, String name, email, Map<String, dynamic> userData) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            /* backgroundImage: NetworkImage(
              'https://placehold.co/150x150/png', // Replace with profile image URL
            ),*/
            child: ClipOval(
                child: Image.asset('assets/images/default_profile.png')),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name, // Replace with user name
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  email.toString(), // Replace with user email
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => showUserDetails(context, userData),
            icon: const Icon(
              Icons.arrow_forward_ios,
              size: 20,
              color: Colors.grey,
            ),
          )
        ],
      ),
    );
  }

  // Group of Settings
  Widget _buildSettingsGroup(BuildContext context,
      {required String title, required List<Widget> settings}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Column(children: settings),
        ],
      ),
    );
  }

  // Individual Setting Item
  Widget _buildSettingItem(BuildContext context,
      {required IconData icon,
      required String title,
      Widget? trailing,
      VoidCallback? onTap}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 0),
      leading: Icon(icon, color: Colors.blue),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: trailing ??
          const Icon(
            Icons.arrow_forward_ios,
            size: 18,
            color: Colors.grey,
          ),
      onTap: onTap,
    );
  }

  Future<void> getUserProfile() async {
    String? accessToken = await _localStorage.getAccessToken();

// Fetch user data when the widget initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<UserProvider>()
          .fetchAuthenticatedUser(accessToken!, context);
    });
  }

  void showUserDetails(BuildContext context, Map<String, dynamic> userData) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /* // Profile Picture
              CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(userData['image']),
                backgroundColor: Colors.grey[200],
              ),
              const SizedBox(height: 16),*/
              // Name
              Text(
                '${userData['firstName']} ${userData['lastName']}',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              // Maiden Name
              Text(
                'Maiden Name: ${userData['maidenName']}',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 16),
              // Additional Details
              Row(
                // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                spacing: 8.0,
                children: [
                  Text(
                    'Age:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    '${userData['age']}',
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                spacing: 8.0,
                children: [
                  Text(
                    'Gender:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    '${userData['gender']}',
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Email
              Row(
                children: [
                  const Icon(Icons.email, color: Colors.blue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      userData['email'],
                      style: const TextStyle(fontSize: 16),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Close Button
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the bottom sheet
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      },
    );
  }
}
