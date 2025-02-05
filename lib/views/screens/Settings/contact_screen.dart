import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/theme_provider.dart';
import '../../widgets/app_bar.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {

  @override
  Widget build(BuildContext context) {
    Provider.of<ThemeProvider>(context, listen: false);
    return Scaffold(
      //backgroundColor: AppColors.greyHundred,
        appBar: MyAppBar.buildAppBar('Settings', false),
        body: Center(
          // ignore: avoid_unnecessary_containers
          child: Container(
            child: Column(
              children: [
                SizedBox(height: 40,),
                Icon(Icons.location_on),
                SizedBox(height: 10,),
                Text("New Delhi"),
                SizedBox(height: 20,),
                Divider(
                  color: Colors.black, // Line color
                  thickness: 2,         // Line thickness
                  indent: 20,           // Space before the line starts
                  endIndent: 20,        // Space after the line ends
                ),
                SizedBox(height: 20,),
                Icon(Icons.phone),
                SizedBox(height: 10,),
                Text("9994567890"),
                SizedBox(height: 20,),
                Divider(
                  color: Colors.black, // Line color
                  thickness: 2,         // Line thickness
                  indent: 20,           // Space before the line starts
                  endIndent: 20,        // Space after the line ends
                ),
                SizedBox(height: 20,),
                Icon(Icons.email),
                SizedBox(height: 10,),
                Text("demoapp123@gmail.com"),
                SizedBox(height: 20,),
                Divider(
                  color: Colors.black, // Line color
                  thickness: 2,         // Line thickness
                  indent: 20,           // Space before the line starts
                  endIndent: 20,        // Space after the line ends
                ),
                SizedBox(height: 20,),
                Icon(Icons.access_time),
                SizedBox(height: 10,),
                Text("10:00 AM to 5:00 PM"),
                SizedBox(height: 20,),
              ],
            ),
          ),
        ));
  }
}