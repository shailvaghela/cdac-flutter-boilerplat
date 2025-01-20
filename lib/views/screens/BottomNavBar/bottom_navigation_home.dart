import 'dart:io';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_demo/constants/app_colors.dart';

import '../SearchScreen/search_screen.dart';
import '../Settings/settings_screen.dart';
import '../home/home_screen.dart';

class BottomNavigationHome extends StatefulWidget {
  final int initialIndex;

  const BottomNavigationHome({super.key, required this.initialIndex});

  @override
  State<BottomNavigationHome> createState() => _BottomNavigationHomeState();
}

class _BottomNavigationHomeState extends State<BottomNavigationHome> {
  int _selectedIndex = 0;

  final List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    SearchScreen(),
    SettingsScreen()
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _selectedIndex = widget.initialIndex; // Set the initial index
  }
  @override
  Widget build(BuildContext context) {
     return WillPopScope(
       onWillPop: () async {
         showExitDialog(context);
         return false; // Prevent default back button behavior
       },
       child: Scaffold(
         body: Center(
           child: _widgetOptions.elementAt(_selectedIndex),
         ),
         bottomNavigationBar: BottomNavigationBar(
           backgroundColor: AppColors.primaryColor.withOpacity(0.9),
           selectedItemColor: Colors.white,
           unselectedItemColor: Colors.black,
           items: [
           BottomNavigationBarItem(
             icon: Icon(Icons.home_outlined),
             label: 'Home',
           ),
           BottomNavigationBarItem(
             icon: Icon(Icons.search),
             label: 'Search',
           ),
             BottomNavigationBarItem(
               icon: Icon(Icons.settings),
               label: 'Settings',
             ),
         ],
         currentIndex: _selectedIndex,
           onTap: (index){
             setState(() {
               _selectedIndex = index;
             });
           },
         ),
       
       ),
     );

  }

  void showExitDialog(BuildContext context) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.question,
      animType: AnimType.scale,
      title: 'Exit App',
      desc: 'Do you really want to exit the app?',
      btnCancelOnPress: () {},
      btnOkOnPress: () {
        // Exit the app
        if (Platform.isAndroid || Platform.isIOS) {
          exit(0); // Use exit(0) to close the app on mobile platforms
        }
      },
    ).show();
  }
}
