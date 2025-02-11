import 'dart:io';
import 'package:workmanager/workmanager.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:logger/logger.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../DatabaseHelper/database_helper.dart';

const taskKontrol = "uploadLogsTask123";

// Define a task ID
const taskID = 'simpleTask';

class WorkManagerService {
  static final Logger logger = Logger();

  // Method to initialize WorkManager and set the dispatcher
  static void initialize() {
    print("workmanagerinitialize--->");
    Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
  }

  // Method to register the background task at a specific time (e.g., end of the day)
  static void registerDailyTaskAtSpecificTime() async {
    // Get the next scheduled time (11:59 PM of the current day)
    final nextScheduledTime = _getNextScheduledTime();

    // Calculate the delay until the scheduled time
    final currentTime = DateTime.now();
    final delayDuration = nextScheduledTime.difference(currentTime);

    // Register the one-time background task with a delay
    Workmanager().registerOneOffTask(
      "simpleTask", // Unique task name
      "simpleTask", // Unique task identifier
      initialDelay: delayDuration,
      inputData: {'key': 'value'},
      constraints: Constraints(
        networkType: NetworkType.connected,
        // Only run when there's a network connection
        requiresBatteryNotLow:
            true, // Optional: Prevents task from running when battery is low
      ),
    );

    print("Next task scheduled for: $nextScheduledTime");
  }

  // Method to register periodic task
  static Future periodicTaskRegistration() async {
    Workmanager().registerPeriodicTask(
      "periodicTask",
      "periodicTask",
      frequency: Duration(minutes: 15),
      existingWorkPolicy: ExistingWorkPolicy.append,
      constraints: Constraints(
        networkType: NetworkType.connected, // Ensure network is connected
        requiresBatteryNotLow: true, // Optional: Prevent running on low battery
      ),
    );
    // Note: The minimum frequency for periodic tasks is 15 minutes
    print("Periodic task registered: $taskKontrol");
  }

  static Future cancelAllTask() async {
    Workmanager().cancelAll();
  }

  static Future simpleRegisterPeriodicTask() async {
    Workmanager().registerPeriodicTask(
      "periodicTask",
      "periodicTask",
      frequency: Duration(minutes: 15), // Minimum 15 minutes
    );
  }

  static Future simpleRegisterOneOffTask() async {
    print("simpleRegisterOneOffTask");
    Workmanager().registerOneOffTask(
      "simpleTask",
      "simpleTask",
    );
  }

  // Method to get the next scheduled time for the background task (11:59 PM)
  static DateTime _getNextScheduledTime() {
    final now = DateTime.now();
    final scheduledTime =
        DateTime(now.year, now.month, now.day, 23, 59); // 11:59 PM today

    if (now.isAfter(scheduledTime)) {
      // If the current time is past 11:59 PM, schedule for the next day
      return scheduledTime.add(Duration(days: 1));
    }
    return scheduledTime; // Schedule for today if it's before 11:59 PM
  }

  // Method to generate log file (save logs)
  Future<void> generateLogFile() async {
    print("Logfilegenerated");
    try {
      final directory = await getApplicationDocumentsDirectory();
      final logFile = File('${directory.path}/app_logs.txt');

      final logMessages = [
        'App started at ${DateTime.now()}',
        'Log file created at ${DateTime.now()}',
        // Add additional log entries here
      ];

      for (var message in logMessages) {
        logger.i(message);
        logFile.writeAsStringSync('$message\n', mode: FileMode.append);
      }

      print("Log file generated at ${logFile.path}");
    } catch (e) {
      print("Error:$e");
    }
  }

  static Future<String> readLogFile() async {
    final directory = await getApplicationDocumentsDirectory();
    final logFile = File('${directory.path}/app_logs.txt');

    if (await logFile.exists()) {
      return await logFile.readAsString();
    } else {
      return 'Log file does not exist.';
    }
  }

  // Method to upload the log file to the server
  static Future<void> uploadLogs() async {
    final directory = await getApplicationDocumentsDirectory();
    final logFile = File('${directory.path}/app_logs.txt');

    if (logFile.existsSync()) {
      print("Uploading log file...");

      // Simulate the log upload via HTTP POST request (replace with your server URL)
      final url = Uri.parse('https://your-server.com/upload');
      final response = await http.post(url, body: {
        'file': logFile.readAsStringSync(),
      });

      if (response.statusCode == 200) {
        print("Log file uploaded successfully!");
        logFile
            .deleteSync(); // Optionally delete the file after successful upload
      } else {
        print("Failed to upload log file.");
      }
    } else {
      print("Log file does not exist.");
    }
  }
}

// Top-level function for the callback dispatcher
// Method to perform the task in the background
//@pragma('vm:entry-point')
void callbackDispatcher() {
  print("Executing callbackDispatcher");

  Workmanager().executeTask((task, inputData) async {
    try {
      switch (task) {
        case 'simpleTask':
          print("Executing simple task");
          // Generate log file if not exists
          await WorkManagerService().generateLogFile();
          /* await DatabaseHelper().insertGeoPicture(
              "storage/emulated/0/DCIM/ProfilePic/DummyUser_c5d69eeccf29b4d9_img_11022025_115858.jpg",
              "Gallery");*/

          break;
        case 'periodicTask':
          print("Executing periodic task");
          await DatabaseHelper().insertGeoPicture(
              "storage/emulated/0/DCIM/ProfilePic/DummyUser_c5d69eeccf29b4d9_img_11022025_115858.jpg",
              "Gallery");
          // Check network connectivity before uploading logs
         /* Connectivity().checkConnectivity().then((connectivityResult) async {
            if (connectivityResult.contains(ConnectivityResult.mobile) ||
                connectivityResult.contains(ConnectivityResult.wifi)) {
              // Upload log files to server if connected
              // await uploadLogs();
            } else {
              print("No internet connection, retrying later.");
            }
          });*/
          break;
        default:
          print("Unknown task: $task");
      }

      return Future.value(
          true); // Return true to indicate that the task was successful
    } catch (error) {
      print('There is an error($error) in this $task');
      return Future.error(error);
    }
  });
}
