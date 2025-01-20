import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../constants/app_colors.dart';
import '../../../constants/assest_path.dart';
import '../../../models/LoginModel/login_response.dart';
import '../../../utils/toast_util.dart';
import '../../../viewmodels/Login/login_view_model.dart';
import '../../widgets/custom_text_widget.dart';
import '../../widgets/gradient_container.dart';
import '../BottomNavBar/bottom_navigation_home.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../constants/app_colors.dart';
import '../../../constants/assest_path.dart';
import '../../../models/LoginModel/login_response.dart';
import '../../../utils/toast_util.dart';
import '../../../viewmodels/Login/login_view_model.dart';
import '../../widgets/custom_text_widget.dart';
import '../BottomNavBar/bottom_navigation_home.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    final loginViewModel = context.watch<LoginViewModel>();
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          // Gradient Background
          GradientContainer(),

          // Glassmorphic Card for Login
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(4, 4),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // App logo
                    Image.asset(
                      ImageRasterPath.loginPic,
                      height: screenHeight * 0.2,
                    ),
                    const SizedBox(height: 20),

                    // Username TextField
                    _buildGlassTextField(
                      controller: _usernameController,
                      hintText: "Username",
                      icon: Icons.person,
                    ),

                    const SizedBox(height: 20),

                    // Password TextField
                    _buildGlassTextField(
                      controller: _passwordController,
                      hintText: "Password",
                      icon: Icons.lock,
                      isPassword: true,
                      isPasswordVisible: _isPasswordVisible,
                      togglePasswordVisibility: _togglePasswordVisibility,
                    ),

                    const SizedBox(height: 10),

                    // Forgot Password
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {},
                        child: CustomTextWidget(
                          text: 'Forgot Password?',
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Login Button
                    loginViewModel.isLoading
                        ? Center(
                            child: CircularProgressIndicator(
                              color: Colors.white70,
                            ),
                          )
                        : ElevatedButton(
                            onPressed: () {
                              if (_usernameController.text.isEmpty) {
                                ToastUtil().showToast(
                                  context,
                                  'Enter Username',
                                  Icons.person,
                                  AppColors.toastBgColorRed,
                                );
                              } else if (_passwordController.text.isEmpty) {
                                ToastUtil().showToast(
                                  context,
                                  'Enter Password',
                                  Icons.lock,
                                  AppColors.toastBgColorRed,
                                );
                              } else {
                                _handleLogin(context);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white.withOpacity(0.3),
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: CustomTextWidget(
                              text: 'Login',
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                    const SizedBox(height: 20),

                    // New User Link
                    Align(
                      alignment: Alignment.center,
                      child: TextButton(
                        onPressed: () {},
                        child: CustomTextWidget(
                          text: 'New User? Register Here',
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool isPassword = false,
    bool? isPasswordVisible,
    VoidCallback? togglePasswordVisibility,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword ? !(isPasswordVisible ?? true) : false,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white70),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  isPasswordVisible! ? Icons.visibility : Icons.visibility_off,
                  color: Colors.white70,
                ),
                onPressed: togglePasswordVisibility,
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  // Handle login action
  Future<void> _handleLogin(BuildContext context) async {
    final loginViewModel = context.read<LoginViewModel>();

    String username = _usernameController.text.trim();
    String password = _passwordController.text.trim();

    LoginResponse? response =
        await loginViewModel.performLogin(username, password);

    if (response != null) {
      // Show success toast
      ToastUtil().showToast(
        context,
        'Welcome, ${response.username}!',
        Icons.check_circle_outline,
        AppColors.toastBgColorGreen,
      );
      // Navigate to the home screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => BottomNavigationHome(initialIndex: 0)),
      );
    } else {
      // Show error toast
      ToastUtil().showToast(
        context,
        loginViewModel.errorMessage ?? 'An error occurred',
        Icons.error_outline,
        AppColors.toastBgColorRed,
      );
    }
  }
}
