import 'package:flutter/material.dart';
import 'dart:io';

void showProfileImageDialog(BuildContext context, String profilePicPath) {
  if (profilePicPath.isNotEmpty) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.file(
              File(profilePicPath),
              fit: BoxFit.contain,
            ),
            const Divider(),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Close',
                style: TextStyle(fontSize: 18, color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('No profile image available')),
    );
  }
}

// Show logs in a dialog with numbers indicating each log entry
void showAppLogsDialog(BuildContext context, List<String> logList) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text("App Logs"),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Here are the logs of your app activities:",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(height: 8.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: logList.asMap().entries.map((entry) {
                int index = entry.key + 1; // Numbering starts from 1
                String logEntry = entry.value;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Text(
                    "$index. $logEntry",
                    // Adding index number before each log
                    style: TextStyle(fontSize: 14),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text("OK"),
        ),
      ],
    ),
  );
}

void showLogDialog(BuildContext context, String logContents) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Log File Contents'),
        content: SingleChildScrollView(
          child: Text(
            logContents.isNotEmpty ? logContents : 'No logs available.',
            style: TextStyle(fontSize: 16),
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: Text('Close'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
