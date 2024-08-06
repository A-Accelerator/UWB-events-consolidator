import 'dart:convert';
import 'package:frontend/pages/viewEvent.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

import 'package:frontend/api_service.dart';
import 'package:frontend/pages/adminedit.dart';
import 'package:frontend/pages/eventedit.dart';

import '../components/drawer.dart';
import '../components/admindrawer.dart';
import './event.dart';
import './eventsearch.dart';
import 'package:intl/intl.dart';
import 'package:frontend/pages/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Async function that parses and filters JSON objects
Future<List<Event>> _fetchEvents(String jsonString) async {
  // Get the json data by parsing the passed in string
  final List<dynamic> jsonData = jsonDecode(jsonString);

  // now return with the output stream: map it, where only events that are not null are used, and parse it to a list
  return jsonData
      .map((json) => Event.fromJson(json))
      .where((event) => event.image != null)
      .toList();
}

// HomePage represents the main page of the application that has the header, a search button, and a list of featured events.
class HomePage extends StatefulWidget {
  final bool isAdmin;
  final int userId;
  HomePage({Key? key, required this.isAdmin, required this.userId}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> _events = [];
  late bool _isAdmin;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAdminStatus();
    fetchHomeEvents();
  }

  // Load the admin status from SharedPreferences
  Future<void> _loadAdminStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isAdmin =
          prefs.getBool('isAdmin') ?? false; // Default to false if not found
    });
  }

  Future<void> fetchHomeEvents() async {
    final url = Uri.parse('http://128.199.8.191:8080/event/homeEvents');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        List<dynamic> events = jsonDecode(response.body);
        setState(() {
          _events = events
              .map((event) => {
                    'id': event['id'],
                    'eventName': event['eventName'],
                    'startDate': event['startDate'],
                    'description': event['description'],
                    'endDate': event['endDate'],
                    'image': event['image'],
                    'createdAt': event['createdAt'],
                    'signedUpUsers': event['signedUpUsers'],
                  })
              .toList();
          _isLoading = false;
        });
      } else {
        print('Failed to fetch events. Status code: ${response.statusCode}');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching events: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    DateTime today = DateTime.now();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Eventipedia - UW Bothell',
          style: TextStyle(
            color: Color(0xFF4B2E83),
          ),
        ),
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu), // Hamburger icon for the drawer
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              color: const Color(0xFF4B2E83),
            );
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search), // Search Icon
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        EventSearchPage(userID: widget.userId)), // Navigate to EventSearchPage
              );
            },
            color: Color(0xFF4B2E83),
          ),
        ],
      ),
      drawer: _isAdmin ? AdminDrawer(userId: widget.userId) : AppDrawer(userId: widget.userId),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 10),
                      // New events
                      child: Text(
                        'New This Week: ${today.year}-${today.month}-${today.day}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 17,
                        ),
                      ),
                    ),
                  ),
                  // Featured Events displayed below
                  Expanded(
                    child: _events.isNotEmpty
                        ? ListView(
                            scrollDirection: Axis.horizontal,
                            children: _events.take(2).map((event) {
                              return _buildEventCard(
                                  context,
                                  event['eventName'],
                                  event['image'],
                                  event['id']);
                            }).toList(),
                          )
                        : Center(
                            child: Text('No events available'),
                          ),
                  ),
                  Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: Text('Other Events:',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontSize: 17,
                          )),
                    ),
                  ),
                  Expanded(
                    child: _events.length > 2
                        ? ListView(
                            scrollDirection: Axis.horizontal,
                            children: _events.skip(2).take(3).map((event) {
                              return _buildEventCard(
                                  context,
                                  event['eventName'],
                                  event['image'],
                                  event['id']);
                            }).toList()
                              ..add(_events.length > 5
                                  ? IconButton(
                                      icon: Icon(Icons.arrow_forward),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => EventListPage(
                                                  userId: widget.userId,
                                                  events: _events.skip(2).toList())),
                                        );
                                      },
                                    )
                                  : Container()),
                          )
                        : Center(
                            child: Text('No other events available'),
                          ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildEventCard(
      BuildContext context, String title, String imageUrl, int eventId) {
    return Padding(
      padding: EdgeInsets.only(right: 13),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => EventPageStatic(
                eventId: eventId,
                userId: widget.userId // Pass the event ID to the EventPage
              ),
            ),
          );
        },
        child: Stack(
          children: [
            Container(
              width: 343,
              height: 360,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: NetworkImage(imageUrl),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.5), // Adjust opacity here
                    BlendMode.dstATop,
                  ),
                ),
              ),
            ),
            Container(
              width: 343,
              height: 360,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Color(0xFF4B2E83)
                    .withOpacity(0.4), // Shade color with opacity
              ),
            ),
            Positioned.fill(
              child: Center(
                child: Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// EventListPage class to handle the display of the remaining events
class EventListPage extends StatelessWidget {
  final int userId;
  final List<Map<String, dynamic>> events;

  EventListPage({required this.userId, required this.events});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('M/d/yyyy');
    final timeFormat = DateFormat('h:mma');

    return Scaffold(
      appBar: AppBar(
        title: Text('All Events'),
      ),
      body: ListView.builder(
        itemCount: events.length,
        itemBuilder: (context, index) {
          final event = events[index];
          final eventDate = dateFormat.format(DateTime.parse(event['startDate']));
          final formattedTime = '${timeFormat.format(DateTime.parse(event['startDate'])).toLowerCase()} - ${timeFormat.format(DateTime.parse(event['endDate'])).toLowerCase()}';
          
          return GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => EventPageStatic(
                    eventId: event['id'],
                    userId: userId, // Pass the event ID to the EventPage
                  ),
                ),
              );
            },
            child: Container(
              padding: EdgeInsets.all(10),
              margin: EdgeInsets.symmetric(vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3), // changes position of shadow
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image: DecorationImage(
                        image: NetworkImage(event['image']),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event['eventName'],
                          style: TextStyle(
                            color: Color(0xFF4B2E83),
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          eventDate,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          formattedTime,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
