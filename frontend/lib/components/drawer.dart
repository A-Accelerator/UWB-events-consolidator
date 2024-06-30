import 'package:flutter/material.dart';
import 'package:frontend/pages/home.dart';
import 'package:frontend/pages/calendar.dart';
import 'package:frontend/pages/login.dart';
import 'package:frontend/pages/user_events.dart';

// This widget defines the drawer menu that is displayed when the user taps on the hamburger icon.
// The drawer contains navigation links to the Home, Calendar, and My Events pages.
class AppDrawer extends StatelessWidget {
  final int userId;
  AppDrawer({super.key, required int this.userId});

  // Creating a common style for the ListTile titles
  TextStyle get listTileStyle => const TextStyle(
        fontWeight: FontWeight.bold,
        color: Colors.white,
        fontSize: 19,
      );

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
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => HomePage(
                        isAdmin: false,
                        userId: userId,
                      )));
            },
          ),
          // ListTile for moving to the Calendar page
          ListTile(
            title: Text('Calendar', style: listTileStyle),
            onTap: () {
              // Navigate to the Calendar page on tap
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) =>  CalendarPage(userId: userId,)));
            },
          ),
          // ListTile for moving to the My Events page
          ListTile(
            title: Text('My Events', style: listTileStyle),
            onTap: () {
              // Navigate to the My Events page when tapped
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => UserEventsPage(userId: userId,)));
            },
          ),
          ListTile(
            title: Text('Log Out', style: listTileStyle),
            onTap: () {
              // Navigate to the My Events page when tapped
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => LoginPage()));
            },
          ),
        ],
      ),
    );
  }
}
