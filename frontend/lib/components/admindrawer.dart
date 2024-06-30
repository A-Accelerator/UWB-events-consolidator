// File: lib/components/admin_drawer.dart

import 'package:flutter/material.dart';
import 'package:frontend/pages/home.dart';
import 'package:frontend/pages/calendar.dart';
import 'package:frontend/pages/login.dart';
import 'package:frontend/pages/user_events.dart';
import 'package:frontend/pages/admin_console.dart';

// This widget defines the drawer menu for admin users.
class AdminDrawer extends StatelessWidget {
  AdminDrawer({super.key, required int this.userId});
  final int userId;

  // Creating a common style for the ListTile titles
  TextStyle get listTileStyle => const TextStyle(
        fontWeight: FontWeight.bold,
        color: Colors.white,
        fontSize: 19,
      );

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor:
          const Color(0xFF4B2E83), // Setting the background color of the drawer
      child: ListView(
        children: [
          // ListTile for moving to the Home page
          ListTile(
            title: Text('Home', style: listTileStyle),
            onTap: () {
              // Navigate to the Home page on tap
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) => HomePage(
                      userId: userId,
                        isAdmin: true,
                      )));
            },
          ),
          // ListTile for moving to the Calendar page
          ListTile(
            title: Text('Calendar', style: listTileStyle),
            onTap: () {
              // Navigate to the Calendar page on tap
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) =>  CalendarPage(userId: userId,)));
            },
          ),
          // ListTile for moving to the My Events page
          ListTile(
            title: Text('My Events', style: listTileStyle),
            onTap: () {
              // Navigate to the My Events page when tapped
              Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => UserEventsPage(userId: userId,)));
            },
          ),
          // ListTile for moving to the Admin Console page
          ListTile(
            title: Text('Admin Console', style: listTileStyle),
            onTap: () {
              // Navigate to the Admin Console page when tapped
              Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => AdminConsolePage(userId: userId,)));
            },
          ),
          // ListTile for logging out
          ListTile(
            title: Text('Log Out', style: listTileStyle),
            onTap: () {
              // Navigate to the Login page when tapped
              Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => LoginPage()));
            },
          ),
        ],
      ),
    );
  }
}
