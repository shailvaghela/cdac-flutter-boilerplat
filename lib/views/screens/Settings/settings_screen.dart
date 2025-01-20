import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';
import '../../widgets/app_bar.dart';
import '../../widgets/custom_text_widget.dart';
import '../home/profile_photo_widget.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: AppColors.greyHundred,
      appBar: MyAppBar.buildAppBar('Settings', false),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Section
            _buildProfileSection(context),

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
                    value: true, // Example value
                    onChanged: (bool value) {
                      // Toggle dark mode logic
                    },
                  ),
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
                  onTap: () {
                    // Logout logic
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
      ),
     /* body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(4.0),
              decoration: BoxDecoration(
                color: AppColors.greyHundred,
                borderRadius: BorderRadius.circular(12),
              ),
            child: Row(spacing: 8.0,
              mainAxisAlignment:MainAxisAlignment.spaceBetween ,
              children: [
                ProfilePhotoWidget(onTap: () {  },),
                Column(
                  mainAxisSize: MainAxisSize.min,
                 crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomTextWidget(
                      text: 'emilys',
                      fontWeight: FontWeight.bold,
                      fontSize: 21,
                    ),
                    CustomTextWidget(
                      text: '9965824365',
                    ),
                  ],
                ),
                IconButton(onPressed: () {
                  
                }, icon: Icon(Icons.arrow_forward_ios))
              ],
            ),
          ),
          ],
        ),
      ),*/

    );
  }
  // Profile Section
  Widget _buildProfileSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundImage: NetworkImage(
              'https://placehold.co/150x150/png', // Replace with profile image URL
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'John Doe', // Replace with user name
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'john.doe@example.com', // Replace with user email
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios,
            size: 20,
            color: Colors.grey,
          ),
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
}
