import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_demo/utils/language_change_controller.dart';
import 'package:flutter_demo/views/screens/Settings/contact_screen.dart';
import 'package:provider/provider.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_theme.dart';
import '../../../services/DatabaseHelper/database_helper_web.dart';
import '../../../services/LocalStorageService/local_storage.dart';
import '../../../utils/toast_util.dart';
import '../../../viewmodels/Logout/logout_view_model.dart';
import '../../../viewmodels/theme_provider.dart';
import '../../../viewmodels/user_provider.dart';
import '../../widgets/app_bar.dart';
// import '../../widgets/custom_help_dialog.dart';
import '../../widgets/custom_text_icon_button.dart';
import '../Login/login_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final LocalStorage _localStorage = LocalStorage();

  @override
  void initState() {
    super.initState();
    getUserProfile();
    _initializeDatabase();
  }

  // Initialize the database on the first screen or in the app
  Future<void> _initializeDatabase() async {
    await DbHelper().init();
  }

  Map<String, dynamic> userData = {
    'firstName': 'John Doe',
    'lastName': 'johndoe@example.com',
    'maidenName': 'John Doe',
    'age': 'John Doe',
    'gender': 'John Doe',
    'email': 'John Doe',
  };

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    bool isWeb = kIsWeb || screenWidth > 600;

    ThemeProvider themeProvider =
        Provider.of<ThemeProvider>(context, listen: false);
    return Scaffold(
      //backgroundColor: AppColors.greyHundred,
      appBar:
          MyAppBar.buildAppBar(AppLocalizations.of(context)!.settings, false),
      // appBar: MyAppBar.buildAppBar(AppLocalizations.of(context)!.settings, false),
      body: Center(
          child: Container(
              width: isWeb
                  ? screenWidth * 0.3
                  : screenWidth * 1, // Adjust width for web vs mobile
              child:
                  Consumer<UserProvider>(builder: (context, userProvider, _) {
                /* if (userProvider.isLoading) {
            return const CircularProgressIndicator();
          }
          if (userProvider.errorMessage != null) {
            return Text(
              userProvider.errorMessage!,
              style: const TextStyle(color: Colors.red),
            );
          }
          if (userProvider.userData != null) {
            final user = userProvider.userData!;*/
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      // Profile Section
                      _buildProfileSection(
                          context,
                          AppLocalizations.of(context)!.name,
                          "sanskars@cdac.om",
                          userData),

                      const Divider(),

                      // General Settings Section
                      _buildSettingsGroup(
                        context,
                        title: AppLocalizations.of(context)!.general_settings,
                        settings: [
                          _buildSettingItem(
                            context,
                            icon: Icons.settings,
                            title: AppLocalizations.of(context)!.general,
                            onTap: () {},
                          ),
                          _buildSettingItem(
                            context,
                            icon: Icons.lock,
                            title:
                                AppLocalizations.of(context)!.privacy_Security,
                            onTap: () {},
                          ),
                          _buildSettingItem(
                            context,
                            icon: Icons.language,
                            title: AppLocalizations.of(context)!.language,
                            onTap: () {
                              _showLanguageSelectionDialog();
                            },
                          ),
                          _buildSettingItem(
                            context,
                            icon: Icons.share,
                            title: AppLocalizations.of(context)!.share_app,
                            onTap: () {
                              /* String appLink = "https://example.com";
                          Share.share('check out my app: $appLink', subject: 'Look what I made!');*/
                              /* String appLink = "https://play.google.com/store/apps/details?id=com.yourcompany.yourapp";

                          // Share the app link
                          Share.share("Check out this awesome app: $appLink");*/
                            },
                          ),
                        ],
                      ),

                      const Divider(),

                      // Display & Theme Section
                      _buildSettingsGroup(
                        context,
                        title: AppLocalizations.of(context)!.display_theme,
                        settings: [
                          _buildSettingItem(
                            context,
                            icon: Icons.dark_mode,
                            title: AppLocalizations.of(context)!.dark_mode,
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
                        title: AppLocalizations.of(context)!.account,
                        settings: [
                          _buildSettingItem(
                            context,
                            icon: Icons.logout,
                            title: AppLocalizations.of(context)!.logout,
                            onTap: () async {
                              // _handleLogout(context);
                              await _localStorage.setLoggingState('false');

                              Navigator.pushReplacement(
                                // ignore: use_build_context_synchronously
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const LoginScreen()),
                              );
                            },
                          ),
                          _buildSettingItem(
                            context,
                            icon: Icons.delete,
                            title: AppLocalizations.of(context)!.delete_account,
                            onTap: () {
                              // Delete account logic
                            },
                          ),
                          _buildSettingItem(
                            context,
                            icon: Icons.lock_reset,
                            title:
                                AppLocalizations.of(context)!.change_password,
                            onTap: () {},
                          ),
                        ],
                      ),

                      const Divider(),

                      // Feedback Section
                      _buildSettingsGroup(
                        context,
                        title: AppLocalizations.of(context)!.feedback,
                        settings: [
                          _buildSettingItem(
                            context,
                            icon: Icons.feedback,
                            title: AppLocalizations.of(context)!.send_feedback,
                            onTap: () {},
                          ),
                          _buildSettingItem(
                            context,
                            icon: Icons.contact_phone,
                            title: AppLocalizations.of(context)!.contact_us,
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const ContactScreen()));
                            },
                          ),
                          _buildSettingItem(
                            context,
                            icon: Icons.info,
                            title: AppLocalizations.of(context)!.about,
                            onTap: () {},
                          ),
                        ],
                      ),
                    ],
                  ),
                );
                //}
              }))),
    );
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
                  AppLocalizations.of(context)!.name, // Replace with user name
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "sanskars@cdac.in".toString(), // Replace with user email
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
    String? accessToken;
    if (kIsWeb) {
      accessToken = await _localStorage.getAccessTokenWeb();
    } else {
      accessToken = await _localStorage.getAccessToken();
    }

    if (!(accessToken.toString().trim().isEmpty)) {
// Fetch user data when the widget initializes
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context
            .read<UserProvider>()
            .fetchAuthenticatedUser(accessToken!, context);
      });
    }
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

  // ignore: unused_element
  Future<void> _handleLogout(BuildContext context) async {
    final logoutViewModel = context.read<LogoutViewModel>();

    String logoutOperationResultMessage =
        await logoutViewModel.performLogout("");

    if (kDebugMode) {
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

  Future<void> _showLanguageSelectionDialog() async {
    await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(title: const Text('Choose Language'), actions: [
            Consumer<LanguageChangeController>(
                builder: (context, provider, child) {
              return Container(
                  child: Row(
                children: [
                  CustomTextIconButton(
                    icon: Icons.language,
                    label: 'English',
                    onPressed: () {
                      provider.changeLanguage(Locale('en'));
                      notifyToSScreens('en');
                      Navigator.pop(context); // Close the dialog
                    },
                    backgroundColor: Colors.blue[50],
                    textColor: Colors.blue,
                    iconColor: Colors.blue,
                  ),
                  Spacer(),
                  CustomTextIconButton(
                    icon: Icons.temple_hindu,
                    label: 'Hindi',
                    onPressed: () {
                      provider.changeLanguage(Locale('hi'));
                      notifyToSScreens('hi');
                      Navigator.pop(context); // Close the dialog
                    },
                    backgroundColor: Colors.blue[50],
                    textColor: Colors.blue,
                    iconColor: Colors.blue,
                  )
                ],
              ));
            })
          ]);
        });
  }

  void notifyToSScreens(String s) {
    Provider.of<LanguageChangeController>(context, listen: false)
        .changeLanguage(Locale(s));
  }
}
