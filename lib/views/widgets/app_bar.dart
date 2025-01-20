import 'package:flutter/material.dart';

class MyAppBar {
  static AppBar buildAppBar(
      String titleName, bool automaticallyImplyLeadingCheck) {
    return AppBar(
      automaticallyImplyLeading: automaticallyImplyLeadingCheck,
      iconTheme: IconThemeData(color: Colors.white),
      title: Text(
        titleName,
        style: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.w500,
            color: Colors.white,
            fontFamily: 'Montserrat',
            letterSpacing: 1.5),
      ),
      centerTitle: true,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            /* colors: [
              Colors.blue.shade700.withOpacity(0.9),
              Colors.purple.shade100
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,*/
            colors: [Colors.blue.shade700.withOpacity(0.9), Color(0xFF85D8CE)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
    );
  }
}
