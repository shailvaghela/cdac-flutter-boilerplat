import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
import '../../../constants/app_colors.dart';
import '../../../services/DatabaseHelper/database_helper_web.dart';
import '../../../utils/toast_util.dart';
import '../../../viewmodels/Login/login_view_model.dart';
import '../../widgets/custom_password_widget.dart';
import '../../widgets/custom_text_widget.dart';
import '../../widgets/custom_username_widget.dart';
import '../../widgets/gradient_container.dart';
import '../BottomNavBar/bottom_navigation_home.dart';
import '../Register/register_screen.dart';
import 'package:flutter_demo/services/AuthService/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  AuthService authService = AuthService();

  @override
  void initState() {
    super.initState();
    _initializeDatabase();
  }

  // Initialize the database on the first screen or in the app
  Future<void> _initializeDatabase() async {
    await DbHelper().init();
  }

  @override
  Widget build(BuildContext context) {
    final loginViewModel = context.watch<LoginViewModel>();
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Define layout for mobile vs web using screen size and conditions
    bool isWeb = kIsWeb || screenWidth > 600;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      extendBody: true,
      body: Stack(
        children: [
          GradientContainer(),
          Center(
            child: Container(
              width: isWeb ? screenWidth * 0.3 : screenWidth * 1, // Adjust width for web vs mobile
              margin: EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha((0.1 * 255).toInt()),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withAlpha((0.3 * 255).toInt()),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha((0.2 * 255).toInt()),
                    blurRadius: 10,
                    offset: const Offset(4, 4),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Image.asset(
                      'assets/images/loginpage.png',
                      height: screenHeight * 0.2,
                    ),
                    const SizedBox(height: 20),

                    customUserNameWidget(
                      textEditController: _usernameController,
                      hintText: "Username",
                      icon: Icons.person,
                    ),

                    const SizedBox(height: 20),

                    customPasswordWidget(
                      textEditController: _passwordController,
                      hintText: "Password",
                      isPassword: true,
                      isPasswordVisible: _isPasswordVisible,
                      togglePasswordVisibility: _togglePasswordVisibility,
                    ),
                    const SizedBox(height: 10),

                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: Text('demo user'),
                                content: Text(
                                    'username: emilys\n\npassword: emilyspass'),
                              ));
                        },
                        child: CustomTextWidget(
                          text: 'Forgot Password?',
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

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
                        text: 'Login',
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 20),

                    Align(
                      alignment: Alignment.center,
                      child: TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const RegisterScreen()),
                          );
                        },
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14),
                            children: [
                              TextSpan(text: 'New User? '),
                              TextSpan(
                                text: 'Register Here',
                                style: TextStyle(color: Colors.white),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                          const RegisterScreen()),
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

  Future<void> _handleLogin(BuildContext context) async {
    final loginViewmodel = context.read<LoginViewModel>();

    String? loginOperationResultMessage = await loginViewmodel.performLogin(
        _usernameController.text.trim(), _passwordController.text.trim());

    if (kDebugMode) {
      log("Inside login screen");
      log(loginOperationResultMessage!);
    }

    if (!loginOperationResultMessage!.toLowerCase().contains("success")) {
      ToastUtil().showToast(
        // ignore: use_build_context_synchronously
        context,
        loginOperationResultMessage,
        Icons.error_outline,
        AppColors.toastBgColorRed,
      );

      return;
    }

    ToastUtil().showToast(
      // ignore: use_build_context_synchronously
      context,
      'Successfully logged in',
      Icons.check_circle_outline,
      AppColors.toastBgColorGreen,
    );

    Navigator.pushReplacement(
      // ignore: use_build_context_synchronously
      context,
      MaterialPageRoute(
          builder: (context) => const BottomNavigationHome(
            initialIndex: 0,
          )),
    );
  }
}


