import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';
import '../../../services/DatabaseHelper/database_helper.dart';
import '../../widgets/app_bar.dart';

class LogsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.greyHundred,
      appBar: MyAppBar.buildAppBar('Exception Logs', true),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: DatabaseHelper().getExceptionLogs(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No Logs Found"));
          }

          final logs = snapshot.data!;
          return ListView.builder(
            itemCount: logs.length,
            itemBuilder: (context, index) {
              final log = logs[index];
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text(log['exception']),
                  subtitle: Text(log['timestamp']),
                  isThreeLine: true,
                  /*  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () async {
                      // Implement log deletion if needed
                    },
                  ),*/
                ),
              );
            },
          );
        },
      ),
    );
  }
}
