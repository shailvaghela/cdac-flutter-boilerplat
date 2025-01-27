

import 'package:flutter/material.dart';

void showCustomConfirmationDialog({
  required BuildContext context,
  required String title,
  required String content,
  required IconData icon,
  required backgroundColor,
  required iconColor,
  required VoidCallback onYesPressed,
}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 10,
        child: Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 50,
                color: iconColor,
              ),
              SizedBox(height: 20),
              Text(
                title,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text(
                content,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close dialog
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text('Cancel',style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Exit the app
                      onYesPressed();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: backgroundColor,
                      padding: EdgeInsets.symmetric(
                          horizontal: 30, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text('OK',style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),),
                  ),
                ],
              ),
            ],
          ),
        ),
      );

      // return AlertDialog(
      //   shape: RoundedRectangleBorder(
      //     borderRadius: BorderRadius.circular(15),
      //   ),
      //   title: Row(
      //     children: [
      //       Icon(
      //         icon,
      //         color: Colors.blue,
      //         size: 30,
      //       ),
      //       const SizedBox(width: 10),
      //       Text(title),
      //     ],
      //   ),
      //   content: Text(content),
      //   actions: <Widget>[
      //     TextButton(
      //       onPressed: () {
      //         Navigator.of(context).pop(); // Close dialog
      //       },
      //       child: const Text(
      //         'No',
      //         style: TextStyle(color: Colors.red),
      //       ),
      //     ),
      //     TextButton(
      //       onPressed: () {
      //         onYesPressed(); // Trigger the provided "Yes" action
      //         Navigator.of(context).pop(); // Close dialog
      //       },
      //       child: const Text(
      //         'Yes',
      //         style: TextStyle(color: Colors.green),
      //       ),
      //     ),
      //   ],
      // );
    },
  );
}