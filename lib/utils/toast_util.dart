import 'package:delightful_toast/delight_toast.dart';
import 'package:delightful_toast/toast/components/toast_card.dart';
import 'package:delightful_toast/toast/utils/enums.dart';
import 'package:flutter/material.dart';

class ToastUtil {
  // Singleton instance
  static final ToastUtil _instance = ToastUtil._internal();

  factory ToastUtil() {
    return _instance;
  }

  ToastUtil._internal();

  void  showToast(BuildContext context, String message, IconData icon,Color color) {
    DelightToastBar(
      builder: (context) {
        return ToastCard(
          color: color,
          leading: Icon(
            icon,
            //Icons.notifications,
            size: 32,
            color: Colors.white,
          ),
          title: Text(
            message,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: Colors.white
            ),
          ),
        );
      },
      position: DelightSnackbarPosition.bottom,
      autoDismiss: true,
      snackbarDuration: Duration(seconds: 3),
    ).show(context);
  }
}