// // ignore_for_file: unused_import
//
// import 'dart:developer';
//
// import 'package:flutter/foundation.dart';
// import 'package:flutter/gestures.dart';
// import 'package:flutter/material.dart';
// // import 'package:flutter_demo/views/widgets/custom_help_text.dart';
// import 'package:provider/provider.dart';
//
// import '../../../constants/app_colors.dart';
// import '../../../constants/app_strings.dart';
// import '../../../constants/assest_path.dart';
// import '../../../models/LoginModel/login_response.dart';
// import '../../../models/LoginModel/login_response_new.dart';
// import '../../../services/EncryptionService/encryption_service_new.dart';
// import '../../../utils/toast_util.dart';
// import '../../../viewmodels/Login/login_view_model.dart';
// import '../../../viewmodels/Login/login_view_model_new.dart';
// import '../../widgets/custom_password_widget.dart';
// import '../../widgets/custom_text_widget.dart';
// import '../../widgets/custom_username_widget.dart';
// import '../../widgets/gradient_container.dart';
// import '../BottomNavBar/bottom_navigation_home.dart';
// import '../Register/register_screen.dart';
//
// import 'package:flutter_demo/services/AuthService/auth_service.dart';
//
// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});
//
//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }
//
// class _LoginScreenState extends State<LoginScreen> {
//   final TextEditingController _usernameController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   bool _isPasswordVisible = false;
//
//   AuthService authService = AuthService();
//
//   @override
//   Widget build(BuildContext context) {
//     final loginViewModel = context.watch<LoginViewModel>();
//     // ignore: unused_local_variable
//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;
//
//     return Scaffold(
//       resizeToAvoidBottomInset: true, // Ensures UI adjusts with the keyboard
//       extendBody: true,
//       body: Stack(
//         children: [
//           // Gradient Background
//           GradientContainer(),
//
//           // Glassmorphic Card for Login
//           Center(
//             child: Container(
//               margin: const EdgeInsets.symmetric(horizontal: 20),
//               padding: const EdgeInsets.all(20),
//               decoration: BoxDecoration(
//                 color: Colors.white
//                     .withAlpha((0.1 * 255).toInt()), // Adjusting opacity
//                 borderRadius: BorderRadius.circular(20),
//                 border: Border.all(
//                   color: Colors.white
//                       .withAlpha((0.3 * 255).toInt()), // Adjusting opacity
//                   width: 1.5,
//                 ),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black
//                         .withAlpha((0.2 * 255).toInt()), // Adjusting opacity
//                     blurRadius: 10,
//                     offset: const Offset(4, 4),
//                   ),
//                 ],
//               ),
//               child: SingleChildScrollView(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.stretch,
//                   children: [
//                     // App logo
//                     Image.asset(
//                       'assets/images/loginpage.png',
//                       height: screenHeight * 0.2,
//                     ),
//                     const SizedBox(height: 20),
//
//                     // Username TextField
//                     customUserNameWidget(
//                       textEditController: _usernameController,
//                       hintText: "Username",
//                       icon: Icons.person,
//                     ),
//
//                     const SizedBox(height: 20),
//
//                     // Password TextField
//                     customPasswordWidget(
//                       textEditController: _passwordController,
//                       hintText: "Password",
//                       isPassword: true,
//                       isPasswordVisible: _isPasswordVisible,
//                       togglePasswordVisibility: _togglePasswordVisibility,
//                     ),
//                     const SizedBox(height: 10),
//
//                     // Forgot Password
//                     Align(
//                       alignment: Alignment.centerRight,
//                       child: TextButton(
//                         onPressed: () {
//                           showDialog(
//                               context: context,
//                               builder: (_) => AlertDialog(
//                                     title: Text('demo user'),
//                                     content: Text(
//                                         'username: emilys\n\npassword: emilyspass'),
//                                   ));
//                         },
//                         child: CustomTextWidget(
//                           text: 'Forgot Password?',
//                           color: Colors.white70,
//                           fontSize: 14,
//                         ),
//                       ),
//                     ),
//
//                     const SizedBox(height: 20),
//
//                     // Login Button
//                     loginViewModel.isLoading
//                         ? Center(
//                             child: CircularProgressIndicator(
//                               color: Colors.white70,
//                             ),
//                           )
//                         : ElevatedButton(
//                             onPressed: () {
//                               if (_usernameController.text.isEmpty) {
//                                 ToastUtil().showToast(
//                                   context,
//                                   'Enter Username',
//                                   Icons.person,
//                                   AppColors.toastBgColorRed,
//                                 );
//                               } else if (_passwordController.text.isEmpty) {
//                                 ToastUtil().showToast(
//                                   context,
//                                   'Enter Password',
//                                   Icons.lock,
//                                   AppColors.toastBgColorRed,
//                                 );
//                               } else {
//                                 _handleLogin(context);
//                               }
//                             },
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor:
//                                   Colors.white.withAlpha((0.3 * 255).toInt()),
//                               shadowColor: Colors.transparent,
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                               padding: EdgeInsets.symmetric(
//                                   horizontal: 20, vertical: 10),
//                             ),
//                             child: CustomTextWidget(
//                               text: 'Login',
//                               color: Colors.white,
//                               fontSize: 16,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//
//                     const SizedBox(height: 20),
//
//                     // New User Link
//                     Align(
//                       alignment: Alignment.center,
//                       child: TextButton(
//                         onPressed: () {
//                           Navigator.pushReplacement(
//                             // ignore: use_build_context_synchronously
//                             context,
//                             MaterialPageRoute(
//                                 builder: (context) => const RegisterScreen()),
//                           );
//                         },
//                         child: RichText(
//                           text: TextSpan(
//                             style: TextStyle(
//                                 color: Colors.white70,
//                                 fontSize: 14), // Default text style
//                             children: [
//                               TextSpan(text: 'New User? '),
//                               TextSpan(
//                                 text: 'Register Here',
//                                 style: TextStyle(
//                                     color: Colors
//                                         .white), // Highlight color for the clickable text
//                                 recognizer: TapGestureRecognizer()
//                                   ..onTap = () {
//                                     Navigator.pushReplacement(
//                                       // ignore: use_build_context_synchronously
//                                       context,
//                                       MaterialPageRoute(
//                                           builder: (context) =>
//                                               const RegisterScreen()),
//                                     );
//                                   },
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     )
//                     /* Align(
//                       alignment: Alignment.center,
//                       child: TextButton(
//                         onPressed: () {
//                           Navigator.pushReplacement(
//                             // ignore: use_build_context_synchronously
//                             context,
//                             MaterialPageRoute(builder: (context) => const RegisterScreen()),
//                           );
//
//                         },
//                         child: CustomTextWidget(
//                           text: 'New User? Register Here',
//                           color: Colors.white70,
//                           fontSize: 14,
//                         ),
//                       ),
//                     ),*/
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // ignore: unused_element
//   Widget _buildGlassTextField({
//     required TextEditingController controller,
//     required String hintText,
//     required IconData icon,
//     bool isPassword = false,
//     bool? isPasswordVisible,
//     VoidCallback? togglePasswordVisibility,
//   }) {
//     return TextField(
//       controller: controller,
//       obscureText: isPassword ? !(isPasswordVisible ?? true) : false,
//       style: const TextStyle(color: Colors.white),
//       decoration: InputDecoration(
//         filled: true,
//         fillColor: Colors.white.withAlpha((0.1 * 255).toInt()),
//         hintText: hintText,
//         hintStyle: const TextStyle(color: Colors.white70),
//         prefixIcon: Icon(icon, color: Colors.white70),
//         suffixIcon: isPassword
//             ? IconButton(
//                 icon: Icon(
//                   isPasswordVisible! ? Icons.visibility : Icons.visibility_off,
//                   color: Colors.white70,
//                 ),
//                 onPressed: togglePasswordVisibility,
//               )
//             : null,
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide.none,
//         ),
//       ),
//     );
//   }
//
//   void _togglePasswordVisibility() {
//     setState(() {
//       _isPasswordVisible = !_isPasswordVisible;
//     });
//   }
//
//   // Handle login action
//   Future<void> _handleLogin(BuildContext context) async {
//     final loginViewmodel = context.read<LoginViewModel>();
//
//     String? loginOperationResultMessage = await loginViewmodel.performLogin(
//         _usernameController.text.trim(), _passwordController.text.trim());
//
//     if (kDebugMode) {
//       log("Inside login screen");
//       log(loginOperationResultMessage!);
//     }
//
//     if (!loginOperationResultMessage!.toLowerCase().contains("success")) {
//       ToastUtil().showToast(
//         // ignore: use_build_context_synchronously
//         context,
//         loginOperationResultMessage,
//         Icons.error_outline,
//         AppColors.toastBgColorRed,
//       );
//
//       return;
//     }
//
//     ToastUtil().showToast(
//       // ignore: use_build_context_synchronously
//       context,
//       'Successfully logged in',
//       Icons.check_circle_outline,
//       AppColors.toastBgColorGreen,
//     );
//     // Navigate to the home screen
//     Navigator.pushReplacement(
//       // ignore: use_build_context_synchronously
//       context,
//       MaterialPageRoute(
//           builder: (context) => const BottomNavigationHome(
//                 initialIndex: 0,
//               )),
//     );
//   }
// }
