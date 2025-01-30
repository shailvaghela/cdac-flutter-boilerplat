// ignore_for_file: unused_local_variable

import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_demo/viewmodels/Register/register_view_model.dart';
import 'package:flutter_demo/views/screens/Login/login_screen.dart';
import 'package:flutter_demo/views/widgets/custom_text_field_register.dart';
import 'package:provider/provider.dart';

import '../../../constants/app_colors.dart';
import '../../../constants/app_strings.dart';
import '../../../services/AuthService/auth_service.dart';
import '../../../utils/toast_util.dart';
// import '../../widgets/custom_help_text.dart';
import '../../widgets/custom_password_widget.dart';
import '../../widgets/custom_text_widget.dart';
import '../../widgets/gradient_container.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _mobileNoController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  bool _isPasswordVisible = false;
  AuthService authService = AuthService();

  @override
  Widget build(BuildContext context) {

    final registerViewModel = context.watch<RegisterViewModel>();

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      resizeToAvoidBottomInset: true, // Ensures UI adjusts with the keyboard
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
                color: Colors.white
                    .withAlpha((0.1 * 255).toInt()), // Adjusting opacity
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white
                      .withAlpha((0.3 * 255).toInt()), // Adjusting opacity
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black
                        .withAlpha((0.2 * 255).toInt()), // Adjusting opacity
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
                    const SizedBox(height: 20),
                    Center(
                      child: Text(
                        'Sign up',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 24, // Increased font size for prominence
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    CustomTextFieldRegister(
                      label: 'Enter First Name',
                      controller: _firstNameController,
                      keyboardType: TextInputType.name,
                      maxLength: 12,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your first name';
                        }
                        if (!RegExp(AppStrings.namePattern).hasMatch(value)) {
                          return 'Enter a valid first name (letters, spaces, \'- allowed)';
                        }
                        return null;
                      },
                      isRequired: true,
                    ),

                    CustomTextFieldRegister(
                      label: 'Enter Last Name',
                      controller: _lastNameController,
                      keyboardType: TextInputType.name,
                      maxLength: 15,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your last name';
                        }
                        if (!RegExp(AppStrings.namePattern).hasMatch(value)) {
                          return 'Enter a valid last name (letters, spaces, \'- allowed)';
                        }
                        return null;
                      },
                      isRequired: true,
                    ),

                    CustomTextFieldRegister(
                      label: 'Enter Contact Number',
                      controller: _mobileNoController,
                      keyboardType: TextInputType.number,
                      maxLength: 10,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your contact number';
                        }
                        // Validate the contact number format (10 to 15 digits)
                        if (!RegExp(r'^[0-9]{10,15}$').hasMatch(value)) {
                          return 'Please enter a valid contact number';
                        }
                        // Ensure the number does not contain the same digit repeated 10 times
                        if (!RegExp(r'^(?!([0-9])\1+$)[0-9]{10}$').hasMatch(value)) {
                          return 'Enter a valid contact number';
                        }
                        return null; // Valid contact number
                      },
                      isRequired: true,
                      isNumberWithPrefix: true,
                    ),

                    CustomTextFieldRegister(
                      label: 'Enter Email',
                      controller: _emailController,
                      keyboardType: TextInputType.number,
                      maxLength: 10,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your email';
                        }
                        return null; // Valid contact number
                      },
                      isRequired: true,
                    ),

                    // Username TextField
                    CustomTextFieldRegister(
                      label: 'Enter Username',
                      controller: _usernameController,
                      keyboardType: TextInputType.name,
                      maxLength: 20,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your username';
                        }
                        return null; // Valid contact number
                      },
                      isRequired: true,
                    ),

                    // Password TextField
                    customPasswordWidget(
                      textEditController: _passwordController,
                      hintText: "Password",
                      isPassword: true,
                      isPasswordVisible: _isPasswordVisible,
                      togglePasswordVisibility: _togglePasswordVisibility,
                      showPrefixIcon: false
                    ),

                    const SizedBox(height: 5),
                    // CustomHelpTextWidget(
                    //   text: "Your password must contain:",
                    //   color: Colors.white,
                    //   fontSize: 13.0,
                    // ),
                    // CustomHelpTextWidget(
                    //   text: "- At least 8 characters",
                    //   color: Colors.white,
                    //   fontSize: 13.0,
                    // ),
                    // CustomHelpTextWidget(
                    //   text: "- At least 2 special character",
                    //   color: Colors.white,
                    //   fontSize: 13.0,
                    // ),
                    // CustomHelpTextWidget(
                    //   text: "- At least 2 special character",
                    //   color: Colors.white,
                    //   fontSize: 13.0,
                    // ),
                    // CustomHelpTextWidget(
                    //   text: "- At least 2 digit character",
                    //   color: Colors.white,
                    //   fontSize: 13.0,
                    // ),

                    const SizedBox(height: 20),

                    registerViewModel.isLoading
                        ? Center(
                      child: CircularProgressIndicator(
                        color: Colors.white70,
                      ),
                    )
                        : ElevatedButton(
                      onPressed: () {
                        if (_usernameController.text.isEmpty) {
                          ToastUtil().showToastKeyBoard(
                            context: context,
                            message: "Enter Username",
                          );
                        } else if (_passwordController.text.isEmpty) {
                          ToastUtil().showToastKeyBoard(
                            context: context,
                            message: "Enter Password",
                          );
                        }
                        else if (_firstNameController.text.isEmpty) {
                          ToastUtil().showToastKeyBoard(
                            context: context,
                            message: "Enter First Name",
                          );
                        }
                        else if (_lastNameController.text.isEmpty) {
                          ToastUtil().showToastKeyBoard(
                            context: context,
                            message: "Enter Last Name",
                          );
                        }
                        else if (_mobileNoController.text.isEmpty) {
                          ToastUtil().showToastKeyBoard(
                            context: context,
                            message: "Enter Contact Number",
                          );
                        }
                        else if (_emailController.text.isEmpty) {
                          ToastUtil().showToastKeyBoard(
                            context: context,
                            message: "Enter Email",
                          );
                        }else if(_passwordController.text.length < 8){
                          ToastUtil().showToastKeyBoard(
                            context: context,
                            message: "Password should be greater than 8 characters",
                          );
                        }
                        else if (!RegExp(r'^(?=(.*[A-Za-z]){2})(?=(.*\d){2})(?=(.*[!@#$%^&*()_+=[\]{}|;:,.<>?/-]){2}).{8,}$').hasMatch(_passwordController.text)) {
                          ToastUtil().showToastKeyBoard(
                            context: context,
                            message: "Please enter valid Password",
                          );
                        }else {
                          _handleRegistration(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                        Colors.white.withAlpha((0.3 * 255).toInt()),
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                      ),
                      child: CustomTextWidget(
                        text: 'Register',
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
                        onPressed: () {
                          Navigator.pushReplacement(
                            // ignore: use_build_context_synchronously
                            context,
                            MaterialPageRoute(builder: (context) => const LoginScreen()),
                          );
                        },
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(color: Colors.white70, fontSize: 14), // Default text style
                            children: [
                              TextSpan(text: 'Already have an account? '),
                              TextSpan(
                                text: 'Login Here',
                                style: TextStyle(color: Colors.white), // Highlight color for the clickable text
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Navigator.pushReplacement(
                                      // ignore: use_build_context_synchronously
                                      context,
                                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                                    );
                                  },
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }


  Future<void> _handleRegistration(BuildContext context) async {
    String username = _usernameController.text.trim();
    String password = _passwordController.text.trim();
    String firstname = _firstNameController.text.trim();
    String lastname = _lastNameController.text.trim();
    String mobilenumber = _mobileNoController.text.trim();
    String email = _emailController.text.trim();

    String registrationOperationResultMessage =
    await authService.performRegistration(username, password, email, firstname, "", lastname, mobilenumber);

    if(kDebugMode){
      log("Inside Registration screen");
      log(registrationOperationResultMessage);
    }

    if (!registrationOperationResultMessage.toLowerCase().contains("success")) {
      ToastUtil().showToast(
        // ignore: use_build_context_synchronously
        context,
        registrationOperationResultMessage,
        Icons.error_outline,
        AppColors.toastBgColorRed,
      );

      return;
    }

    ToastUtil().showToast(
      // ignore: use_build_context_synchronously
      context,
      'Successfully registration by, $username!',
      Icons.check_circle_outline,
      AppColors.toastBgColorGreen,
    );
    // Navigate to the home screen
    Navigator.pushReplacement(
      // ignore: use_build_context_synchronously
      context,
      MaterialPageRoute(
          builder: (context) =>
          const LoginScreen()),
    );
  }
}