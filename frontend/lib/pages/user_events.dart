// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:frontend/api_service.dart';
import '../components/drawer.dart';
import './event.dart';
import './eventsearch.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class UserEventsPage extends StatefulWidget {
  final int userId;
  const UserEventsPage({super.key, required this.userId});

  @override
  _UserEventsPageState createState() => _UserEventsPageState();
}

class _UserEventsPageState extends State<UserEventsPage> {
  List<Event> _events = [];
  bool _isLoading = false;
  String _error = "";

  final apiService = ApiService('http://192.168.86.234:8080');

  @override
  void initState() {
    super.initState();
    loadEvents();
  }

  // Method to call the API service (use try/catch to catch the error and capture it in the string)
  Future<void> loadEvents() async {
    setState(() {
      _isLoading = true;
      _error = "";
    });
    try {
      final url = Uri.parse('http://192.168.86.234:8080/user/userEvents/${widget.userId}');
      final response = await http.get(url);
      List<dynamic> events = jsonDecode(response.body);
      setState(() {
        _events = events.map((event) => Event.fromJson(event)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('M/d/yyyy');
    final timeFormat = DateFormat('h:mma');

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
                  builder: (context) => EventSearchPage(userID: widget.userId),
                ), // Navigate to EventSearchPage
              );
            },
            color: Color(0xFF4B2E83),
          ),
        ],
      ),
      drawer: AppDrawer(userId: widget.userId), // Drawer with navigation options
      body: Padding(
        padding: const EdgeInsets.only(top: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_isLoading)
              Center(child: CircularProgressIndicator())
            else if (_error.isNotEmpty)
              Center(child: Text('Error: $_error'))
            else
              Expanded(
                child: ListView(
                  scrollDirection: Axis.vertical,
                  padding: EdgeInsets.fromLTRB(13, 0, 0, 0),
                  children: _events.map((event) {
                    final eventDate = dateFormat.format(event.startDate);
                    String formattedTime =
                        '${timeFormat.format(event.startTime).toLowerCase()} - ${timeFormat.format(event.endTime).toLowerCase()}';
                    return Padding(
                      padding: EdgeInsets.only(bottom: 13),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => EventPage(
                              title: event.eventName,
                              image: event.image,
                              navTo: 'userEvents',
                              userId: widget.userId,
                            ),
                          ));
                        },
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(0, 0, 11, 0),
                            child: Stack(
                              children: [
                                Container(
                                  width: 370,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    color: Colors.white, // Set the background color to white
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        spreadRadius: 2,
                                        blurRadius: 8,
                                        offset: Offset(0, 4), // changes position of shadow
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.fromLTRB(0, 15, 0, 0),
                                      child: Center(
                                        child: Text(
                                          event.eventName,
                                          style: TextStyle(
                                            color: Color(0xFF4B2E83),
                                            fontSize: 30,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                    Center(
                                      child: Text(
                                        '$eventDate | $formattedTime',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 15,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class Event {
  final int id;
  final String eventName;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  final DateTime startDate;
  final DateTime endDate;
  final String image;
  final DateTime createdAt;
  final List<dynamic> signedUpUsers;

  Event({
    required this.id,
    required this.eventName,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.startDate,
    required this.endDate,
    required this.image,
    required this.createdAt,
    required this.signedUpUsers,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
      eventName: json['eventName'],
      description: json['description'],
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      image: json['image'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      signedUpUsers: List<dynamic>.from(json['signedUpUsers']),
    );
  }
}
